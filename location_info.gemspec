# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'date'
require 'location_info/version'

Gem::Specification.new do |s|
  s.name        = 'location_info'
  s.version     = LocationInfo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today.to_s
  s.summary     = "LocationInfo retrieves information about a place from the world wide web"
  s.description = "A simple hello world gem"
  s.authors     = ["Sybil Ehrensberger"]
  s.email       = 'contact@sybil-ehrensberger.com'
  s.files       = ["lib/location_info.rb", "lib/location_info/image.rb", "lib/location_info/wikipedia.rb"]
  s.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'examples/*', 'lib/**/*', 'bin/*']
  s.require_paths = ["lib"]
  s.homepage    =
    'http://sybil-ehrensberger.com'
  s.license       = 'MIT'
  s.add_runtime_dependency 'geocoder', '~> 1.1', '>= 1.1.4'
end
