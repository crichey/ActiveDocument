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
      value = @node.xpath("./node()").to_s
      begin
        value[/<search:highlight>/] = ""
        value[/<\/search:highlight>/] = ""
      rescue IndexError
      end
      return value
    end

    def highlighted_match(highlight_tag = nil)
      value = @node.xpath("./node()").to_s
      unless highlight_tag.nil?
        begin
          value[/<search:highlight>/] = "<#{highlight_tag}>"
          value[/<\/search:highlight>/] = "</#{highlight_tag}>"
        rescue IndexError
          value
        end

      end
      return value
    end
  end
end