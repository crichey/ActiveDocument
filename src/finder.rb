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
require 'mark_logic_query_builder'
require 'rubygems'
require 'nokogiri'
require 'search_results'
require 'logger'

module ActiveDocument

  class Finder


    @@xquery_builder = ActiveDocument::MarkLogicQueryBuilder.new

    def self.config(yaml_file)
      config = YAML.load_file(yaml_file)
      @@ml_http = ActiveDocument::MarkLogicHTTP.new(config['uri'], config['user_name'], config['password'])
      configure_logger(config)
    end

    # enables the dynamic finders
    def self.method_missing(method_id, *arguments, &block)
      puts "method called is #{method_id} with arguments #{arguments}" # todo change output to logging output
      method = method_id.to_s
      # identify finder methods
      if method =~ /find_by_(.*)$/ and arguments.length > 0
        namespace = arguments[1] if arguments.length == 2
        execute_finder($1.to_sym, arguments[0], nil, namespace)
      else
        puts "missed"
      end
    end

    def self.execute_finder(element, value, root = nil, element_namespace = nil, root_namespace = nil)
      xquery = @@xquery_builder.find_by_element(element, value, root, element_namespace, root_namespace)
      @@log.info("Finder.execute_finder at line #{__LINE__}: #{xquery}")
      SearchResults.new(@@ml_http.send_xquery(xquery))
    end

    private

    def self.configure_logger(config)

      begin
        log_location = if config['logger']['file']
          config['logger']['file']
        else
          STDERR
        end
        log_level = case config['logger']['level']
          when "debug" then
            Logger::DEBUG
          when "info" then
            Logger::INFO
          when "warn" then
            Logger::WARN
          when "error" then
            Logger::ERROR
          when "fatal" then
            Logger::FATAL
          else
            Logger::WARN
        end

        rotation  = if config['logger']['rotation']
          config['logger']['rotation']
        else
          "daily"
        end
        file = open(log_location, File::WRONLY | File::APPEND | File::CREAT)
        @@log = Logger.new(file, rotation)
        @@log.level = log_level
      rescue StandardError => oops
        @@log = Logger.new(STDERR)
        @@log.level = Logger::WARN
      end
    end
  end

end
