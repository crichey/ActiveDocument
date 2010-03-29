require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
require 'active_document'
require 'search_results'
require 'rubygems'
require 'finder'
require 'test/unit'

class FinderTests < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    ActiveDocument::Finder.config('config.yml')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Tests dynamic finders for element word searches
  def test_element_word_searches
    # test for find by title element in namespace http://docbook.org/ns/docbook
    results = ActiveDocument::Finder.find_by_title("Explorers", "http://docbook.org/ns/docbook")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # test for find by PERSONA element with no namespace
    results = ActiveDocument::Finder.find_by_PERSONA("SCARUS") # note that the find is case sensitive in regards to the element name, e.g. find_by_persona fails
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
  end

  def test_search
    results = ActiveDocument::Finder.search("Antony OR settlement")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal 2, results.total
  end
end