require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require 'rubygems'
require 'test/unit'
require 'ActiveDocument/Finder'

class FinderTests < Test::Unit::TestCase


  class Book < ActiveDocument::Base
    config 'config.yml'
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @a_and_c = Book.new(IO.read("../data/a_and_c.xml"), "/books/a_and_c.xml")
    @a_and_c.save

    @discover_book = Book.new(IO.read("../data/discoverBook.xml"), "/books/discoverBook.xml")
    @discover_book.save
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    Book.delete @a_and_c.uri
    Book.delete @discover_book.uri
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