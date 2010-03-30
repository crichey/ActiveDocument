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
require 'active_document'
require 'search_results'
require 'rubygems'
require 'test/unit'


class Book < ActiveDocument::Base
  config 'config.yml'
end

class BaseTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @book = Book.new(IO.read("../data/a_and_c.xml"))

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_dynamic_attributes
    my_book = Book.new("<book><title>Tale of Two Penguins</title><author>Savannah</author></book>")
    assert_raise NoMethodError do
      my_book.title 1900 # dynamic attributes don't allow for paramters
    end
    # test simple case for single text nodes
    assert_equal "Tale of Two Penguins", my_book.title
    assert_equal "Savannah", my_book.author
    # test for single complex element
    element = my_book.book
    assert_instance_of ActiveDocument::Base::PartialResult, element
    assert_equal "book", element.root
    #assert_equal 2, element.children.length
    # test for multiple simple elements
    titles = @book.TITLE
    assert_equal 49, titles.length
    assert_equal "The Tragedy of Antony and Cleopatra", titles[0]
    assert_equal "Dramatis Personae", titles[1]
#    # test for multiple complex elements
#    groups = @book.PGROUP
#    assert_equal 6, groups.length
#    assert_instance_of ActiveDocument::PartialResult, groups
    #assert_equal 4, groups[0].children.length
  end

  def test_nested_dynamic_attributes
    title = @book.PERSONAE.TITLE
    assert_equal "Dramatis Personae", title
  end

end