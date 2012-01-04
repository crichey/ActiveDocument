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

require 'rubygems'
require 'nokogiri'
require 'ActiveDocument/search_match'

module ActiveDocument
  class SearchResult
    include Enumerable

    def initialize(node)
      @node = node
    end

    #def index
    #  Integer(@node.xpath("./@index").to_s)
    #end

    def uri
       @node.xpath("./corona:uri").text.to_s
    end

    #def path
    #  @node.xpath("./@path").to_s
    #end

    #def score
    #  Float(@node.xpath("./@score").to_s)
    #end

    def confidence
      Float(@node.xpath("./corona:confidence").to_s)
    end

    #def fitness
    #  Float(@node.xpath("./@fitness").to_s)
    #end

    def each(&block)
      nodeset = @node.xpath("./search:snippet/search:match")
      if nodeset.length == 1
        yield SearchMatch.new(nodeset[0])
      else
        @node.xpath("./search:snippet/search:match").each {|node| yield SearchMatch.new(node)}
      end
    end

    def root_type
      full_path = @node.xpath("./search:snippet/search:match")[0].xpath("./@path").to_s
      root = full_path.match(/:[[:alpha:]]+\/|:[[:alpha:]]+$/) # find the first :something/ which should indicate the root
      root.to_s.delete(":/") # remove the : and / to get the root element name
    end

    def [](index)
      SearchMatch.new(@node.xpath("./search:snippet/search:match")[index])
    end

    def length
      @node.xpath("./search:snippet/search:match").length
    end
    def realize(klass)
      klass.load(uri)
    end
  end
end