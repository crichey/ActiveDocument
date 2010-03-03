require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
require 'active_document'
require 'search_results'
require 'rubygems'
require 'test/unit'
gem 'flexmock'

class BaseTest < Test::Unit::TestCase

  class Document < ActiveDocument::Base
    default_namespace "http://docbook.org/ns/docbook"
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # @doc = Document.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # test ability to load by uri
  def test_find_by_uri
    book = Document.load("test.xml")
    assert_not_nil(book, "Should have been able to load the document by uri")
    assert_instance_of(Document, book, "Book should be an instance of document not #{book.class}")
  end

  def test_finder
    results = Document.find_by_word("beliefs", "book")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
  end


end