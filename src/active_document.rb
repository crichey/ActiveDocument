require 'mark_logic_http'
require 'rexml/document'
require 'mark_logic_query_builder'
require 'search_results'

# The ActiveXML module is used as a namespace for all classes relating to the ActiveXML functionality.
# ActiveXML::Base is the class that should be extended in order to make use of this functionality in your own
# domain objects
module ActiveDocument

  # Developers should extend this class to create their own domain classes
  class Base
    attr_reader :document


    @@ml_http = ActiveDocument::MarkLogicHTTP.new
    @@xquery_builder = ActiveDocument::MarkLogicQueryBuilder.new

    # create a new instance with an optional xml string to use for constructing the model
    def initialize(xml_string = nil)
      @document = REXML::Document.new(xml_string) unless xml_string.nil?
    end



    class << self

      attr_reader :default_namespace
      def default_namespace(namespace)
        @@default_namespace = namespace
      end


      # enables the dynamic finders
      def method_missing(method_id, *arguments, &block)
        puts "method called is #{method_id}"
        method = method_id.to_s
        if method =~ /find_by_(.*)$/
          puts "Got finder for #{$1}"
        else
          puts "missed"
        end
      end

      # Returns an ActiveXML object representing the requested information
      def load(uri)
        self.new(@@ml_http.send_xquery(@@xquery_builder.load(uri)))
      end

      # Finds all documents of this type that contain the word anywhere in their structure
      def find_by_word(word, root=self.class.to_s.downcase, namespace=@@default_namespace)
        SearchResults.new(@@ml_http.send_xquery(@@xquery_builder.find_by_word(word, root, namespace)))
      end
    end

  end

end