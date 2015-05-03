module WikipediaPlaces

  class WikiImage

    attr_accessor :small, :normal

    def initialize(raw_info)

      if !raw_info.key?('imageinfo') || raw_info['imageinfo'].length < 1
        puts "Unknown format for imageinfo: #{raw_info}"
        @small = nil
        @normal = nil
        return
      end

      data = {
        'name': (raw_info.key? 'title') ? raw_info['title'] : 'No name',
        'mime': raw_info['imageinfo'][0]['mime'],
      }

      if raw_info['imageinfo'][0].key? ('thumburl')
        @small = Image.new(raw_info['imageinfo'][0]['thumburl'],
                                 raw_info['imageinfo'][0]['thumbwidth'].to_i,
                                 raw_info['imageinfo'][0]['thumbheight'].to_i,
                                 data)
      else
        @small = nil
      end

      @normal = Image.new(raw_info['imageinfo'][0]['url'],
                         raw_info['imageinfo'][0]['width'].to_i,
                         raw_info['imageinfo'][0]['height'].to_i, data)

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

  end

end
