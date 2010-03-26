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
require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'mark_logic_query_builder'
require 'search_results'
require 'finder'

# The ActiveXML module is used as a namespace for all classes relating to the ActiveXML functionality.
# ActiveXML::Base is the class that should be extended in order to make use of this functionality in your own
# domain objects.
#
module ActiveDocument

  # Developers should extend this class to create their own domain classes
  # = Usage
  #
  # == Dynamic Finders
  # ActiveDocument::Base provides extensive methods for finding matching documents based on a variety of criteria.
  # === Find By Element
  # Accessed via find_by_ELEMENT method where Element = the name of your element. Executes a search for all documents
  # with an element ELEMENT that contains the value passed in to the method call.
  # The signature of this dynamic finder is:
  # <tt>find_by_ELEMENT(value, root [optional], element_namespace [optional], root_namespace [optional])</tt>
  #
  # Parameters details are as follows:
  # <b>Value:</b> the text to be found within the given element. This is a mandatory parameter
  # <b>Namespace:</b> The namespace in which the element being searched occurs. This is an optional element. If provided,
  # it will be used in the search and will override any default values. If no namespace if provided then the code will
  # attempt to dynamically determine the namespace. First, if the element name is contained in the namespaces hash
  # then that namespace is used. If the element name is not found then the _default_namespace_
  # is used. If there is no default namespace, then no namespace is used.
  #
  class Base < Finder
    attr_reader :document
    @@namespaces = Hash.new

    # create a new instance with an optional xml string to use for constructing the model
    def initialize(xml_string = nil)
      @document = Nokogiri::XML(xml_string) unless xml_string.nil?
      @root = self.class.to_s.downcase
    end

    class << self
      attr_reader :default_namespace
      attr_accessor :root
      attr_reader :namespaces

      def namespaces(namespace_hash)
        @@namespaces = namespace_hash
      end

      def add_namespace(element, uri)
        @@namespaces[element.to_s] == uri
      end

      def remove_namespace(element)
        @@namespaces.delete element
      end

      def default_namespace(namespace)
        @@default_namespace = namespace # todo should this just be an entry in namespaces?
      end

      # enables the dynamic finders
      def method_missing(method_id, *arguments, &block)
        @@log.debug("ActiveDocumet::Base at line #{__LINE__}: method called is #{method_id} with arguments #{arguments}")
        method = method_id.to_s
        # identify finder methods
        if method =~ /find_by_(.*)$/ and arguments.length > 0
          value = arguments[0]
          element = $1.to_sym
          if arguments[1]
            root = arguments[1]
          else
            root = @root
          end
          if arguments[2]
            element_namespace = arguments[2]
          else
            element_namespace = namespace_for_element(element)
          end
          if arguments[3]
            root_namespace = arguments[3]
          else
            root_namespace = namespace_for_element(root)
          end
          execute_finder(element, value, root, element_namespace, root_namespace)
        end
      end

      # Returns an ActiveXML object representing the requested information
      def load(uri)
        self.new(@@ml_http.send_xquery(@@xquery_builder.load(uri)))
      end

      # Finds all documents of this type that contain the word anywhere in their structure
      def find_by_word(word, root=@root, namespace=@@default_namespace)
        SearchResults.new(@@ml_http.send_xquery(@@xquery_builder.find_by_word(word, root, namespace)))
      end

      def namespace_for_element(element)
        namespace = nill
        if @@namespaces[element]
          namespace = @@namespaces[element]
        else
          namespace = @@default_namespace unless @@default_namespace.nil?
        end
        namespace
      end
    end # end inner class

  end # end class


end # end module