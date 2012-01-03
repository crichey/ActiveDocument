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
require 'ActiveDocument/mark_logic_search_options'
module ActiveDocument

  #todo create a configuration class for logging info and such

  # CoronaInterface methods always return a hash. This hash will always contain at least a uri key with associated
  # value
  class CoronaInterface

    def self.load(uri)
      {:uri => ["/store?uri=#{uri}", :get]}
    end

    # @param uri the uri of the record to be deleted
    # @return A hash containing the necessary return values. This hash contains:
    # uri: an array where the first element is the uri to be used for the REST call and the second element is the
    # http verb
    def self.delete(uri)
      {:uri => ["/store?uri=#{uri}", :delete]}
    end

    # @param uri the uri of the record to be saved
    # @return A hash containing the necessary return values. This hash contains:
    # uri: an array where the first element is the uri to be used for the REST call and the second element is the
    # http verb
    def self.save(uri)
      {:uri => ["/store?uri=#{uri}", :put]}
    end

    # This method does a full text search
    # @return A hash containing the necessary return values. This hash contains:
    # uri: an array where the first element is the uri to be used for the REST call and the second element is the
    # http verb
    # post_parameters: a hash of all post parameters to be submitted
    def self.find_by_word(word, root, root_namespace, options = nil)
      #todo deal with paging
      response = Hash.new
      post_parameters = Hash.new
      options = self.setup_options(options, root, root_namespace)
      unless root.nil?
        if root_namespace.nil?
          root_expression = root
        else
          root_expression = options.searchable_expression[root_namespace] + ":" + root unless root_namespace.nil?
        end
      end
      structured_query = "{\"underElement\":\"#{root_expression}\",\"query\":{\"wordAnywhere\":\"#{word}\"}}"
      response[:uri] = ["/search", :post]
      post_parameters[:structuredQuery] = structured_query
      post_parameters[:outputFormat] = "xml"
      response[:post_parameters] = post_parameters
      response
    end

    def self.find_by_element(element, value, root, element_namespace, root_namespace, options = nil)
      response = Hash.new
      post_parameters = Hash.new
      options = self.setup_options(options, root, root_namespace)
      unless root.nil?
        if root_namespace.nil?
          root_expression = root
        else
          root_expression = options.searchable_expression[root_namespace] + ":" + root unless root_namespace.nil?
        end
      end
      element_qname = element.to_s
      element_qname.insert(0, element_namespace + ":") unless element_namespace.nil?
      # todo this query is the more permissive contains. Deal with more restrictive equals as well
      structured_query = "{\"element\":\"#{element_qname}\", \"contains\":\"#{value}\"}"
      response[:uri] = ["/search", :post]
      post_parameters[:structuredQuery] = structured_query
      post_parameters[:outputFormat] = "xml"
      response[:post_parameters] = post_parameters
      response
    end

    def self.find_by_attribute(element, attribute, value, root, element_namespace, attribute_namespace, root_namespace, options = nil)
      response = Hash.new
      post_parameters = Hash.new
      options = self.setup_options(options, root, root_namespace)
      unless root.nil?
        if root_namespace.nil?
          root_expression = root
        else
          root_expression = options.searchable_expression[root_namespace] + ":" + root unless root_namespace.nil?
        end
      end
      element_qname = element
      element_qname.insert(0, element_namespace + ":") unless element_namespace.nil?
      attribute_qname = attribute.to_s
      attribute_qname.insert(0, attribute_namespace + ":") unless attribute_namespace.nil?
      # todo this query is the more permissive contains. Deal with more restrictive equals as well
      structured_query = "{\"element\":\"#{element_qname}\",\"attribute\":\"#{attribute_qname}\", \"contains\":\"#{value}\"}"
      response[:uri] = ["/search", :post]
      post_parameters[:structuredQuery] = structured_query
      post_parameters[:outputFormat] = "xml"
      response[:post_parameters] = post_parameters
      response
    end

    def self.search(search_text, start, page_length, options)
      ["/search?stringQuery=#{search_text}&start=#{start}&end=#{start + page_length -1}&outputFormat=xml", :get]
    end

    def self.co_occurrence(element1, element1_namespace, element2, element2_namespace, query)
    #  Not supported by Corona at this time
    end

    def self.declare_namespace(prefix, uri)
      ["/manage/namespace/#{prefix}?uri=#{uri}", :post]
    end

    # @param uri [The uri for which the matching, if any, prefix should be found]
    # @return [An array where the first item is the string uri for the request and the second item is the http verb]
    def self.lookup_namespace(uri)
      ["/manage/namespace/#{uri}", :get]
    end

    def self.delete_all_namespaces
      ["/manage/namespace/", :delete]
    end

    private

    def self.setup_options(options, root, root_namespace)
      if options then
        search_options = options
      else
        search_options = ActiveDocument::MarkLogicSearchOptions.new
      end
      if (search_options.searchable_expression.empty?)
        search_options.searchable_expression[root_namespace] = root unless root.nil?
      end
      return search_options
    end

  end # end class
end # end module