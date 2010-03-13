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

require 'mark_logic_http'
require 'mark_logic_query_builder'
require 'rubygems'
require 'nokogiri'
require 'search_results'

module ActiveDocument

  class Finder

    @@ml_http = ActiveDocument::MarkLogicHTTP.new
    @@xquery_builder = ActiveDocument::MarkLogicQueryBuilder.new

    # enables the dynamic finders
    def self.method_missing(method_id, *arguments, &block)
      puts "method called is #{method_id} with argumens #{arguments}" # todo change output to logging output
      method = method_id.to_s
      if method =~ /find_by_(.*)$/ and arguments.length > 1
        self.execute_finder($1.to_sym, arguments[0], arguments[1])
      else
        puts "missed"
      end
    end
    
    def self.execute_finder(element, value, namespace = nil)
      SearchResults.new(@@ml_http.send_xquery(@@xquery_builder.find_by_element(element, value, nil, namespace)))
    end
  end

end
