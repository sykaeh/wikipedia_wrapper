require 'wikipedia_wrapper/image'
require 'wikipedia_wrapper/fetcher'

module WikipediaWrapper

  @@configuration = {
    :lang => 'en',
    :user_agent => 'WikipediaWrapper/0.1 (http://sykaeh.github.com/wikipedia_wrapper/; wikipedia_wrapper@sybil-ehrensberger.com) Ruby/2.2.1', :img_width => 200,
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

  def self.find(search_term)
    f = Fetcher.new(@@configuration)

    wiki_page = f.page(search_term)
    wiki_page.images = f.images(wiki_page.image_filenames).map { |img| img.error.nil? ? img : nil }.compact

    return wiki_page

  end

end
