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
    config 'config.yml'
  end

  class Book2 < ActiveDocument::Base
    config 'config.yml'
    namespaces :pubdate => 'http://docbook.org/ns/docbook', :book => 'http://docbook.org/ns/docbook'
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
    # todo fix
    book = Book.load("test.xml")
    assert_not_nil(book, "Should have been able to load the document by uri")
    assert_instance_of(Book, book, "Book should be an instance of document not #{book.class}")
    assert_equal "test.xml", book.uri
  end

  def test_find_by_word
    # test wtih explicit root
    results = Book.find_by_word("beliefs", "book")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
    # test wtih defualt root
    results = Book.find_by_word("beliefs")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(2, results.total)
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
    results = Book2.find_by_pubdate("1900",nil, 'http://docbook.org/ns/docbook')
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


end