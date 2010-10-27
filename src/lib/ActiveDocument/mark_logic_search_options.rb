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
  # MarkLogicSearchOptions allow you to control exactly how the ActiveDocument::Finder#search method behaves and what additional
  # information may be returned in the ActiveDocument::SearchResults object
  # == Attributes
  # * return_facets - if true then facet information is returned in the resultant ActiveDocument::SearchResults object. Default is true
  # * value_constraints - Used for creating searches on the value of an element
  #   this is a #Hash of value constraint names to their options.
  #   e.g. search_options_object.value_constraints["Region"] = {"namespace" => "http://wits.nctc.gov", "element" => "Region"}
  # * word_constraints - Used for creating searches for a word within an element value. This is a #Hash of word constaint names to their options
  #   this is a #Hash of value constraint names to their options.
  #   e.g. search_options_object.word_constraints["Region"] = {"namespace" => "http://wits.nctc.gov", "element" => "Region"}
  # * range_constraints - Used for searching for a range of values, also for creating facets or doing co-occurents.
  #   This is a #hash of range_constraint names to their options
  #   e.g. search_options_object.range_constraints["Facility Type"] = {"namespace" => "http://wits.nctc.gov", "element" => "FacilityType", "type" => "xs:string", "collation" => "http://marklogic.com/collation/"}
  # * directory_constraint - Used for specifying that the search should only executed for this directory, to the depth
  #   specified in directory_depth
  # * searchable_expression - An expression to be searched. Whatever expression is specified is returned from the search.
  #   This is provided as a hash where the key is the element name and the value is the element's namespace. If there is no
  #   namespace then nil or "" should be passed as the value. eg search_options_object.searchable_expression["element"] = "namespace" or
  #   search_options_object.searchable_expression["element"] = "" if there is no namespace for element
  class MarkLogicSearchOptions
    attr_accessor :return_facets, :value_constraints, :word_constraints, :range_constraints, :directory_constraint, :directory_depth, :searchable_expression

    def initialize
      @return_facets = true;
      @value_constraints = Hash.new
      @word_constraints = Hash.new
      @range_constraints = Hash.new
      @searchable_expression = Hash.new
      @directory_depth = 1
    end


    # outputs the object in correctly formatted XML suitable for use in a search
    def to_s
      constraints = String.new
      additional_query = String.new
      searchable_path = String.new

      @value_constraints.each do |key, value|
        constraints << <<-XML
        <constraint name=" #{key.gsub(/\s/, '_')} ">
          <value>
            <element ns=" #{value["namespace"]} " name=" #{value["element"]} "/>
          </value>
        </constraint>
        XML
      end

      @word_constraints.each do |key, value|
        constraints << <<-XML
        <constraint name=" #{key.gsub(/\s/, '_')} ">
          <word>
            <element ns=" #{value["namespace"]} " name=" #{value["element"]} "/>
          </word>
        </constraint>
        XML
      end

      @range_constraints.each do |key, value|
        constraints << <<-XML
        <constraint name=" #{key.gsub(/\s/, '_')} ">
          <range type=" #{value["type"]} "
        XML
        if value.has_key?("collation")
          constraints << "collation=\"#{value["collation"]}\""
        end

        constraints << <<-XML
            >
            <element ns=" #{value["namespace"]} " name=" #{value["element"]} "/>
        XML

        if value.has_key?("computed_buckets")
          value["computed_buckets"].each do |computed_bucket|
            constraints << computed_bucket.to_s if computed_bucket.instance_of?(ActiveDocument::MarkLogicSearchOptions::ComputedBucket)
          end
        end
        constraints << "</range></constraint>"
      end

      # serialize the additional query information
      if @directory_constraint
        additional_query = "<additional-query>{cts:directory-query(\"#{directory_constraint}\"), \"#{directory_depth}\"}</additional-query>"
      end

      # serialize the searchable_expression
      if @searchable_expression.size > 0
        searchable_path << "<searchable-expression"
        searchable_path << "  xmlns:a=\"#{@searchable_expression.keys[0]}\"" unless @searchable_expression.keys[0].nil? or @searchable_expression.keys[0].empty?
        searchable_path << '>/'
        searchable_path << "a:" unless @searchable_expression.keys[0].nil? or @searchable_expression.keys[0].empty?
        searchable_path << "#{@searchable_expression.values[0]}</searchable-expression>"
      end

      value = "<options xmlns=\"http://marklogic.com/appservices/search\">"
      unless additional_query.empty?
        value << additional_query
      end
      value << "<return-facets>#{@return_facets}</return-facets>"

      # add in constraints
      unless constraints.empty?
        value << constraints
      end

      # output the searchable expression
      unless searchable_path.empty?
        value << searchable_path
      end
      # close the options node
      value << "</options>"

    end

    #end to_s

    class ComputedBucket
      attr_accessor :name, :ge, :lt, :anchor, :title

      def initialize (name, ge, lt, anchor, title)
        @name = name
        @ge = ge
        @lt = lt
        @anchor = anchor
        @title = title
      end

      def to_s
        <<-XML
          <computed-bucket name=" #{@name} " ge=" #{@ge} " lt=" #{@lt} " anchor=" #{@anchor} "> #{@title} </computed-bucket>
        XML
      end
    end
  end

end