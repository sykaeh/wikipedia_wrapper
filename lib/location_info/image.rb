module LocationInfo

  class Image

    attr_reader :name, :url, :source, :width, :height, :mime # makes attributes readable

    def initialize(url, source, data = {})

      @source = source
      @url = url

      @name = data[:name] || ''
      @mime = data[:mime] || ''
      @height = data[:height] || 0
      @width = data[:width] || 0

    end

  end

end
