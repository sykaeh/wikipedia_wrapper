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

  def test_autocomplete

    results = WikipediaWrapper.autocomplete('api', limit: 3)

    assert_equal 3, results.length
    assert results.key? 'Application programming interface'
    assert results.key? 'Apia'
    assert results.key? 'Apink'

    assert_equal 'In computer programming, an application programming interface (API) is a set of routines, protocols, and tools for building software applications.', results['Application programming interface']
    assert_equal 'Apia is the capital and the largest city of Samoa. From 1900 to 1919, it was the capital of the German Samoa.', results['Apia']

  end

  def test_search

    results = WikipediaWrapper.search('api', limit: 15)
    puts results

  end


end
