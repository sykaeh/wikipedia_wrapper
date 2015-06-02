require 'minitest/autorun'
require 'wikipedia_wrapper'

class WikipediaWrapperTest < Minitest::Test

  def setup
    WikipediaWrapper.cache.clear
  end

  def test_disambiguation
    assert_raises WikipediaWrapper::DisambiguationError do
      wiki_page = WikipediaWrapper.summary('Georgia')
    end
  end

  def test_basic_plaintext_intro

    summary = WikipediaWrapper.summary('Earth')
    refute_empty summary
    assert summary.start_with? ('Earth, also called the world and,')

  end

  def test_basic_plaintext_sentences

    summary = WikipediaWrapper.summary('Earth', sentences: 5)
    assert_equal "Earth, also called the world and, less frequently, Gaia (and Terra in some works of science fiction) is the third planet from the Sun, the densest planet in the Solar System, the largest of the Solar System's four terrestrial planets, and the only astronomical object known to accommodate life. The earliest life on Earth arose at least 3.5 billion years ago. Earth's biodiversity has expanded continually except when interrupted by mass extinctions. Although scholars estimate that over 99 percent of all species, amounting to over five billion species, that ever lived on the planet are extinct, Earth is currently home to 10–14 million species of life, of which about 1.2 million have been documented and over 90 percent await description. Over 7.3 billion humans depend upon its biosphere and minerals.", summary

  end

  def test_basic_plaintext_chars

    summary = WikipediaWrapper.summary('Earth', chars: 300)
    assert_equal "Earth, also called the world and, less frequently, Gaia (and Terra in some works of science fiction) is the third planet from the Sun, the densest planet in the Solar System, the largest of the Solar System's four terrestrial planets, and the only astronomical object known to accommodate life.", summary

  end

  def test_basic_html_intro

    summary = WikipediaWrapper.summary('Toronto', html: true)
    refute_empty summary
    assert summary.start_with? ('<p><b>Toronto</b> (<span><span')

  end

  def test_basic_html_sentences

    summary = WikipediaWrapper.summary('Toronto', html: true, sentences: 5)
    assert_equal "<p><b>Toronto</b> (<span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"/\u0275/ variable 1st 'o' in 'omission'\">\u0275</span></span><span><span title=\"/\u02c8/ primary stress follows\">\u02c8</span></span><span><span title=\"'r' in 'rye'\">r</span></span><span><span title=\"/\u0252/ short 'o' in 'body'\">\u0252</span></span><span><span title=\"'n' in 'nigh'\">n</span></span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"/o\u028a/ long 'o' in 'bode'\">o\u028a</span></span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span></span>, <span><small>local</small> <span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span><span><span title=\"/\u02c8/ primary stress follows\">\u02c8</span></span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"'r' in 'rye'\">r</span></span><span><span title=\"/\u0252/ short 'o' in 'body'\">\u0252</span></span><span><span title=\"'n' in 'nigh'\">n</span></span><span><span title=\"/o\u028a/ long 'o' in 'bode'\">o\u028a</span></span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span></span>) is the most populous city in Canada, and the capital of the province of Ontario. In 2011, Toronto had a population of 2,615,060, making it the fourth most populous city in North America, after Mexico City, New York City, and Los Angeles.</p>", summary

  end

  def test_basic_html_chars

    summary = WikipediaWrapper.summary('Toronto', html: true, chars: 300)
    assert_equal "<p><b>Toronto</b> (<span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"/ɵ/ variable 1st 'o' in 'omission'\">ɵ</span></span><span><span title=\"/ˈ/ primary stress follows\">ˈ</span></span><span><span title=\"'r' in 'rye'\">r</span></span><span><span title=\"/ɒ/ short 'o' in 'body'\">ɒ</span></span><span><span title=\"'n' in 'nigh'\">n</span></span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"/oʊ/ long 'o' in 'bode'\">oʊ</span></span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span></span>, <span><small>local</small> <span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span><span><span title=\"/ˈ/ primary stress follows\">ˈ</span></span><span><span title=\"'t' in 'tie'\">t</span></span><span><span title=\"'r' in 'rye'\">r</span></span><span><span title=\"/ɒ/ short 'o' in 'body'\">ɒ</span></span><span><span title=\"'n' in 'nigh'\">n</span></span><span><span title=\"/oʊ/ long 'o' in 'bode'\">oʊ</span></span><span title=\"Representation in the International Phonetic Alphabet (IPA)\">/</span></span>) is the most populous city in Canada, and the capital of the province of Ontario.</p>", summary

  end

end
