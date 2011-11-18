require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require "ActiveDocument/database_configuration"
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
    assert_nil namespace
    namespaces = Hash.new
    namespaces["book"] = "http://docbook.org"
    ActiveDocument::DatabaseConfiguration.define_namespaces(namespaces)
    namespace = ActiveDocument::DatabaseConfiguration.lookup_namespace("book")
    assert_equal namespace, "http://docbook.org", "Expected http://docbook.org but received #{namespace}"
  end
end