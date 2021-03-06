require 'wikipedia_wrapper/exception'
require 'wikipedia_wrapper/image'
require 'wikipedia_wrapper/util'

module WikipediaWrapper

  class Page

    attr_reader :title, :revision_time, :url, :extract

    def initialize(term, redirect: true)

      @term = term
      @redirect = redirect
      @images = nil
      @img_width = WikipediaWrapper.config.img_width
      @img_height = WikipediaWrapper.config.img_height

      # FIXME: Deal with continuation

      # FIXME: deal with redirect false!
      load_page

    end

    def to_s
      "Wikipedia Page: #{@title} (#{@url}), revid: #{@revision_id}, revtime: #{@revision_time}"
    end

    def categories
      # FIXME: Implement!
    end

    # Retrieve image info for all given image filenames, except for the images in the whitelist
    # See {http://www.mediawiki.org/wiki/API:Imageinfo}
    #
    # @param width [Integer] optional width of the smaller image (in px)
    # @param height [Integer] optional height of the smaller image (in px)
    # @note Only one of width and height can be used at the same time. If both are defined, only width is used.
    # @return [Array<WikipediaWrapper::WikiImage>] list of images
    def images(width: nil, height: nil)

      # if we haven't retrieved any images or the width or height have changed, re-fetch
      if @images.nil? || (!width.nil? && @img_width != width) || (!width.nil? && @img_width != width)

        unless width.nil?
          @img_width = width
        end

        unless height.nil?
          @img_height = height
        end

        @images = []

        # deal with the case that a page has no images
        if @raw['images'].nil?
          return @images
        end

        filenames = @raw['images'].map {|img_info| img_info['title']}.compact

        if filenames.empty? # there are no filenames, return an empty array
          return @images
        end

        # exclude whitelisted filenames
        filenames = filenames.map { |f| WikipediaWrapper.config.image_allowed?(f) ? f : nil }.compact

        query_parameters = {
          'titles': filenames.join('|'),
          'redirects': '',
          'prop': 'imageinfo',
          'iiprop': 'url|size|mime',
        }

        if (!@img_width.nil?)
          query_parameters[:iiurlwidth] = @img_width.to_s
        elsif (!@img_height.nil?)
          query_parameters[:iiurlheight] = @img_height.to_s
        end

        raw_results = WikipediaWrapper.fetch(query_parameters)

        # check if the proper format is there
        if raw_results.key?('query') && raw_results['query'].key?('pages')
          raw_results['query']['pages'].each do |k, main_info|
            begin
              wi = WikiImage.new(main_info)
              @images.push(wi)
            rescue WikipediaWrapper::FormatError => e
              puts e.message
            end
          end
        end

      end

      return @images

    end


    private

    def load_page

      query_parameters = {
        'prop': 'revisions|info|extracts|images|pageprops',
        'titles': @term,
        'redirects': '',
        'rvprop': 'content',
        'inprop': 'url',
        'exintro': '',
        'ppprop': 'disambiguation',
      }

      raw_results = WikipediaWrapper.fetch(query_parameters)
      WikipediaWrapper.check_results(@term, raw_results)

      key, page_info = raw_results['query']['pages'].first
      @raw = page_info

      @page_id = page_info['pageid']
      @title = page_info['title']
      @revision_time = page_info['touched'] #FIXME: parse in to date & time, format: 2015-04-23T07:20:47Z
      @revision_id = page_info['lastrevid']
      @url = page_info['fullurl']
      @extract = (page_info.key? 'extract') ? page_info['extract'] : ''

    end

  end

end
