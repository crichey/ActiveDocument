require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require 'ActiveDocument/search_result'
require 'rubygems'
require 'nokogiri'
class SearchResult_test < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  Snippet = "<corona:snippet>
<span class='match' path='/PLAY/TITLE'>The Tragedy of <span class='hit'>Antony</span> and Cleopatra</span> <span class='match' path='/PLAY/PERSONAE/PGROUP[2]/GRPDESCR'>friends to <span class='hit'>Antony</span>.</span> <span class='match' path='/PLAY/PERSONAE/PERSONA[3]'>CANIDIUS, lieutenant-general to <span class='hit'>Antony</span>.</span> <span class='match' path='/PLAY/PERSONAE/PERSONA[5]'>EUPHRONIUS, an ambassador from <span class='hit'>Antony</span> to Caesar.</span>
</corona:snippet>"
  Uri = "/books/a_and_c.xml"
  Confidence = 1
  Result = "<corona:result xmlns:corona='http://marklogic.com/corona'>#{Snippet}<corona:confidence>#{Confidence}</corona:confidence>
<corona:uri>#{Uri}</corona:uri>

</corona:result>"

  def setup
    @result = ActiveDocument::SearchResult.new(Nokogiri::XML(Result))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_length
    assert_equal(4, @result.length)
  end

  def test_uri
    assert_equal(Uri, @result.uri)
  end

  def test_confidence
    assert_equal(Confidence, @result.confidence)
  end

  def test_root_type
    assert_equal("PLAY", @result.root_type)
  end

  def test_each
    counter = 0
    @result.each do
      counter = counter +1
    end
    assert_equal(4, counter)
  end
end