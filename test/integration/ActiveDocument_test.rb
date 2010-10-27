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
require 'ActiveDocument/active_document'
require 'ActiveDocument/search_results'
require 'rubygems'
require 'test/unit'

class BaseTest < Test::Unit::TestCase

  class Book < ActiveDocument::Base
    default_namespace "http://docbook.org/ns/docbook"
    root "book"
    config 'config.yml'
  end

  class Book2 < ActiveDocument::Base
    config 'config.yml'
    namespaces :pubdate => 'http://docbook.org/ns/docbook', :book => 'http://docbook.org/ns/docbook'
  end

  class Play < ActiveDocument::Base
    config 'config.yml'
    root 'PLAY'
  end

  class BookNoNamespace < ActiveDocument::Base
    config 'config.yml'
    root 'book'
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

  # test ability to load by uri
  def test_find_by_uri
    # test exception raised when document doesn't exist
    assert_raise ActiveDocument::LoadException do
      Book.load("notFound.xml")
    end

    # test correct loading of a document
    book = Book.load("/books/a_and_c.xml")
    assert_not_nil(book, "Should have been able to load the document by uri")
    assert_instance_of(Book, book, "Book should be an instance of document not #{book.class}")
    assert_equal "/books/a_and_c.xml", book.uri
  end

  def test_find_by_word
    # test wtih explicit root
    results = Book.find_by_word("beliefs", "book")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
    # test wtih default root
    results = Book.find_by_word("beliefs")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
  end

  def test_element_word_searches
    # test with default namespace
    results = Book.find_by_pubdate("1900")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # now verify that same result is achieved when there is no default namespace and an element namespace is explicitly set for the element
    results = Book2.find_by_pubdate("1900")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # now verify that same result is achieved when there is no default namespace and an element namespace is explicitly set in the call
    Book2.remove_namespace("pubdate")
    results = Book2.find_by_pubdate("1900", nil, 'http://docbook.org/ns/docbook')
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # test with nil passed in for element namespace, should use default namespace
    results = Book.find_by_pubdate("1900", nil, nil, nil)
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # test with invalid explicit element namespace to act as baseline
    results = Book.find_by_pubdate("1900", nil, "bad")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(0, results.total)

    # test with explicit root of book with default namespace
    results = Book.find_by_pubdate("1900", "book")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # test with explicit root of book with default element namespace and explicit root namespace
    results = Book.find_by_pubdate("1900", "book", nil, 'http://docbook.org/ns/docbook')
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)

    # now verify that same result is achieved when there is no default namespace and an element namespace is explicitly set for the element and root
    results = Book2.find_by_pubdate("1900")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
  end

  def test_find_by_attribute
    # test with no attribute namespace
    results = Book.find_by_attribute_Role("bibliomisc", "src-chapnum")
    assert_equal(1, results.total)
    # test incorrect search with no attribute namespace
    results = Book.find_by_attribute_Role("bibliomisc", "garbagefdsfsdfds")
    assert_equal(0, results.total)
    # test with explicit attribute namespace
    results = Book.find_by_attribute_sort("title", "Discoverers and Explorers", nil, nil, "http://docbook.org/ns/docbook")
    assert_equal(1, results.total)
  end

  def test_find_by_element
    # test using default namespace
    results = Book.find_by_title("Discoverers and Explorers")
    assert_equal(1, results.total)
    results = Book.find_by_title("Discoverers and Explorers", nil, "http://docbook.org/ns/docbook")
    assert_equal(1, results.total)
    # test with no namespaces
    results = Play.find_by_PERSONA("MARK ANTONY")
    assert_equal(1, results.total)

  end

  def test_realize
    result = Book.find_by_word("beliefs", "book")[0]
    my_book = result.realize(Book)
    assert_instance_of(Book, my_book)
  end

  def test_save_and_delete
    book = BookNoNamespace.new("<book><title>Tale of Two Penguins</title><author>Savannah</author></book>", "test.xml")
    book.save
    loaded_book = BookNoNamespace.load("test.xml")
    assert_not_nil loaded_book
    assert_equal "book", loaded_book.root
    assert_equal "Tale of Two Penguins", loaded_book.title.text

    # delete the loaded book
    Book.delete(loaded_book.uri)

    # confirm that it is deleted
    begin
      Book.delete(loaded_book.uri)
    rescue Net::HTTPFatalError => e then
      assert_match(/Document not found/, e.message)
    else
      fail "No exception raised"
    end
  end

end