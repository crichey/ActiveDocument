require "test/unit"
$:.unshift File.join(File.dirname(__FILE__), "../../src", "lib")
require 'ActiveDocument/search_match'
require 'rubygems'

class SearchMatchTest < Test::Unit::TestCase
  Snippet = "<span class=\"match\" path=\"/PLAY/TITLE\">The Tragedy of <span class=\"hit\">Antony</span> and Cleopatra</span>"


  def setup
    @match = ActiveDocument::SearchMatch.new(Nokogiri::XML(Snippet))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  def test_to_s
    assert_equal("<span class=\"match\" path=\"/PLAY/TITLE\">The Tragedy of Antony and Cleopatra</span>", @match.to_s)
  end

  def test_highlighted_match
    assert_equal("<span class=\"match\" path=\"/PLAY/TITLE\">The Tragedy of <bold>Antony</bold> and Cleopatra</span>", @match.highlighted_match("bold"))
  end
end