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
$:.unshift File.join(File.dirname(__FILE__), "../../src/lib", "ActiveDocument8")
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
        @search_results = ActiveDocument::SearchResults.new(xml_results)
    @search_results_noh = ActiveDocument::SearchResults.new(xml_results_noh)

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

    # check path
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:bookinfo/*:title", match[0].path)
    assert_equal("fn:doc('/documents/discoverBook.xml')/*:book/*:chapter[1]/*:chapterinfo/*:biblioentry/*:title", match[1].path)
    # check match text
    assert_equal("Discoverers and Explorers", match[0].to_s)
    assert_equal("Discoverers and Explorers", match[1].to_s)
    # check  match with default highlighting
    assert_equal("Discoverers <search:highlight>and</search:highlight> Explorers", match[0].highlighted_match)
    assert_equal("Discoverers <search:highlight>and</search:highlight> Explorers", match[1].highlighted_match)
    # check  match with custom highlighting
    assert_equal("Discoverers <b>and</b> Explorers", match[0].highlighted_match("b"))
    assert_equal("Discoverers <b>and</b> Explorers", match[1].highlighted_match("b"))
    # test second set of matches
    match = results[1].to_a
    # check length
    assert_equal(1, match.length)

    # check path
    assert_equal("fn:doc('/documents/a_and_c.xml')/PLAY/PERSONAE/PERSONA[10]", match[0].path)
    # check match text
    assert_equal("Officers, Soldiers, Messengers, and other Attendants.", match[0].to_s)
    # check match with default highlighting
    assert_equal("Officers, Soldiers, Messengers, <search:highlight>and</search:highlight> other Attendants.", match[0].highlighted_match)
    # check match with custom highlighting
    assert_equal("Officers, Soldiers, Messengers, <b>and</b> other Attendants.", match[0].highlighted_match("b"))

    #check highlighting function when no highlighting present in results
    results = @search_results_noh.to_a
    match = results[0].to_a
    # check match text
    assert_equal("Discoverers and Explorers", match[0].to_s)
    assert_equal("Discoverers and Explorers", match[0].highlighted_match("b"))
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