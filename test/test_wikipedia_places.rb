require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test

  def test_wikipedia_wrapper_config

    WikipediaWrapper.set('img_width', 500)
    assert_equal 500, WikipediaWrapper.get('img_width')

  end


  def test_integration
    wiki_page = WikipediaWrapper.find('Opfikon', 'Switzerland')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end

  def test_integration_2
    wiki_page = WikipediaWrapper.find('San Francisco', 'United States of America')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end


end
