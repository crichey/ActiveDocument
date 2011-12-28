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

require 'net/http'
require 'uri'
require 'digest/md5'

module Net
  module HTTPHeader
    @@nonce_count = -1
    CNONCE = Digest::MD5.new.update("%x" % (Time.now.to_i + rand(65535))).hexdigest

    def digest_auth(user, password, response)
      # based on http://segment7.net/projects/ruby/snippets/digest_auth.rb
      @@nonce_count += 1

      response['www-authenticate'] =~ /^(\w+) (.*)/

      params = {}
      $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

      a_1 = "#{user}:#{params['realm']}:#{password}"
      a_2 = "#{@method}:#{@path}"
      request_digest = ''
      request_digest << Digest::MD5.new.update(a_1).hexdigest
      request_digest << ':' << params['nonce']
      request_digest << ':' << ('%08x' % @@nonce_count)
      request_digest << ':' << CNONCE
      request_digest << ':' << params['qop']
      request_digest << ':' << Digest::MD5.new.update(a_2).hexdigest

      header = []
      header << "Digest username=\"#{user}\""
      header << "realm=\"#{params['realm']}\""

      header << "qop=#{params['qop']}"

      header << "algorithm=MD5"
      header << "uri=\"#{@path}\""
      header << "nonce=\"#{params['nonce']}\""
      header << "nc=#{'%08x' % @@nonce_count}"
      header << "cnonce=\"#{CNONCE}\""
      header << "response=\"#{Digest::MD5.new.update(request_digest).hexdigest}\""

      @header['Authorization'] = header
    end
  end
end

module ActiveDocument

  class MarkLogicHTTP

    def initialize(uri, user_name, password)
      @url = URI.parse(uri)
      @user_name = user_name
      @password = password
    end

# @param uri [the uri endpoint for the request]
# @param body [the optional body]
# @param verb [The HTTP verb to be used]
# @param post_fields [a hash of post fields. They key should be the field name and the value is the field value]
# @return [nil if there if no uri or it is an empty string. Otherwise, returns the http response]
    def send_corona_request(uri, verb=:get, body="", post_fields=nil)
      return nil if uri.nil? or uri.empty?
      target_url = @url + URI.escape(uri)
      http = Net::HTTP.new(target_url.host, target_url.port)
      if target_url.query
        endpoint = target_url.path + "?" + target_url.query
      else
        endpoint = target_url.path
      end
      case verb
        when :post
          req = Net::HTTP::Post.new(endpoint)
          req.set_form_data(post_fields) unless post_fields.nil?
          #puts URI.decode_www_form(req.body)
        when :put
          req = Net::HTTP::Put.new(endpoint)
        when :get
          req = Net::HTTP::Get.new(endpoint)
        when :delete
          req = Net::HTTP::Delete.new(endpoint)
        else
          req = Net::HTTP::Get.new(endpoint) # safe default
      end
      if ((! body.nil?) and (verb == :put or verb == :post) ) then
        if (req.body.nil?) then req.body = body
        else
          req.body << body
        end
      end
      res = http.head(target_url.request_uri)
      #puts "body::::: #{req.body}" unless verb == :put
      req.digest_auth(@user_name, @password, res)
      res = http.request(req)
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          #puts res.body
          res.body
        else
          #puts req.path
          raise res.error!
      end
    end

  end
end
