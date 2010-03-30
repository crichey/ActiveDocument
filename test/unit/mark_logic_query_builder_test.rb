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
require 'mark_logic_query_builder'

class MarkLogicQueryBuilderTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @query_builder = ActiveDocument::MarkLogicQueryBuilder.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_load
    assert_equal("fn:doc('test.xml')", @query_builder.load("test.xml"))
  end

  def test_find_by_word
    # test with nil namespace
    word = "home"
    root = "p"
    result = @query_builder.find_by_word(word, root, nil)
    expected =
            <<EXPECTED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("home",
<options xmlns="http://marklogic.com/appservices/search">
<searchable-expression>/p</searchable-expression>
</options>)
EXPECTED

    expected.delete!("\n")
    result.delete!("\n")
    assert_equal expected, result

    # test with "" namespace
    word = "home"
    root = "p"
    result = @query_builder.find_by_word(word, root, "")
    expected =
            <<EXPECTED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("home",
<options xmlns="http://marklogic.com/appservices/search">
<searchable-expression>/p</searchable-expression>
</options>)
EXPECTED

    expected.delete!("\n")
    result.delete!("\n")
    assert_equal expected, result
    # test with namespace
    word = "home"
    root = "p"
    namespace ="http://marklogic.com/federal"
    result = @query_builder.find_by_word(word, root, namespace)
    expected =
            <<EXPECTED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("home",
<options xmlns="http://marklogic.com/appservices/search">
<searchable-expression  xmlns:a="http://marklogic.com/federal">/a:p</searchable-expression>
</options>)
EXPECTED

    expected.delete!("\n")
    result.delete!("\n")
    assert_equal expected, result
  end
end