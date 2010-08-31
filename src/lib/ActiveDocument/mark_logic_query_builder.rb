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

    def delete(uri)
      "xdmp:document-delete('#{uri}')"
    end

    def save(document, uri)
      xquery = <<-GENERATED
            xdmp:document-insert(
         "#{uri}",
	 #{document.to_s},
         xdmp:default-permissions(),
         xdmp:default-collections())
GENERATED
      
    end

    # This method does a full text search
    def find_by_word(word, root, namespace)
      xquery = <<GENERATED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("#{word}",
<options xmlns="http://marklogic.com/appservices/search">
GENERATED
      unless root.nil?
        xquery << "<searchable-expression"

        xquery << "  xmlns:a=\"#{namespace}\"" unless namespace.nil? or namespace.empty?
        xquery << '>/'
        xquery << "a:" unless namespace.nil? or namespace.empty?
        xquery << "#{root}</searchable-expression>"
      end
      xquery << "</options>)"
    end

    def find_by_element(element, value, root, element_namespace, root_namespace)
      xquery = <<GENERATED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("word:#{value}",
<options xmlns="http://marklogic.com/appservices/search">
GENERATED
      unless root.nil?
        xquery << "<searchable-expression"
        xquery << "  xmlns:a=\"#{root_namespace}\"" unless root_namespace.nil?
        xquery << '>/'
        xquery << "a:" unless root_namespace.nil?
        xquery << "#{root}</searchable-expression>"
      end
      xquery << <<CONSTRAINT
<constraint name="word">
<word>
<element ns="#{element_namespace unless element_namespace.nil?}" name="#{element}"/>
</word>
</constraint></options>)
CONSTRAINT
    end

    def find_by_attribute(element, attribute, value, root, element_namespace, attribute_namespace, root_namespace)
      # todo should the searchable expression portion be refactored?
      xquery = <<-GENERATED
      import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
      search:search("word:#{value}",
      <options xmlns="http://marklogic.com/appservices/search">
      GENERATED
      unless root.nil?
        xquery << "<searchable-expression"
        xquery << "  xmlns:a=\"#{root_namespace}\"" unless root_namespace.nil?
        xquery << '>/'
        xquery << "a:" unless root_namespace.nil?
        xquery << "#{root}</searchable-expression>"
      end
      xquery << <<-CONSTRAINT
      <constraint name="word">
      <word>
        <attribute ns="#{attribute_namespace unless attribute_namespace.nil?}" name="#{attribute}"/>
        <element ns="#{element_namespace unless element_namespace.nil?}" name="#{element}"/>
      </word>
      </constraint></options>)
      CONSTRAINT
    end

    def search(search_text, start, page_length, options)
      if options.nil?
        option = '()'
      else
        option = options.to_s
      end
      <<-GENERATED
      import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
      search:search('#{search_text}',#{option},#{start}, #{page_length})
      GENERATED
    end

    def co_occurrence(element1, element1_namespace, element2, element2_namespace, query)
      <<-GENERATED
declare namespace one = "#{element1_namespace}";
declare namespace two = "#{element2_namespace}";
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
let $pairs := cts:element-value-co-occurrences(xs:QName('one:#{element1}'), xs:QName('two:#{element2}'), ('frequency-order', 'fragment-frequency','ordered'), cts:query(search:parse('#{query}')))
return
for $pair in $pairs
return
  ($pair/cts:value[1]/text(),"|",$pair/cts:value[2]/text(),"|",cts:frequency($pair),"*")
      GENERATED
    end

  end # end class
end # end module