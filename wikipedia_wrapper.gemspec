# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'date'
require 'wikipedia_wrapper/version'

Gem::Specification.new do |s|
  s.name        = 'wikipedia_wrapper'
  s.version     = WikipediaWrapper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today.to_s
  s.summary     = "WikipediaWrapper retrieves information about a place from Wikipedia"
  s.description = "A simple hello world gem"
  s.authors     = ["Sybil Ehrensberger"]
  s.email       = 'contact@sybil-ehrensberger.com'
  s.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'examples/*', 'lib/**/*', 'bin/*']
  s.require_paths = ["lib"]
  s.homepage    =
    'http://sybil-ehrensberger.com'
  s.license       = 'MIT'

  s.add_runtime_dependency("cache", '~> 0.4')
end
