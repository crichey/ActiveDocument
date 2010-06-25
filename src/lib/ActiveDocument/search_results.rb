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
require 'ActiveDocument/search_result'

module ActiveDocument
  class SearchResults
    include Enumerable
    attr_reader :facets

    def initialize(results)
      @results_document = Nokogiri::XML(results)
      @facets = Hash.new
      @results_document.xpath("/search:response/search:facet").each do |facet|
        name = facet.xpath("./@name").to_s
        detail = Hash.new
        @facets[name] = detail
        facet.xpath("search:facet-value").each do |facet_value|
          detail[facet_value.xpath("./@name").to_s] = facet_value.xpath("./@count").to_s
        end
      end
    end

    def total
      Integer(@results_document.xpath("/search:response/@total").to_s)
    end

    def start
      Integer(@results_document.xpath("/search:response/@start").to_s)
    end

    def page_length
      Integer(@results_document.xpath("/search:response/@page-length").to_s)
    end

    def search_text
      @results_document.xpath("/search:response/search:qtext/text()").to_s
    end

    def query_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:query-resolution-time/text()").to_s
    end

    def snippet_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:snippet-resolution-time/text()").to_s
    end

    def facet_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:facet-resolution-time/text()").to_s
    end

    def total_time
      @results_document.xpath("/search:response/search:metrics/search:total-time/text()").to_s
    end

    def each(&block)
      nodeset = @results_document.xpath("/search:response/search:result")
      if nodeset.length == 1
        yield SearchResult.new(nodeset[0])
      else
        @results_document.xpath("/search:response/search:result").each {|node| yield SearchResult.new(node)}
      end
    end

    def [](index)
      SearchResult.new(@results_document.xpath("/search:response/search:result")[index])
    end

    def length
      @results_document.xpath("/search:response/search:result").length
    end

  end

end
