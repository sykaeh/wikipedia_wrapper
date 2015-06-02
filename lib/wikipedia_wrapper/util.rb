require 'uri'
require 'open-uri'
require 'json'
require 'wikipedia_wrapper/exception'


module WikipediaWrapper


  # Given the request parameters, params, fetch the response from the API URL
  # and parse it as JSON. Raise an InvalidRequestError if an error occurrs.
  #
  # @raise [WikipediaWrapper::InvalidRequestError] if the request was invalid
  #   or another error occurrs
  # @param params [Hash{Symbol => String}] hash of the properties that should
  #   be added to the request URL
  # @return [Hash] the JSON response of the server converted in to a hash
  def self.fetch(params)

    # if no action is defined, set it to 'query'
    if !params.key?(:action)
      params[:action] = 'query'
    end

    params[:format] = 'json' # always return json format

    # FIXME: deal with continuation
    #params[:continue] = '' # does not work for autocomplete

    query_part = params.map { |k, v| v.empty? ? "#{k}" : "#{k}=#{v}" }.join("&")
    endpoint_url = URI.encode("#{WikipediaWrapper.config.api_url}?#{query_part}")

    raw_results = cache.fetch(endpoint_url) {
      f = open(endpoint_url, "User-Agent" => config.user_agent)
      JSON.parse(f.read)
    }

    if params[:action] != 'opensearch' && raw_results.key?('error')
      raise WikipediaWrapper::InvalidRequestError.new(endpoint_url, raw_results['error']['info'])
    end

    return raw_results

  end

  def self.check_results(term, raw_results)

    if raw_results['query']['pages'].length > 1
      raise WikipediaWrapper::MultiplePagesError.new(raw_results['query']['pages'].map { |p| p['title'] }, term)
    elsif raw_results['query']['pages'].length < 1
      raise WikipediaWrapper::PageError.new(term)
    end

    key, page_info = raw_results['query']['pages'].first
    if key == '-1'
      raise WikipediaWrapper::PageError.new(term)
    end

    # Check for disambiguation pages
    if page_info['pageprops'] && page_info['pageprops']['disambiguation']
      raise WikipediaWrapper::DisambiguationError.new(term)
    end

  end

end
