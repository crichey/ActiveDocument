require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require "ActiveDocument/database_configuration"
require "json"
class NamespacesTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    ActiveDocument::DatabaseConfiguration.initialize('config.yml')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail
    namespace = ActiveDocument::DatabaseConfiguration.lookup_namespace("book")
    #assert_nil namespace
    namespaces = Hash.new
    namespaces["book"] = "http://docbook.org/ns/docbook"
    ActiveDocument::DatabaseConfiguration.define_namespaces(namespaces)
    namespace = ActiveDocument::DatabaseConfiguration.lookup_namespace("book")
    namespace_hash = JSON.parse namespace
    assert_equal namespace_hash['uri'], "http://docbook.org/ns/docbook", "Expected #{namespaces["book"]} but received #{namespace}"
  end
end