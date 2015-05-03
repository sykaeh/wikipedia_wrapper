require 'wikipedia_places/image'
require 'wikipedia_places/fetcher'

module WikipediaPlaces

  @@configuration = {
    :lang => 'en',
    :user_agent => 'WikipediaPlaces/0.1 (http://sykaeh.github.com/wikipedia_places/; wikipedia_places@sybil-ehrensberger.com) Ruby/2.2.1', :img_width => 200,
    :img_height => nil
  }

  def self.set(property_name, value)
    if property_name.is_a? String
      property_name = property_name.to_sym
    end
    @@configuration[property_name] = value
  end

  def self.get(property_name)
    if property_name.is_a? String
      property_name = property_name.to_sym
    end
    @@configuration[property_name]
  end


  # class functions

  def self.find(city, country)
    f = Fetcher.new(@@configuration)

    wiki_page = f.page("#{city}")
    wiki_page.images = f.images(wiki_page.image_filenames)

    return wiki_page

  end

end
