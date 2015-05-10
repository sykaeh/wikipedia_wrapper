# WikipediaWrapper.configure do |config|
#   config.api_key = 'dfskljkf'
# end

module WikipediaWrapper

  class Configuration
    attr_accessor :lang, :api_url, :user_agent, :img_width, :img_height, :default_ttl

    def initialize
      @lang = 'en'
      @api_url = "http://#{@lang}.wikipedia.org/w/api.php"
      @user_agent = 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1'
      @img_width = 200
      @img_height = nil
      @default_ttl = 7*24*60*60
    end

    def reset
      @lang = 'en'
      @api_url = "http://#{@lang}.wikipedia.org/w/api.php"
      @user_agent = 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1'
      @img_width = 200
      @img_height = nil
      @default_ttl = 7*24*60*60
    end

  end

end
