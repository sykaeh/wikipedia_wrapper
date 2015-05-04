require 'minitest/autorun'
require 'wikipedia_wrapper/Fetcher'

class FetcherTest < Minitest::Test


  def test_fetcher_config

    w = WikipediaWrapper::Fetcher.new({:lang => 'de', :user_agent => 'my custom user agent',
      :img_width => 700, :img_height => 200})

    assert_equal w.language, 'de'
    assert_equal w.api_url,  'http://de.wikipedia.org/w/api.php?'
    assert_equal w.user_agent, 'my custom user agent'
    assert_equal w.img_width, 700
    assert_equal w.img_height, 200

  end

end
