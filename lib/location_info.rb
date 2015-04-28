require 'location_info/image'
require 'location_info/wikipedia'

module LocationInfo

  # class functions

  def self.wikipedia(query)
    w = Wikipedia.new()
    wiki_page = w.find(query)
  end

  def self.geocoder(query)
    'not implemented' # FIXME: implement!
  end


  def self.flickr(query)
    'not implemented' #FIXME: implement!
  end

end
