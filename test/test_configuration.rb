require 'minitest/autorun'
require 'wikipedia_wrapper'
require 'wikipedia_wrapper/exception'

class ConfigurationTest < Minitest::Test

  def setup
    # make sure the state is as expected
    WikipediaWrapper.config.reset
  end

  # General config tests
  def test_different_methods

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


  # tests with the default image configuration

  def test_default_allowed
    a = WikipediaWrapper.config.image_allowed? ('File: Sixteen Chapel.jpg')
    assert a
  end

  def test_default_blocked_ending
    a = WikipediaWrapper.config.image_allowed? ('File:Commons-logo.svg')
    refute a
  end

  def test_default_blocked_filename
    a = WikipediaWrapper.config.image_allowed? ('File:Edit-clear.svg')
    refute a
  end

  # tests loading custom image config file

  def test_invalid_path
    random = 'f2d9pN4QlyLpvaGQHHyy'
    assert_raises(WikipediaWrapper::ConfigurationError) {
      WikipediaWrapper.config.image_restrictions = random
    }
  end

  def test_invalid_syntax
    fname = File.expand_path(File.dirname(__FILE__)) + '/image_restrictions_syntax_error.yaml'
    assert_raises(WikipediaWrapper::ConfigurationError) {
      WikipediaWrapper.config.image_restrictions = fname
    }
  end

  def test_set_custom_file

    WikipediaWrapper.config.image_restrictions = File.expand_path(File.dirname(__FILE__)) + '/image_restrictions_custom.yaml'

    endings = WikipediaWrapper.config.image_restrictions['allowed_endings']
    assert_equal ['.txt'], endings

    exclude_files = WikipediaWrapper.config.image_restrictions['exclude_files']
    assert_equal ['myfile.txt', 'otherfile.txt', 'spaced file.txt'], exclude_files

    exclude_partials = WikipediaWrapper.config.image_restrictions['exclude_partials']
    assert_equal ['something'], exclude_partials

    a = WikipediaWrapper.config.image_allowed? ('spaced file.txt')
    refute a

    a = WikipediaWrapper.config.image_allowed? ('filesomething.txt')
    refute a

    a = WikipediaWrapper.config.image_allowed? ('File:Edit-clear.svg')
    refute a

  end

  def test_empty_endings

    WikipediaWrapper.config.image_restrictions = File.expand_path(File.dirname(__FILE__)) + '/image_restrictions_empty.yaml'

    endings = WikipediaWrapper.config.image_restrictions['allowed_endings']
    assert_equal nil, endings

    exclude_files = WikipediaWrapper.config.image_restrictions['exclude_files']
    assert_equal nil, exclude_files

    exclude_partials = WikipediaWrapper.config.image_restrictions['exclude_partials']
    assert_equal nil, exclude_partials

    a = WikipediaWrapper.config.image_allowed? ('File:Edit-clear.svg')
    assert a

  end

end
