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
require "yaml"
require 'ActiveDocument/mark_logic_http'
require 'ActiveDocument/corona_interface'
module ActiveDocument

  # This class is used to manage the configuration of MarkLogic. It can create, list and change / delete a variety of
  # configuration options including indexes namespaces and fields
  class DatabaseConfiguration

    # @param yaml_file [The yaml file containing the configuration information for the server connection]
    def self.initialize(yaml_file)
      config = YAML.load_file(yaml_file)
      @@ml_http = ActiveDocument::MarkLogicHTTP.new(config['uri'], config['user_name'], config['password'])
      @@namespaces = Hash.new
    end

    # @param namespaces [a Hash of namespaces prefixes to namespaces]
    def self.define_namespaces(namespaces)
      namespaces.keys.each do |key|
        corona_array = ActiveDocument::CoronaInterface.declare_namespace(key, namespaces[key])
        @@ml_http.send_corona_request(corona_array[0], corona_array[1])
      end
    end

    # @param prefix [The prefix for which you wish to find a matching namespace]
    # @return The matching namespace as a string or nil if there is no matching namespace for the prefix
    def self.lookup_namespace(prefix)
      corona_array = ActiveDocument::CoronaInterface.lookup_namespace(prefix)
      begin
        @@ml_http.send_corona_request(corona_array[0], corona_array[1])
      rescue Exception => exception
        if exception.response.code == "404"
          nil #return nil when no namespace is found
        else
          raise exception
        end
      end
    end

    def self.delete_all_namespaces
      corona_array = ActiveDocument::CoronaInterface.delete_all_namespaces
      begin
        @@ml_http.send_corona_request(corona_array[0], corona_array[1])
      rescue Exception => exception
        if exception.response.code == "404"
          nil
        else
          raise exception
        end
      end
    end

  end
end