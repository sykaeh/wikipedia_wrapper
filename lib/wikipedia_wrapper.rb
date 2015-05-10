require 'uri'
require 'open-uri'
require 'json'
require 'cache'
require 'wikipedia_wrapper/exception'
require 'wikipedia_wrapper/configuration'
require 'wikipedia_wrapper/image'
require 'wikipedia_wrapper/page'
require 'wikipedia_wrapper/image_whitelist'

module WikipediaWrapper

  extend self

  def config
    @config ||= Configuration.new
  end

  def configure
    @config ||= Configuration.new
    yield(config)
  end

  def cache
    if @cache.nil?
      @cache = Cache.new
      @cache.config.default_ttl = config.default_ttl
    end
    @cache
  end

  def cache=(raw_client, timeout: config.default_ttl)
    @cache = Cache.wrap(raw_client)
    @cache.config.default_ttl = timeout
  end


  def basic_page(search_term)

  end

  # Deal with disambig sites
  # Possibly use https://www.mediawiki.org/wiki/API:Opensearch
  def page(search_term)

    query_parameters = {
      'prop': 'revisions|info|extracts|images',
      'titles': search_term,
      'redirects': '',
      'rvprop': 'content',
      'inprop': 'url',
      'exintro': '',
    }

    raw_results = fetch(query_parameters)

    if raw_results['query']['pages'].length > 1
      raise MultiplePagesError
    end

    if raw_results['query']['pages'].length == 0
      raise PageError
    end

    page = nil
    raw_results['query']['pages'].each do |key, value|
      page = Page.new(value)
    end

    # FIXME: attach images
    page.images = images(page.image_filenames).map { |img| img.error.nil? ? img : nil }.compact

    return page

  end

  # Plain text or basic HTML summary of the page.
  #
  # @note This is a convenience wrapper - auto_suggest and redirect are enabled by default
  #
  # @param sentences [Integer] if set, return the first `sentences` sentences (can be no greater than 10).
  # @param chars [Integer] if set, return only the first `chars` characters (actual text returned may be slightly longer).
  # @param auto_suggest [Boolean] let Wikipedia find a valid page title for the query
  # @param redirect [Boolean] allow redirection without raising RedirectError
  def summary(title, sentences: 0, chars: 0, auto_suggest: true, redirect: true)

    # use auto_suggest and redirect to get the correct article
    # also, use page's error checking to raise DisambiguationError if necessary
    page_info = page(title, auto_suggest=auto_suggest, redirect=redirect)
    title = page_info.title
    pageid = page_info.pageid

    query_params = {
      'prop': 'extracts',
      'explaintext': '',
      'titles': title
    }

    if sentences
      query_params[:exsentences] = sentences
    elsif chars
      query_params[:exchars] = chars
    else
      query_params[:exintro] = ''
    end

    raw_results = fetch(query_params)
    #request = _wiki_request(query_params)
    #summary = request['query']['pages'][pageid]['extract']

    #return summary
  end


  # Do a Wikipedia search for `query`.
  #
  # @param limit [Integer] the maxmimum number of results returned
  # @return
  def search(query, limit: 10)

    search_params = {
      'list': 'search',
      'srprop': 'snippet',
      'srlimit': limit.to_s,
      'srsearch': query
    }

    raw_results = fetch(search_params)
    # FIXME: do proper error handling
    # if 'error' in raw_results:
    #   if raw_results['error']['info'] in ('HTTP request timed out.', 'Pool queue is full'):
    #     raise HTTPTimeoutError(query)
    #   else:
    #     raise WikipediaException(raw_results['error']['info'])

    results = {}
    raw_results['query']['search'].each do |sr|
      results[sr['title']] = sr['snippet'].gsub(/<span .*>(?<term>[^<]*)<\/span>/, '\k<term>')
    end

    return results

  end

  # Get an autocomplete suggestions for the given query. The query will be used
  # as a prefix. This function uses https://www.mediawiki.org/wiki/API:Opensearch
  #
  # @param query [String] the term to get the autocompletions for (used as a prefix)
  # @param limit [Integer]  the maximum number of results to return (may not exceed 100)
  # @param redirect [Boolean] whether redirects should be followed for suggestions
  # @return hash of  {'title' => 'description'}
  def autocomplete(query, limit: 10, redirect: true)

    query_params = {
      'action': 'opensearch',
      'search': query,
      'redirects': redirect ? 'resolve' : 'return',
      'limit': (limit > 100 ? 100 : limit).to_s
    }

    raw_results = fetch(query_params)

    if raw_results.length != 4
      raise WikipediaWrapper::WikipediaError.new("Wrong format for autocomplete: array had length of #{raw_results.length} instead of 4")
    end

    num_suggestions = raw_results[1].length - 1

    results = {}
    for i in 0..num_suggestions
      results[raw_results[1][i]] = raw_results[2][i]
    end

    return results

  end


  # Retrieve image info for all given image filenames, except for the images in the whitelist
  # See {http://www.mediawiki.org/wiki/API:Imageinfo}
  #
  # @param filenames [Array<String>] list of all filenames
  # @param width [Integer] optional width of the smaller image (in px)
  # @param height [Integer] optional height of the smaller image (in px)
  # @note Only one of width and height can be used at the same time. If both are defined, only width is used.
  # @return [Array<WikipediaWrapper::WikiImage>] list of images
  def images(filenames, width: nil, height: nil)

    images = []

    if filenames.empty? # there are no filenames, return an empty array
      return images
    end

    filenames = filenames.map { |f| (ImageWhitelist.is_whitelisted? f)  ? nil : f }.compact

    query_parameters = {
      'titles': filenames.join('|'),
      'redirects': '',
      'prop': 'imageinfo',
      'iiprop': 'url|size|mime',
    }

    if (!width.nil?)
      query_parameters[:iiurlwidth] = width
    elsif (!height.nil?)
      query_parameters[:iiurlheight] = height
    end

    raw_results = fetch(query_parameters)

    # check if the proper format is there
    if raw_results.key?('query') && raw_results['query'].key?('pages')
      raw_results['query']['pages'].each do |k, main_info|

        wi = WikiImage.new(main_info)
        if wi.error.nil?
          images.push(wi)
        end

      end
    end

    return images

  end

  private

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
    puts endpoint_url

    cache.fetch(endpoint_url) {
      f = open(endpoint_url, "User-Agent" => config.user_agent)
      JSON.parse(f.read)
    }

  end

end
