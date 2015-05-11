require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test
  
    def test_autocomplete

      results = WikipediaWrapper.autocomplete('api', limit: 3)

      assert_equal 3, results.length
      assert results.key? 'Application programming interface'
      assert results.key? 'Apia'
      assert results.key? 'Apink'

      assert_equal 'In computer programming, an application programming interface (API) is a set of routines, protocols, and tools for building software applications.', results['Application programming interface']
      assert_equal 'Apia is the capital and the largest city of Samoa. From 1900 to 1919, it was the capital of the German Samoa.', results['Apia']

    end

end
