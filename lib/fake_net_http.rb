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

module Net #:nodoc:

  class BufferedIO #:nodoc:
    def initialize( io, debug_output = nil )
      @debug_output = debug_output
      @io = case io
      when Socket, IO: io
      when String
        File.exists?(io) ?  File.open(io, "r") : StringIO.new(io)
      end
      raise "Unable to create local socket" unless @io
      connect
    end

    def connect(*args)
      @rbuf = ''
    end

    def rbuf_fill
      @rbuf << @io.sysread(1024)
    end
  end
  
  class HTTP #:nodoc:

    def HTTP.socket_type #:nodoc:
      FakeWeb::SocketDelegator
    end

    alias :original_net_http_request :request
    alias :original_net_http_connect :connect
    
    def request(req, body = nil, &block)
      prot = use_ssl ? "https" : "http"
      uri = "#{prot}://#{self.address}#{req.path}"
      if FakeWeb.registered_uri?(uri)
        @socket = Net::HTTP.socket_type.new
        return FakeWeb.response_for(uri, &block)
      else
        original_net_http_connect
        return original_net_http_request(req, body, &block)
      end
    end

    def connect
    end
  end
end
