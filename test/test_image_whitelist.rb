require 'minitest/autorun'
require 'wikipedia_wrapper/image_whitelist'

class ImageWhitelistTest < Minitest::Test
  def test_basic_file
    a = WikipediaWrapper::ImageWhitelist.is_whitelisted? ('File: Sixteen Chapel.jpg')
    refute a
  end

  def test_complete_whitelisted_file
    a = WikipediaWrapper::ImageWhitelist.is_whitelisted? ('File:Commons-logo.svg')
    assert a
  end

  def test_partial_whitelisted_file
    a = WikipediaWrapper::ImageWhitelist.is_whitelisted? ('File:Arms of San Marino.svg' )
    assert a
  end
end
