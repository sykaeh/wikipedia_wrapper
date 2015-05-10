module WikipediaWrapper

  class Page

    attr_reader :title, :revision_time, :url, :extract
    attr_accessor :images

    def initialize(page_info)

      # TODO: handle problems!
      @raw = page_info
      @page_id = page_info['pageid']
      @title = page_info['title']
      @revision_time = page_info['touched'] #FIXME: parse in to date & time, format: 2015-04-23T07:20:47Z
      @revision_id = page_info['lastrevid']
      @url = page_info['fullurl']
      @extract = (page_info.key? 'extract') ? page_info['extract'] : ''

      @images = []

    end

    def image_filenames

      if @raw['images'].nil? # deal with the case that a page has no images
        []
      else
        @raw['images'].map {|img_info| img_info['title']}.compact
      end

    end

    def to_s
      # TODO: Implement!
    end

  end

end
