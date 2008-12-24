# FakeWeb - Ruby Helper for Faking Web Requests
# Copyright 2006 Blaine Cook <romeda@gmail.com>.
#
# FakeWeb is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# FakeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FakeWeb; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'net/http'
require 'net/https'
require 'stringio'

module Net  #:nodoc: all

  class BufferedIO
    def initialize(io, debug_output = nil)
      @read_timeout = 60
      @rbuf = ''
      @debug_output = debug_output

      @io = case io
      when Socket, OpenSSL::SSL::SSLSocket, IO
        io
      when String
        File.exists?(io) ? File.open(io, "r") : StringIO.new(io)
      end
      raise "Unable to create local socket" unless @io
    end
  end


  class HTTP
    def self.socket_type
      FakeWeb::SocketDelegator
    end

    alias :original_net_http_request :request
    alias :original_net_http_connect :connect

    def request(request, body = nil, &block)
      protocol = use_ssl ? "https" : "http"

      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/

      uri = "#{protocol}://#{self.address}:#{self.port}#{path}"

      if FakeWeb.registered_uri?(uri)
        @socket = Net::HTTP.socket_type.new
        FakeWeb.response_for(uri, &block)
      elsif FakeWeb.allow_net_connect?
        original_net_http_connect
        original_net_http_request(request, body, &block)
      else
        raise FakeWeb::NetConnectNotAllowedError,
              "Real HTTP connections are disabled. Unregistered URI: #{uri}"
      end
    end

    def connect
    end
  end

end
