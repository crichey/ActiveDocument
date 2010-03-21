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
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
require 'active_document'
require 'search_results'
require 'rubygems'
require 'test/unit'

class BaseTest < Test::Unit::TestCase

  class Book < ActiveDocument::Base
    default_namespace "http://docbook.org/ns/docbook"
    config 'config.yml'
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

  def test_find_by_work
    results = Document.find_by_word("beliefs", "book")
    assert_instance_of(ActiveDocument::SearchResults, results)
    assert_equal(1, results.total)
  end

  def test_element_word_searches
    results = Book.find_by_pubdate("1900")
  end


end