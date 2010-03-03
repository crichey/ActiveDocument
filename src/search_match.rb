require 'rubygems'
require 'nokogiri'

module ActiveDocument
  class SearchMatch
    include Enumerable

    def initialize(node)
      @node = node
    end

    def path
      @node.xpath("./@path").to_s
    end

    def to_s
      @node.xpath("./text()").to_s
    end
  end
end