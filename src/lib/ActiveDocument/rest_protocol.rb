module ActiveDocument
  module RestProtocol

    def setup_options_uri(options, root, root_namespace)
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

    def delete_all_namespaces_uri
      ["/manage/namespaces/", :delete]
    end

# @param uri [The uri for which the matching, if any, prefix should be found]
# @return [An array where the first item is the string uri for the request and the second item is the http verb]
    def lookup_namespace_uri(uri)
      ["/manage/namespace/#{uri}", :get]
    end

    def declare_namespace_uri(prefix, uri)
      ["/manage/namespace/#{prefix}?uri=#{uri}", :post]
    end

    def co_occurrence_uri(element1, element1_namespace, element2, element2_namespace, query)
      #  Not supported by Corona at this time
    end

    def search_uri(search_text, start, page_length, options)
      if options && options.directory_constraint
        directory_string = nil
        if options.directory_depth == 1
          directory_string = "&inDirectory=" + options.directory_constraint
        else
          directory_string = "&underDirectory=" +options.directory_constraint
        end
      end
      ["/search?stringQuery=#{search_text}&start=#{start}&end=#{start + page_length -1}&outputFormat=xml&include=snippet&include=confidence#{directory_string}", :get]
    end

    def find_by_attribute_uri(element, attribute, value, root, element_namespace, attribute_namespace, root_namespace, options = nil)
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
      post_parameters[:include] = "snippet"
      post_parameters[:include] = "confidence"
      if options.directory_constraint
        if options.directory_depth == 1
          post_parameters[:inDirectory] = options.directory_constraint
        else
          post_parameters[:underDirectory] = options.directory_constraint
        end
      end
      response[:post_parameters] = post_parameters
      response
    end

    def find_by_element_uri(element, value, root, element_namespace, root_namespace, options = nil)
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
      post_parameters[:include] = "snippet"
      post_parameters[:include] = "confidence"
      if options.directory_constraint
        if options.directory_depth == 1
          post_parameters[:inDirectory] = options.directory_constraint
        else
          post_parameters[:underDirectory] = options.directory_constraint
        end
      end
      response[:post_parameters] = post_parameters
      response
    end

# This method does a full text search
# @return A hash containing the necessary return values. This hash contains:
# uri: an array where the first element is the uri to be used for the REST call and the second element is the
# http verb
# post_parameters: a hash of all post parameters to be submitted
    def find_by_word_uri(word, root, root_namespace, options = nil)
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
      post_parameters[:include] = "snippet"
      post_parameters[:include] = "confidence"
      if options.directory_constraint
        if options.directory_depth == 1
          post_parameters[:inDirectory] = options.directory_constraint
        else
          post_parameters[:underDirectory] = options.directory_constraint
        end
      end
      response[:post_parameters] = post_parameters
      response
    end

# @param uri the uri of the record to be saved
# @return A hash containing the necessary return values. This hash contains:
# uri: an array where the first element is the uri to be used for the REST call and the second element is the
# http verb
    def save_uri(uri)
      {:uri => ["/v1/documents?uri=#{uri}", :put]}
    end

# @param uri the uri of the record to be deleted
# @return A hash containing the necessary return values. This hash contains:
# uri: an array where the first element is the uri to be used for the REST call and the second element is the
# http verb
    def delete_uri(uri)
      {:uri => ["/store?uri=#{uri}", :delete]}
    end

    def load_uri(uri)
      {:uri => ["/store?uri=#{uri}", :get]}
    end
  end
end
