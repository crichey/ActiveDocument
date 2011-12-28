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
$:.unshift File.join(File.dirname(__FILE__), "../../src/", "lib")
require 'ActiveDocument/active_document'
require 'ActiveDocument/search_results'
require 'rubygems'
require 'test/unit'


class BookUnit < ActiveDocument::Base
  config 'config.yml'
end

class BookWithRoot < ActiveDocument::Base
  config 'config.yml'
  root "book"
end

class DocBook < ActiveDocument::Base
  config 'config.yml'
  default_namespace "http://docbook.org/ns/docbook"
end

class TestBook < ActiveDocument::Base
  config 'config.yml'
  default_namespace "test"
end

class BaseTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @book = BookUnit.new(IO.read("../data/a_and_c.xml"))
    @bookWithRoot = BookWithRoot.new(IO.read("../data/a_and_c.xml"))
    @book_namespaces = DocBook.new(IO.read("../data/discoverBook.xml"))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_document_root
    # test the default root determination
    assert_equal "PLAY", @book.root
    # test the overriden root value
    assert_equal "book", @bookWithRoot.root
  end

  def test_dynamic_attributes
    my_book = BookUnit.new("<book><title>Tale of Two Penguins</title><author>Savannah</author></book>")
    assert_raise NoMethodError do
      my_book.title 1900 # dynamic attributes don't allow for paramters
    end

    assert_equal "book", my_book.root

    # test simple case for single text nodes
    title = my_book.title
    assert_equal "Tale of Two Penguins", title.text
    assert_equal "Savannah", my_book.author.text
    # test for single complex element
    element = my_book.book
    assert_instance_of ActiveDocument::Base::PartialResult, element
    assert_equal "book", element.root
    assert_equal 2, element.children.length

    # test for multiple simple elements
    titles = @book.TITLE
    assert_equal 49, titles.length
    assert_equal "The Tragedy of Antony and Cleopatra", titles[0].text
    assert_equal "Dramatis Personae", titles[1].text

    # test for multiple complex elements
    groups = @book.PGROUP
    assert_equal 6, groups.length
    assert_instance_of ActiveDocument::Base::PartialResult, groups
    assert_equal 4, groups[0].children.length
  end

  def test_nested_dynamic_attributes
    title = @book.PERSONAE.TITLE
    assert_equal "Dramatis Personae", title.text
    #@book.TITLE.each do |title|
    #  puts title.text
    #end

    # test with namespace
    date = @book_namespaces.bookinfo.pubdate.text
    assert_equal("1900", date)
  end

  def test_dynamic_attributes_with_hyphens
    my_book = BookUnit.new("<book><book-title>Tale of Two Penguins</book-title><author>Savannah</author></book>")
    title = my_book.bookHYPHENtitle
    assert_equal "Tale of Two Penguins", title.text

    my_book = BookUnit.new("<book><chapter><first-paragraph>My First paragraph</first-paragraph></chapter></book>")
    paragraph = my_book.chapter.firstHYPHENparagraph
    assert_equal "My First paragraph", paragraph.text
  end

  
  def test_modify_simple_element
    my_book = BookUnit.new("<book><title type='test'>Tale of Two Penguins</title><author>Savannah</author></book>")
    assert_equal "Tale of Two Penguins", my_book.title.text
    my_book.title = "changed"
    assert_equal "changed", my_book.title.text
    assert_equal 'test', my_book.title["type"]
    my_book.title["type"] = "works"
    assert_equal 'works', my_book.title["type"]
  end

  def test_element_attributes
    # test with no namespaces first
    my_book = BookUnit.new("<book author='Savannah'><title section='foo'>Tale of Two Penguins</title></book>")
    assert_equal "Savannah", my_book["author"]

    # test with no namespaces and attribute in nested element
    assert_equal "foo", my_book.title["section"]

    # test with namespaces
    my_book = TestBook.new("<test:book xmlns:test='test' test:author='Savannah'><test:title test:section='foo'>Tale of Two Penguins</title></book>")
    assert_equal "Savannah", my_book["author"]

    # test with no namespaces and attribute in nested element
    assert_equal "foo", my_book.title["section"]
  end

end