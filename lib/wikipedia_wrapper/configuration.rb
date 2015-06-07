require 'yaml'

module WikipediaWrapper

  class Configuration
    attr_accessor :lang, :user_agent, :default_ttl, :img_width, :img_height
    attr_reader :api_url

    # Initialize the configuration with some sensible defaults
    def initialize
      set_defaults
    end

    # Reset the configuration to the initial state with the default parameters
    def reset
      set_defaults
      @image_restrictions = nil
    end

    def lang=(lang_code)
      @lang = lang_code
      @api_url = "http://#{@lang}.wikipedia.org/w/api.php"
    end

    def image_restrictions
      if @image_restrictions.nil?
        self.image_restrictions = File.expand_path(File.dirname(__FILE__)) + '/default_image_restrictions.yaml'
      end
      @image_restrictions
    end

    def image_restrictions=(path)
      begin
        @image_restrictions = YAML.load_file(path)
      rescue Errno::ENOENT # No such file
        raise WikipediaWrapper::ConfigurationError.new("The file #{path} does not exist")
      rescue Psych::SyntaxError => e
        raise WikipediaWrapper::ConfigurationError.new("SyntaxError in the file #{path}: #{e}")
      end
    end

    def image_allowed?(filename)
      allowed_ending?(filename) && !blocked_filename?(filename) && !blocked_partial?(filename)
    end

    private

    def set_defaults
      self.lang = 'en'
      @user_agent = 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1'
      @default_ttl = 7*24*60*60
      @img_height = nil
      @img_width = nil
    end

    def allowed_ending?(filename)
      if self.image_restrictions['allowed_endings'].nil? # if there are no allowed_endings
        if self.image_restrictions['exclude_endings'].nil?
          return true
        end

        self.image_restrictions['exclude_endings'].each do |e|
          if filename.downcase.end_with?(e.downcase)
            return false
          end
        end
        return true
      else # if allowed_endings is specified
        self.image_restrictions['allowed_endings'].each do |e|
          if filename.downcase.end_with?(e.downcase)
            return true
          end
        end
        return false
      end
    end

    def blocked_partial?(filename)

      if self.image_restrictions['exclude_partials'].nil?
        return false
      end

      self.image_restrictions['exclude_partials'].each do |p|
        if filename.downcase.include? p.downcase
          return true
        end
      end

      return false
    end

    def blocked_filename?(filename)

      if self.image_restrictions['exclude_files'].nil?
        false
      else
        self.image_restrictions['exclude_files'].include? filename
      end
    end

  end

end
