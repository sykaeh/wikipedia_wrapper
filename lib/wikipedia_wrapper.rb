require 'uri'
require 'open-uri'
require 'json'
require 'cache'
require 'wikipedia_wrapper/exception'
require 'wikipedia_wrapper/configuration'
require 'wikipedia_wrapper/page'

# @author Sybil Ehrensberger <contact@sybil-ehrensberger.com>
module WikipediaWrapper

  extend self

  # @!attribute [r]
  #   @return [WikipediaWrapper::Configuration] the configuration for this module
  def config
    @config ||= Configuration.new
  end

  # Set up configuration options
  #
  # @yieldparam config [WikipediaWrapper::Configuration] the configuration instance
  # @example
  #   WikipediaWrapper.configure do |config|
  #     config.api_key = 'http://en.wikipedia.org/w/api.php'
  #     config.user_agent = 'WikipediaWrapper/0.0.1 (http://sykaeh.github.com/wikipedia_wrapper/) Ruby/2.2.1'
  #     config.default_ttl = 604800
  #   end
  def configure
    @config ||= Configuration.new
    yield(config)
  end

  # Retrieve the cache for this module if it is already defined, otherwise
  # create a new Cache, defaulting to an in-memory cache
  # @return [Cache] the cache
  def cache
    if @cache.nil?
      @cache = Cache.new
      @cache.config.default_ttl = config.default_ttl
    end
    @cache
  end


  # Define the caching client
  # @example
  #   WikipediaWrapper.cache(Memcached.new('127.0.0.1:11211', :binary_protocol => true))
  #   WikipediaWrapper.cache(Dalli::Client.new)
  #   WikipediaWrapper.cache(Redis.new)
  #   WikipediaWrapper.cache(Rails.new)
  # @see https://github.com/seamusabshere/cache Cache Gem Configuration
  # @param raw_client [Memcached, Dalli::Client, Redis, memcache-client] a caching client (Memcached, Dalli, memcache-client, redis)
  # @param timeout [Integer] default timeout for the cache entries [in seconds]
  def cache=(raw_client, timeout: config.default_ttl)
    @cache = Cache.wrap(raw_client)
    @cache.config.default_ttl = timeout
  end


  # Convenience function to retrieve a Wikipedia page
  #
  # @param term [String] the title of the page
  # @param auto_suggest [Boolean] whether the search and autocorrect suggestion should be used to find a valid term (default: true)
  # @param redirect [Boolean] whether redirects should be followed automatically (default: true)
  # @return [WikipediaWrapper::Page] the wiki page
  def page(term, auto_suggest: true, redirect: true)

    if auto_suggest
      term = check_page(term)
    end

    return WikipediaWrapper::Page.new(term, redirect: redirect)

  end

  # Plain text or basic HTML summary of the page. Redirects are always followed
  # automatically.
  #
  # @note This is a convenience wrapper - auto_suggest and redirect are enabled by default
  #
  # @raise [WikipediaWrapper::PageError] if no page with that term was found
  # @raise [WikipediaWrapper::MultiplePagesError] if more than one page with that term was found
  # @param term [String] the title of the page
  # @param html [Boolean] if true, return basic HTML instead of plain text
  # @param sentences [Integer] if set, return the first `sentences` sentences (can be no greater than 10).
  # @param chars [Integer] if set, return only the first `chars` characters (actual text returned may be slightly longer).
  # @return [String] the plain text or basic HTML summary of that page
  def summary(term, html: false, sentences: 0, chars: 0)

    # get auto_suggest
    term = check_page(term)

    query_params = {
      'redirects': '',
      'prop': 'extracts',
      'titles': term
    }

    if !html
      query_params['explaintext'] = ''
    end

    if sentences
      query_params[:exsentences] = (sentences > 10 ? 10 : sentences).to_s
    elsif chars
      query_params[:exchars] = chars.to_s
    else
      query_params[:exintro] = ''
    end

    raw_results = fetch(query_params)

    if raw_results['query']['pages'].length > 1
      raise WikipediaWrapper::MultiplePagesError.new(term, [raw_results['query']['pages'].map { |p, info| info['title']}])
    elsif raw_results['query']['pages'].length < 1
      raise WikipediaWrapper::PageError.new(term)
    else
      id, info = raw_results['query']['pages'].first
      summary = info['extract']
    end

    return summary
  end


  # Do a Wikipedia search for the given term
  #
  # @param limit [Integer] the maxmimum number of results returned
  # @param suggestion [Boolean] set to true if you want an autocorrect suggestion
  # @return [{String => String}] if suggestion is false, return a Hash of the suggestions
  #   (as keys) and a snippet of the search result as values
  # @return [Array<{String => String}, <String, nil>>] if suggestion is true,
  #   return return a Hash of the suggestions
  #   (as keys) and a snippet of the search result as values in the first position of
  #   the array and in the second position a proposed suggestion or nil if there
  #   was no suggestion
  def search(term, limit: 10, suggestion: false)

    search_params = {
      'list': 'search',
      'srprop': 'snippet',
      'srlimit': limit.to_s,
      'srsearch': term
    }

    raw_results = fetch(search_params)

    results = {}

    raw_results['query']['search'].each do |sr|
      results[sr['title']] = sr['snippet'].gsub(/<span .*>(?<term>[^<]*)<\/span>/, '\k<term>')
    end

    if suggestion
      s = raw_results['query']['searchinfo'].key?('suggestion') ? raw_results['query']['searchinfo']['suggestion'] : nil
      return [results, s]
    else
      return results
    end

  end

  # Get an autocomplete suggestions for the given term. The term will be used
  # as a prefix.

  # @see https://www.mediawiki.org/wiki/API:Opensearch MediaWiki API
  # @raise [WikipediaWrapper::FormatError] if an unknown format is encountered in the response
  # @param term [String] the term to get the autocompletions for (used as a prefix)
  # @param limit [Integer]  the maximum number of results to return (may not exceed 100)
  # @param redirect [Boolean] whether redirects should be followed for suggestions
  # @return [Hash{String=>String}] a hash where the keys are the titles of the articles and
  #   the values are a short description of the page
  def autocomplete(term, limit: 10, redirect: true)

    query_params = {
      'action': 'opensearch',
      'search': term,
      'redirects': redirect ? 'resolve' : 'return',
      'limit': (limit > 100 ? 100 : limit).to_s
    }

    raw_results = fetch(query_params)

    if raw_results.length != 4
      raise WikipediaWrapper::FormatError.new("autocomplete", "array had length of #{raw_results.length} instead of 4")
    end

    num_suggestions = raw_results[1].length - 1

    results = {}
    for i in 0..num_suggestions
      results[raw_results[1][i]] = raw_results[2][i]
    end

    return results

  end



  # Function to determine whether there is a page with that term. It uses
  # the search and suggestion functionality to find a possible match
  # and raises a PageError if no page could be found.
  #
  # @todo Deal with Disambiguation Pages
  # @raise [WikipediaWrapper::PageError] if no page with that term could be found
  # @param term [String] the term for which we want a page
  # @return [String] the actual title of the page
  def check_page(term)

    results, suggestion = search(term, limit: 1, suggestion: true)
    if !suggestion.nil?
      return suggestion
    elsif results.length == 1
      title, snippet = results.first
      return title
    else
      raise WikipediaWrapper::PageError.new(term)
    end

    # FIXME: Deal with Disambiguation

  end


  # Given the request parameters, params, fetch the response from the API URL
  # and parse it as JSON. Raise an InvalidRequestError if an error occurrs.
  #
  # @raise [WikipediaWrapper::InvalidRequestError] if the request was invalid
  #   or another error occurrs
  # @param params [Hash{Symbol => String}] hash of the properties that should
  #   be added to the request URL
  # @return [Hash] the JSON response of the server converted in to a hash
  def fetch(params)

    # if no action is defined, set it to 'query'
    if !params.key?(:action)
      params[:action] = 'query'
    end

    params[:format] = 'json' # always return json format

    # FIXME: deal with continuation
    #params[:continue] = '' # does not work for autocomplete

    query_part = params.map { |k, v| v.empty? ? "#{k}" : "#{k}=#{v}" }.join("&")
    endpoint_url = URI.encode("#{config.api_url}?#{query_part}")

    raw_results = cache.fetch(endpoint_url) {
      f = open(endpoint_url, "User-Agent" => config.user_agent)
      JSON.parse(f.read)
    }

    #
    if params[:action] != 'opensearch' && raw_results.key?('error')
      raise WikipediaWrapper::InvalidRequestError.new(endpoint_url, raw_results['error']['info'])
    end

    return raw_results

  end

end
