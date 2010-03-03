require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../..", "src")
require 'mark_logic_http'

class ConnectionTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @ml_http = ActiveDocument::MarkLogicHTTP.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # test valid connection
  def test_connect
    assert_nothing_raised do
      response = @ml_http.send_xquery("fn:doc('/documents/discoverBook.xml')")
      #puts response
      assert_not_nil response, "Should have been able to find content for /documents/discoverBook.xml"
    end
  end

  # test error
  def test_error_response
    assert_raise Net::HTTPError, Net::HTTPFatalError do
      response = @ml_http.send_xquery("fn:dosc('/documents/discoverBook.xml')")
      #puts response
    end
  end
end