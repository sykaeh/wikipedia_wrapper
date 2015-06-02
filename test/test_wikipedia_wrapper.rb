require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test

  def setup
    WikipediaWrapper.cache.clear
  end

  def test_disambiguation
    assert_raises WikipediaWrapper::DisambiguationError do
      wiki_page = WikipediaWrapper.page('Georgia')
    end
  end

  def test_integration
    wiki_page = WikipediaWrapper.page('Opfikon')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end

  def test_integration_2
    wiki_page = WikipediaWrapper.page('San Francisco')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end

  def test_integration_3 # uses the check_page (since it would be Yverdon, not Yverdons)
    wiki_page = WikipediaWrapper.page('Yverdons')
    refute_nil wiki_page
    refute_empty wiki_page.images
  end

  def test_error_fetch
    test_params = {'action': 'blah'}

    assert_raises WikipediaWrapper::InvalidRequestError do
      WikipediaWrapper::fetch(test_params)
    end

  end


end
