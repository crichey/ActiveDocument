require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
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