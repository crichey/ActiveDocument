require 'rubygems'
require 'nokogiri'

module ActiveDocument
  class SearchResult
    include Enumerable
    def initialize(node)
      @node = node
    end

    def index
      Integer(@node.xpath("./@index").to_s)
    end

    def uri
      @node.xpath("./@uri").to_s
    end

    def path
      @node.xpath("./@path").to_s
    end

    def score
      Float(@node.xpath("./@score").to_s)
    end

    def confidence
      Float(@node.xpath("./@confidence").to_s)
    end

    def fitness
      Integer(@node.xpath("./@fitness").to_s)
    end

    def each(&block)
      @node.xpath("./search:snippet/search:match").each {|node| yield SearchMatch.new(node)}
    end
  end
end