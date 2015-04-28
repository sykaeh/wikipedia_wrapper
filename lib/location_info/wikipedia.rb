require 'uri'
require 'open-uri'
require 'json'
require 'location_info/image'

module LocationInfo

  class Wikipedia

    #attr_reader :page_info # makes attributes readable
    # attr_writer :duration # makes attributes writeable

    def initialize(options = {})

      @language = options[:lang] || 'en'
      @api_url = options[:api_url] || "http://#{@language}.wikipedia.org/w/api.php?"

      @user_agent = options[:user_agent] || 'LocationInfo/0.1 (http://sykaeh.github.com/location_info/; location_info@sybil-ehrensberger.com) Ruby/2.2.1'

    end

    def find(search_term)

      # TODO: make search_term URL safe, i.e. escape spaces etc.

      url = "#{@api_url}action=query&prop=revisions|info|extracts|images&titles=#{search_term}&rvprop=content&inprop=url&exintro&format=json"

      f = open(URI.encode(url), "User-Agent" => @user_agent)
      query_result = JSON.parse(f.read)


      # FIXME: what to do with more than one?
      page = nil
      query_result['query']['pages'].each do |key, value|
        page = Wikipedia::Page.new(value)
        page.images += get_images(page.image_filenames)
      end

      return page

    end

    def get_images(filenames, width:nil, height:nil)

      # to get the image info and url: https://www.mediawiki.org/wiki/API:Imageinfo
      image_url = "#{@api_url}action=query&titles=#{filenames.join('|')}&prop=imageinfo&&iiprop=url|size|mime&format=json"

      if (!width.nil?)
        image_url += "iiurlwidth=#{width}"
      elsif (!height.nil?)
        image_url += "iiurlheight=#{height}"
      end

      f = open(URI.encode(image_url), "User-Agent" => @user_agent)
      query_result = JSON.parse(f.read)

      images = []
      query_result['query']['pages'].each do |k, main_info|

        data = {
          'title': main_info['title'],
          'mime': main_info['imageinfo'][0]['mime'],
          'width': main_info['imageinfo'][0]['width'].to_i,
          'height': main_info['imageinfo'][0]['height'].to_i,
        }

        images.push(Image.new(main_info['imageinfo'][0]['url'], 'Wikipedia', data))

      end

      return images


    end


  end


  class Wikipedia::Page

    attr_reader :images, :title, :revision_time, :url, :extract
    attr_writer :images

    def initialize(page_info)

      # TODO: handle problems!
      @raw = page_info
      @page_id = page_info['pageid']
      @title = page_info['title']
      @revision_time = page_info['touched'] #FIXME: parse in to date & time, format: 2015-04-23T07:20:47Z
      @revision_id = page_info['lastrevid']
      @url = page_info['fullurl']
      @extract = page_info['extract']

      @images = []

    end

    def image_filenames

      @raw['images'].map {|img_info| img_info['title'] }

    end

  end

end
