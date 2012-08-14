require 'ActiveDocument/marklogic_search_options'

module ActiveDocument
  class RestProtocol

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

    def self.delete_all_namespaces_setup
      ["/manage/namespaces/", :delete]
    end

    def self.co_occurrence_setup(element1, element1_namespace, element2, element2_namespace, query)
      #  Not supported by Corona at this time
    end

    def self.search_setup(search_text, start, page_length, options)
      if options && options.directory_constraint
        directory_string = nil
        if options.directory_depth == 1
          directory_string = "&inDirectory=" + options.directory_constraint
        else
          directory_string = "&underDirectory=" +options.directory_constraint
        end
      end
      ["/v1/search?q=#{search_text}", :get]
    end

    def self.find_by_attribute_setup(element, attribute, value, root, element_namespace, attribute_namespace, root_namespace, options = nil)
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

    def self.find_by_element_setup(element, value, root, element_namespace, root_namespace, options = nil)
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
# @param [Object] word
# @param [Object] root
# @param [Object] root_namespace
# @param [Object] options
    def self.find_by_word_setup(word, root, root_namespace, options = nil)
      #todo deal with paging
      response = Hash.new
      post_parameters = Hash.new
      options = self.setup_options(options, root, root_namespace)

      if root_namespace.nil?
        root_expression = root
      else
        root_expression = options.searchable_expression[root_namespace] + ":" + root unless root_namespace.nil?
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
    def self.save_setup(uri)
      {:uri => ["/v1/documents?uri=#{uri}", :put]}
    end

# @param uri the uri of the record to be deleted
# @return A hash containing the necessary return values. This hash contains:
# uri: an array where the first element is the uri to be used for the REST call and the second element is the
# http verb
    def self.delete_setup(uri)
      {:uri => ["/v1/documents?uri=#{uri}", :delete]}
    end

    def self.load_setup(uri)
      {:uri => ["/v1/documents?uri=#{uri}", :get]}
    end
  end
end
