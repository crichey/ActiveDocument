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

module ActiveDocument

  class MarkLogicQueryBuilder

    def load(uri)
      "fn:doc('#{uri}')"
    end

    def find_by_word(word, root, namespace)
xquery = <<GENERATED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("#{word}",
<options xmlns="http://marklogic.com/appservices/search">
<searchable-expression
GENERATED
      xquery << "  xmlns:a=\"#{namespace}\"" unless namespace.nil? or namespace.empty?
      xquery << '>/'
      xquery << "a:" unless namespace.nil? or namespace.empty?
      xquery << "#{root}</searchable-expression></options>)"
    end
  end

end