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
    GET = :get
    POST = :post
    PUT = :put
    DELETE = :delete

    def initialize(uri, user_name, password)
      @url = URI.parse(uri)
      @user_name = user_name
      @password = password
    end

# @param uri [the uri endpoint for the request]
# @param body [the optional body]
# @param verb [The HTTP verb to be used]
    def send_corona_request(uri, verb=GET, body="")
      return nil if uri.nil? or uri.empty?
      targetUrl = @url + uri
      #targetUrl = URI.parse(target)
      req = authenticate(targetUrl, verb)
      req.body = body if verb == PUT or verb == POST
      #req.set_form_data({'request'=>"#{xquery}"})
      res = Net::HTTP.new(targetUrl.host, targetUrl.port).start { |http| http.request(req) }
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
#          puts res.body
          res.body
        else
          res.error!
      end
    end

    private
    def authenticate(targetUrl, verb)
      case verb
        when POST
          req = Net::HTTP::Post.new(targetUrl.path)
        when PUT
          req = Net::HTTP::Put.new(targetUrl.path)
        when GET
          req = Net::HTTP::Get.new(targetUrl.path)
        when DELETE
          req = Net::HTTP::Delete.new(targetUrl.path)
      end
      Net::HTTP.start(targetUrl.host, targetUrl.port) do |http|
        res = http.head(targetUrl.request_uri)
        req.digest_auth(@user_name, @password, res)
      end
      return req
    end
  end
end
