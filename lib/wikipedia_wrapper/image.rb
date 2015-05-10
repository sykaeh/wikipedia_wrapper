module WikipediaWrapper

  class WikiImage

    attr_accessor :error, :small, :normal

    def initialize(raw_info)

      @error = nil
      @small = nil
      @normal = nil

      if !raw_info.key?('imageinfo') || raw_info['imageinfo'].length != 1
        @error = "Unknown format for imageinfo: #{raw_info}"
        puts @error
        return
      end

      data = {
        'name': (raw_info.key? 'title') ? raw_info['title'].sub('File:', '') : 'No name',
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
