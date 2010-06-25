#   Copyright 2010 Mark Logic, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require 'ActiveDocument/search_results'
require 'ActiveDocument/search_result'
require 'ActiveDocument/search_match'
require 'ActiveDocument/active_document'

class SearchResultsTest < Test::Unit::TestCase
  class Book < ActiveDocument::Base
    default_namespace "http://docbook.org/ns/docbook"
    config 'config.yml'
  end

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

    xml_results_noh = <<BEGIN
      <search:response total="2" start="1" page-length="10" xmlns:search="http://marklogic.com/appservices/search">
  <search:result index="1" uri="/documents/discoverBook.xml" path="fn:doc('/documents/discoverBook.xml')" score="243" confidence="0.97047" fitness="1">
    <search:snippet>
      <search:match path="fn:doc('/documents/discoverBook.xml')/*:book/*:bookinfo/*:title">Discoverers and Explorers</search:match>
      <search:match path="fn:doc('/documents/discoverBook.xml')/*:book/*:chapter[1]/*:chapterinfo/*:biblioentry/*:title">Discoverers and Explorers</search:match>
    </search:snippet>
  </search:result>
  <search:result index="2" uri="/documents/a_and_c.xml" path="fn:doc('/documents/a_and_c.xml')" score="234" confidence="0.952329" fitness="1">
    <search:snippet>
      <search:match path="fn:doc('/documents/a_and_c.xml')/PLAY/PERSONAE/PERSONA[10]">Officers, Soldiers, Messengers, and other Attendants.</search:match>
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

    results_with_facets = <<-BEGIN
<search:response total="21973" start="1" page-length="10" xmlns:search="http://marklogic.com/appservices/search">
  <search:result index="9" uri="/Users/clarkrichey/Downloads/wits/wits21402.xml" path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits21402.xml&quot;)" score="196" confidence="0.338805" fitness="0.890659">
    <search:snippet>
      <search:match path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits21402.xml&quot;)/*:Incident/*:Subject">1 newspaper editor injured in letter <search:highlight>bomb</search:highlight> attack by Informal Anarchist Federation in Turin, Piemonte, Italy</search:match>
      <search:match path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits21402.xml&quot;)/*:Incident/*:EventTypeList">
<search:highlight>Bombing</search:highlight>
</search:match>
      <search:match path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits21402.xml&quot;)/*:Incident/*:WeaponTypeList/*:WeaponType">Letter <search:highlight>Bomb</search:highlight></search:match>
    </search:snippet>
  </search:result>
  <search:result index="10" uri="/Users/clarkrichey/Downloads/wits/wits23118.xml" path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits23118.xml&quot;)" score="196" confidence="0.338805" fitness="0.890659">
    <search:snippet>
      <search:match path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits23118.xml&quot;)/*:Incident/*:Subject">1 government employee killed in <search:highlight>bombing</search:highlight> in Ghazni, Afghanistan</search:match>
      <search:match path="fn:doc(&quot;/Users/clarkrichey/Downloads/wits/wits23118.xml&quot;)/*:Incident/*:EventTypeList">
<search:highlight>Bombing</search:highlight>
</search:match>
    </search:snippet>
  </search:result>
  <search:facet name="Region">
    <search:facet-value name="Africa" count="622">Africa</search:facet-value>
    <search:facet-value name="Central and South America" count="1012">Central and South America</search:facet-value>
    <search:facet-value name="East Asia-Pacific" count="1198">East Asia-Pacific</search:facet-value>
    <search:facet-value name="Eurasia" count="761">Eurasia</search:facet-value>
    <search:facet-value name="Europe" count="1057">Europe</search:facet-value>
    <search:facet-value name="Middle East and Persian Gulf" count="10374">Middle East and Persian Gulf</search:facet-value>
    <search:facet-value name="North America and Caribbean" count="16">North America and Caribbean</search:facet-value>
    <search:facet-value name="South Asia" count="6933">South Asia</search:facet-value>
  </search:facet>
  <search:facet name="Country">
    <search:facet-value name="England" count="200">England</search:facet-value>
    <search:facet-value name="Ireland" count="422">Ireland</search:facet-value>
    <search:facet-value name="Brazil" count="10">Brazil</search:facet-value>
  </search:facet>
  <search:qtext>bomb</search:qtext>
  <search:metrics>
    <search:query-resolution-time>PT0.420016S</search:query-resolution-time>
    <search:facet-resolution-time>PT0.002873S</search:facet-resolution-time>
    <search:snippet-resolution-time>PT0.039998S</search:snippet-resolution-time>
    <search:total-time>PT0.463759S</search:total-time>
  </search:metrics>
</search:response>
    BEGIN
    @search_results = ActiveDocument::SearchResults.new(xml_results)
    @search_results_noh = ActiveDocument::SearchResults.new(xml_results_noh)
    @faceted_results = ActiveDocument::SearchResults.new(results_with_facets)
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

    a = results[0]
    assert_not_nil a[0]
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
    results = @search_results
    match = results[0].to_a

    # test first set of matches
    # check length
    assert_equal(2, results[0].length)

    # check path
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:bookinfo/*:title", results[0][0].path)
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:chapter[1]/*:chapterinfo/*:biblioentry/*:title", results[0][1].path)
    # check match text
    assert_equal("Discoverers and Explorers", results[0][0].to_s)
    assert_equal("Discoverers and Explorers", results[0][1].to_s)
    # check  match with default highlighting
    assert_equal("Discoverers <search:highlight>and</search:highlight> Explorers", results[0][0].highlighted_match)
    assert_equal("Discoverers <search:highlight>and</search:highlight> Explorers", results[0][1].highlighted_match)
    # check  match with custom highlighting
    assert_equal("Discoverers <b>and</b> Explorers", results[0][0].highlighted_match("b"))
    assert_equal("Discoverers <b>and</b> Explorers", results[0][1].highlighted_match("b"))
    # test second set of matches
    # check length
    assert_equal(1, results[1].length)

    # check path
    assert_equal("fn:doc('/documents/a_and_c.xml')/PLAY/PERSONAE/PERSONA[10]", results[1][0].path)
    # check match text
    assert_equal("Officers, Soldiers, Messengers, and other Attendants.", results[1][0].to_s)
    # check match with default highlighting
    assert_equal("Officers, Soldiers, Messengers, <search:highlight>and</search:highlight> other Attendants.", results[1][0].highlighted_match)
    # check match with custom highlighting
    assert_equal("Officers, Soldiers, Messengers, <b>and</b> other Attendants.", results[1][0].highlighted_match("b"))

    #check highlighting function when no highlighting present in results
    results = @search_results_noh.to_a
    match = results[0].to_a
    # check match text
    assert_equal("Discoverers and Explorers", results[0][0].to_s)
    assert_equal("Discoverers and Explorers", results[0][0].highlighted_match("b"))
  end

  def test_facets
    facets = @faceted_results.facets
    assert_equal 2, facets.size
    assert_block do
      facets.keys.include? "Region"
      facets.keys.include? "Country"
    end
    assert_equal 8, facets["Region"].size
  end

  def test_root_type
    puts @search_results.to_a[0].root_type
  end

  def test_realize

    result = @search_results.to_a[0]
    my_book = result.realize(Book)
    assert_instance_of(Book, my_book)
  end

end