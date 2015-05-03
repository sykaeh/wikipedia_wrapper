require 'minitest/autorun'
require 'wikipedia_places'

class WikipediaPlacesTest < Minitest::Test

  def test_wikipedia_places_config

    WikipediaPlaces.set('img_width', 500)
    assert_equal 500, WikipediaPlaces.get('img_width')

  end


  def test_integration
    wiki_page = WikipediaPlaces.find('Opfikon', 'Switzerland')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end

  def test_integration_2
    wiki_page = WikipediaPlaces.find('San Francisco', 'United States of America')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end


end
