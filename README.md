# WikipediaWrapper
WikipediaWrapper is a ruby gem that extracts information from Wikipedia and makes the information available in an easy-to-use API.

All information is extracted using the [Wikipedia/MediaWiki API](https://en.wikipedia.org/w/api.php).

This gem is inspired by the [Python wrapper for the Wikipedia API](https://github.com/goldsmith/Wikipedia) by [Jonathan Goldsmith](https://github.com/goldsmith).

## Installation
Install WikipediaWrapper like any other Ruby gem:

```
gem install wikipedia_wrapper
```

Or, if you're using Rails/Bundler, add this to your Gemfile:

```
gem 'wikipedia_wrapper'
```

and run at the command prompt:

```
bundle install
```

## Usage
Before you can use the gem, you need to require it in your file:

```ruby
require 'wikipedia_wrapper'
```

The following are just some example usages. For detailed information, check the documentation.

### Configuration
To use this gem you do not need to specify configuration options, but you can. The values specified in the example below are the default values. It is however highly recommended that you choose a caching client and set that before making a lot of requests. The caching functionality is provided by the [cache gem](https://github.com/seamusabshere/cache). See it's documentation for more information on possible caching clients.

```ruby
WikipediaWrapper.configure do |config|
  config.api_key = 'http://en.wikipedia.org/w/api.php'
  config.user_agent = 'WikipediaWrapper/0.0.1 (http://sykaeh.github.com/wikipedia_wrapper/) Ruby/2.2.1'
  config.default_ttl = 604800
end

WikipediaWrapper.cache(Memcached.new('127.0.0.1:11211', :binary_protocol => true)) # or
WikipediaWrapper.cache(Dalli::Client.new) # or
WikipediaWrapper.cache(Redis.new) # or
WikipediaWrapper.cache(Rails.new)
```

### Autocomplete suggestions
Autocomplete suggestions are the suggestions you get when you start typing a word in the search box on the page. You get the complete title for each page and a short summary. You can specify a limit with the keyword argument `limit` (default is 10).

```ruby
WikipediaWrapper.autocomplete('api', limit: 3)
# returns => { "Application programming interface"=>"In computer programming, an application programming interface (API) is a set of routines, protocols, and tools for building software applications.",
# "Apia"=>"Apia is the capital and the largest city of Samoa. From 1900 to 1919, it was the capital of the German Samoa.",
# "Apink"=>"Apink (Korean: 에이핑크, Japanese: エーピンク; also written A Pink) is a South Korean girl group formed by A Cube Entertainment in 2011. The group consists of Park Cho-rong, Yoon Bo-mi, Jung Eun-ji, Son Na-eun, Kim Nam-joo and Oh Ha-young."}
```

### Search
Search does a full-text search of the term you provided, and returns the list of page titles that match and short snippets containing the search term.

```ruby
WikipediaWrapper.search('api', limit: 3)
# returns: => {"Application programming interface"=>"&quot;API In computer programming",
# "Web API"=>"For the Microsoft ASP.NET Web API) for both the web server and web",
# "Google Gadgets API"=>"Google Gadgets API which allows developers to create Google Gadgets easily.  Gadgets are mini-applications built in HTML, JavaScript,"}
```

### Summary
Summary is a convenience function to get the first couple of character, sentences of all of the text before the first section (introductory text) either in plain text or as basic HTML markup.

```ruby
WikipediaWrapper.summary('Ruby') # returns the intro text in plaintext
WikipediaWrapper.summary('Ruby', chars: 100) # returns the first 100 characters in plaintext
WikipediaWrapper.summary('Ruby', sentences: 10) # returns the first 10 sentences in plaintext
WikipediaWrapper.summary('Ruby', html: true) # returns the intro text in HTML
```

### Complete page
To get all of the information on a particular page, use the `page` convenience wrapper or use the `Page` class directly.

```ruby

page = WikipediaWrapper.page('Ruby')
# or directly:
page = WikipediaWrapper::Page.new('Ruby')

page.title # => "Ruby"
page.url # => "http://en.wikipedia.org/wiki/Ruby"
page.extract # => "<p>A <b>ruby</b> is a pink to blood-red colored gemstone, a variety of the mineral corundum (aluminium oxide). The red color is caused mainly by the presence of the element chromium. Its name comes from <i>ruber</i>, Latin for red. Other varieties of gem-quality corundum are called sapphires. Ruby is considered one of the four precious stones, together with sapphire, emerald and diamond.</p>\n<p>Prices of rubies are primarily determined by color. The brightest and most valuable \"red\" called blood-red, commands a large premium over other rubies of similar quality. After color follows clarity: similar to diamonds, a clear stone will command a premium, but a ruby without any needle-like rutile inclusions may indicate that the stone has been treated. Cut and carat (weight) are also an important factor in determining the price. Ruby is the traditional birthstone for July and is always lighter red or pink than garnet.</p>\n<p></p>"
```

## Tests
WikipediaWrapper comes with a test suite (just run rake test).

## License
Copyright (c) 2015 Sybil Ehrensberger, released under the MIT license
