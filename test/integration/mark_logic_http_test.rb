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
$:.unshift File.join(File.dirname(__FILE__), "../../src/lib", "ActiveDocument")
require 'ActiveDocument/mark_logic_http'
require 'yaml'

class ConnectionTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    config = YAML.load_file('config.yml')
    @ml_http = ActiveDocument::MarkLogicHTTP.new(config['uri'], config['user_name'], config['password'])
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