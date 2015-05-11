require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test


    def test_search

      results = WikipediaWrapper.search('api', limit: 15)

      assert_equal 15, results.length
      assert results.key?('Application programming interface')
      assert results.key?('HTML5 File API')
      assert_equal 'HTML5 File API for representing file objects in web applications and programmatic selection and accessing their data. In addition', results['HTML5 File API']

      assert results.key?('Windows API')
      assert_equal "The Windows APIs) available in the Microsoft Windows operating", results['Windows API']

    end

end
