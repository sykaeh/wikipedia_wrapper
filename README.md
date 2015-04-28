LocationInfo
========

LocationInfo is a ruby gem that extracts information about a particular place and makes it available in multiple different formats. Currently the following features are available:

* Wikipedia introduction text & all images associated with the page using the [Wikipedia/MediaWiki API](https://en.wikipedia.org/w/api.php)
* Geocoding information as provided by [geocoder](https://github.com/alexreisner/geocoder)
* Other images from [Flickr](http://flickr.com)



Compatibility
-------------

* Supports multiple Ruby versions: Ruby 1.9.3, 2.0.x, 2.1.x, JRuby, and Rubinius.
* Supports Rails 3 and 4.



Installation
------------

Install LocationInfo like any other Ruby gem:

    gem install location_info

Or, if you're using Rails/Bundler, add this to your Gemfile:

    gem 'location_info'

and run at the command prompt:

    bundle install


Usage
------------

More examples can be found in the examples directory.


Tests
------------

LocationInfo comes with a test suite (just run rake test).


License
-----------

Copyright (c) 2015 Sybil Ehrensberger, released under the MIT license
