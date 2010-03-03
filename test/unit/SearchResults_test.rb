require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
require 'search_results'
require 'search_result'
require 'search_match'

class SearchResultsTest < Test::Unit::TestCase

  # Create a SearchResults object with the configured simulated XML result from the server
  def setup
    xml_results = <<BEGIN
      <search:response total="2" start="1" page-length="10" xmlns:search="http://marklogic.com/appservices/search">
  <search:result index="1" uri="/documents/discoverBook.xml" path="fn:doc('/documents/discoverBook.xml')" score="243" confidence="0.97047" fitness="1">
    <search:snippet>
      <search:match path="fn:doc('/documents/discoverBook.xml')/*:book/*:bookinfo/*:title">Discoverers <search:highlight>and</search:highlight> Explorers</search:match>
      <search:match path="fn:doc('/documents/discoverBook.xml')/*:book/*:chapter[1]/*:chapterinfo/*:biblioentry/*:title">Discoverers <search:highlight>and</search:highlight> Explorers</search:match>
    </search:snippet>
  </search:result>
  <search:result index="2" uri="/documents/a_and_c.xml" path="fn:doc('/documents/a_and_c.xml')" score="234" confidence="0.952329" fitness="1">
    <search:snippet>
      <search:match path="fn:doc('/documents/a_and_c.xml')/PLAY/PERSONAE/PERSONA[10]">Officers, Soldiers, Messengers, <search:highlight>and</search:highlight> other Attendants.</search:match>
    </search:snippet>
  </search:result>
  <search:qtext>and</search:qtext>
  <search:metrics>
    <search:query-resolution-time>PT0.009197S</search:query-resolution-time>
    <search:facet-resolution-time>PT0.000083S</search:facet-resolution-time>
    <search:snippet-resolution-time>PT0.019534S</search:snippet-resolution-time>
    <search:total-time>PT0.029033S</search:total-time>
  </search:metrics>
</search:response>
BEGIN
    @search_results = ActiveDocument::SearchResults.new(xml_results)

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # test total
  def test_total
    assert_equal(2, @search_results.total)
  end

  # test start
  def test_start
    assert_equal(1, @search_results.start)
  end

  # test page length
  def test_page_length
    assert_equal(10, @search_results.page_length)
  end

  def test_search_text
    assert_equal("and", @search_results.search_text)
  end

  def test_query_resolution_time
    assert_equal("PT0.009197S", @search_results.query_resolution_time)
  end

  def test_facet_resolution_time
    assert_equal("PT0.000083S", @search_results.facet_resolution_time)
  end

  def test_snippet_resolution_time
    assert_equal("PT0.019534S", @search_results.snippet_resolution_time)
  end

  def test_total_time
    assert_equal("PT0.029033S", @search_results.total_time)
  end

  def test_results
    results = @search_results.to_a
    # check length
    assert_equal(2, results.length)

    # check index
    assert_equal(1, results[0].index)
    assert_equal(2, results[1].index)

    # check uri
    assert_equal("/documents/discoverBook.xml", results[0].uri)
    assert_equal("/documents/a_and_c.xml", results[1].uri)

    # check path
    assert_equal("fn:doc('/documents/discoverBook.xml')", results[0].path)
    assert_equal("fn:doc('/documents/a_and_c.xml')", results[1].path)

    # check score
    assert_equal(243, results[0].score)
    assert_equal(234, results[1].score)

    # check confidence
    assert_equal(0.97047, results[0].confidence)
    assert_equal(0.952329, results[1].confidence)

    # check fitness
    assert_equal(1, results[0].fitness)
    assert_equal(1, results[1].fitness)
  end

  def test_results_match
    results = @search_results.to_a
    match = results[0].to_a

    # test first set of matches
    # check length
    assert_equal(2, match.length)

    #check path
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:bookinfo/*:title", match[0].path)
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:chapter[1]/*:chapterinfo/*:biblioentry/*:title", match[1].path)
    #check match text
    assert_equal("Discoverers and Explorers", match[0].to_s)
    assert_equal("Discoverers and Explorers", match[1].to_s)

    #test second set of matches
    match = results[1].to_a
    # check length
    assert_equal(1, match.length)

    #check path
    assert_equal("fn:doc('/documents/a_and_c.xml')/PLAY/PERSONAE/PERSONA[10]", match[0].path)
    assert_equal("Officers, Soldiers, Messengers,  other Attendants.", match[1].to_s)
  end


end