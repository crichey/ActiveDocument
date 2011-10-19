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
    end

    def total
      Integer(@results_document.xpath("/corona:response/corona:meta/corona:total/text()").to_s)
    end

    def start
      Integer(@results_document.xpath("/corona:response/corona:meta/corona:start/text()").to_s)
    end

    def page_length
      total - start + 1
    end

    def each(&block)
      nodeset = @results_document.xpath("/corona:response/corona:results/corona:result")
      if nodeset.length == 1
        yield SearchResult.new(nodeset[0])
      else
        @results_document.xpath("/corona:response/corona:results/corona:result").each {|node| yield SearchResult.new(node)}
      end
    end

    def [](index)
      SearchResult.new(@results_document.xpath("/corona:response/corona:results/corona:result")[index])
    end

    def length
      @results_document.xpath("/corona:response/corona:results/corona:result").length
    end

  end

end
