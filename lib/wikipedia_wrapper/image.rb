require 'wikipedia_wrapper/exception'

module WikipediaWrapper

  class WikiImage

    attr_accessor :small, :normal

    def initialize(raw_info)

      @small = nil
      @normal = nil

      if !raw_info.key?('imageinfo') || raw_info['imageinfo'].length != 1
        raise WikipediaWrapper::FormatError.new('WikiImage initialize', "Unknown format for imageinfo: #{raw_info}")
      end

      @filename = (raw_info.key? 'title') ? raw_info['title'].sub('File:', '') : 'No name'

      data = {
        'name': @filename,
        'mime': raw_info['imageinfo'][0]['mime'],
      }



      @normal = Image.new(raw_info['imageinfo'][0]['url'],
                         raw_info['imageinfo'][0]['width'].to_i,
                         raw_info['imageinfo'][0]['height'].to_i, data)


      if raw_info['imageinfo'][0].key? ('thumburl')
        @small = Image.new(raw_info['imageinfo'][0]['thumburl'],
                                 raw_info['imageinfo'][0]['thumbwidth'].to_i,
                                 raw_info['imageinfo'][0]['thumbheight'].to_i,
                                 data)
      else
        @small = @normal
      end

    end

    def to_s
      "WikiImage #{@filename}"
    end

  end

  class Image

    attr_reader :name, :url, :width, :height, :mime # makes attributes readable

    def initialize(url, width, height, data)

      @url = url
      @name = data[:name] || ''
      @mime = data[:mime] || ''
      @height = data[:height] || 0
      @width = data[:width] || 0

    end

    def to_s
      "Image: #{@name} (#{@url})"
    end

  end

end
