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
  # -------------------
  #  = Usage
  # -------------------
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
  # -------------------
  #  == Dynamic Accessors
  # In addition to the ability to access the underlying XML document (as a Nokogiri XML Document) you have the ability
  # to access the XML as attributes of your domain object via dynamic attribute accessors (eg. domain_object.element_name) The rules for using accessors
  # are as follows:
  #  1. If the element_name is a simple type (i.e. text node with no children <tt><example>text</exmample></tt>)
  #     1. If there is only one occurence of the element, return its text value
  #     2. If there are multiple occurences of the element, return a list of each text value
  #  2. If the element_name is a complex type (e.g. <tt><example><text>hi</text></example></tt>)
  #     1. If there is only one ocurence of the element then return it as a Nokoguri Element
  #     2. If there are multiple occurences of the element, return a list of Nokoguri Elements
  # -------------------
  class Base < Finder
    attr_reader :document
    @@namespaces = Hash.new

    # create a new instance with an optional xml string to use for constructing the model
    def initialize(xml_string = nil)
      unless xml_string.nil?
        @document = Nokogiri::XML(xml_string) do |config|
          config.noblanks
        end
      end
      @root = self.class.to_s.downcase
    end

    # enables the dynamic finders
    def method_missing(method_id, *arguments, &block)
      @@log.debug("ActiveDocument::Base at line #{__LINE__}: method called is #{method_id} with arguments #{arguments}")
      method = method_id.to_s
      if method =~ /^(\w*)$/ # methods with no '.' in them and not ending in '='
        if arguments.length > 0
          super
        end
        access_element $1
      end
    end

    def access_element(element)
      nodeset = @document.xpath("//#{element}")
      if nodeset.length == 1 # found one match
        if nodeset[0].children.length == 1 and nodeset[0].children[0].type == Nokogiri::XML::Node::TEXT_NODE
          nodeset[0].text
        elsif nodeset[0].children.length >1 # we are now dealing with complex nodes
          nodeset[0] # return the complex element
        end
      elsif nodeset.length >1 # multiple matches
        if nodeset.all? {|node| node.children.length == 1} and nodeset.all? {|node| node.children[0].type == Nokogiri::XML::Node::TEXT_NODE}
          # we have multiple simple text nodes
          nodeset.collect {|node| node.text}
        else
          # we have multiple complex elements
          nodeset.to_a
        end
      end
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
        @@log.debug("ActiveDocument::Base at line #{__LINE__}: method called is #{method_id} with arguments #{arguments}")
        method = method_id.to_s
        # identify element search methods
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