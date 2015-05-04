require 'uri'
require 'open-uri'
require 'json'
require 'wikipedia_wrapper/image'
require 'wikipedia_wrapper/page'
require 'wikipedia_wrapper/image_whitelist'

module WikipediaWrapper

  class Fetcher

    attr_accessor :api_url, :language, :user_agent, :img_height, :img_width

    def initialize(config)

      @language = config[:lang]
      @api_url = config[:api_url] || "http://#{@language}.wikipedia.org/w/api.php?"

      @user_agent = config[:user_agent]

      @img_height = config[:img_height]
      @img_width = config[:img_width]

    end


    # Deal with disambig sites
    # Possibly use https://www.mediawiki.org/wiki/API:Opensearch
    def page(search_term)

      url = "#{@api_url}action=query&prop=revisions|info|extracts|images&" +
            "titles=#{search_term}&redirects&rvprop=content&inprop=url&exintro&format=json"

      puts URI.encode(url)
      f = open(URI.encode(url), "User-Agent" => @user_agent)
      query_result = JSON.parse(f.read)

      # FIXME: what to do with more than one?
      page = nil
      query_result['query']['pages'].each do |key, value|
        page = Page.new(value)
      end

      return page

    end


    # http://www.mediawiki.org/wiki/API:Imageinfo
    def images(filenames)

      images = []

      if filenames.empty? # there are no filenames, return an empty array
        return images
      end

      filenames = filenames.map { |f| (ImageWhitelist.is_whitelisted? f)  ? nil : f }.compact

      image_api_url = "#{@api_url}action=query&titles=#{filenames.join('|')}&" +
                  "redirects&prop=imageinfo&&iiprop=url|size|mime&format=json"

      if (!@img_width.nil?)
        image_api_url += "&iiurlwidth=#{@img_width}"
      elsif (!@img_height.nil?)
        image_api_url += "&iiurlheight=#{@img_height}"
      end

      puts URI.encode(image_api_url)

      f = open(URI.encode(image_api_url), "User-Agent" => @user_agent)
      query_result = JSON.parse(f.read)

      # check if the proper format is there
      if query_result.key?('query') && query_result['query'].key?('pages')
        query_result['query']['pages'].each do |k, main_info|

          images.push(WikiImage.new(main_info))

        end
      end

      return images

    end

  end

end
