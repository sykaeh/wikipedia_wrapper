module WikipediaWrapper

  class Configuration
    attr_accessor :lang, :api_url, :user_agent, :default_ttl

    # Initialize the configuration with some sensible defaults
    def initialize
      @lang = 'en'
      @api_url = "http://#{@lang}.wikipedia.org/w/api.php"
      @user_agent = 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1'
      @default_ttl = 7*24*60*60
    end

    # Reset the configuration to the initial state with the default parameters
    def reset
      @lang = 'en'
      @api_url = "http://#{@lang}.wikipedia.org/w/api.php"
      @user_agent = 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1'
      @default_ttl = 7*24*60*60
    end

  end

end
