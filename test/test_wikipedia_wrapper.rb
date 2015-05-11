require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test

  def test_wikipedia_wrapper_config

    # Default config
    assert_equal nil, WikipediaWrapper.config.img_height

    # Config from config block
    WikipediaWrapper.configure do |config|
      config.img_height = 600
    end
    assert_equal 600, WikipediaWrapper.config.img_height

    # Test resetting of config
    WikipediaWrapper.config.reset
    assert_equal nil, WikipediaWrapper.config.img_height

    # Test setting config properties directly
    WikipediaWrapper.config.img_height = 700
    assert_equal 700, WikipediaWrapper.config.img_height

    # Overwrite config with a config block
    WikipediaWrapper.configure do |config|
      config.img_height = 600
    end
    assert_equal 600, WikipediaWrapper.config.img_height

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

  def test_integration_3
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
