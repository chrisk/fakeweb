require 'net/http'
require 'net/https'
require 'stringio'

module Net  #:nodoc: all

  class BufferedIO
    alias :old_initialize :initialize
    def initialize(io, debug_output = nil)
      @read_timeout = 60
      @rbuf = ''
      @debug_output = debug_output

      @io = case io
      when Socket, OpenSSL::SSL::SSLSocket, IO
        io
      when String
        if !io.include?("\0") && File.exists?(io)
          File.open(io, "r")
        else
          StringIO.new(io)
        end
      end
      raise "Unable to create local socket" unless @io
    end
  end

  class HTTP
    class << self
      alias :old_socket_type :socket_type
    end
    def self.socket_type
      FakeWeb::StubSocket
    end

    alias :original_net_http_request :request
    alias :original_net_http_connect :connect

    def request(request, body = nil, &block)
      protocol = use_ssl? ? "https" : "http"

      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/

      if request["authorization"] =~ /^Basic /
        userinfo = request["authorization"].sub(/^Basic /, "").unpack("m").first + "@"
      else
        userinfo = ""
      end

      uri = "#{protocol}://#{userinfo}#{self.address}:#{self.port}#{path}"
      method = request.method.downcase.to_sym

      if FakeWeb.registered_uri?(method, uri)
        @socket = Net::HTTP.socket_type.new
        FakeWeb.response_for(method, uri, &block)
      elsif FakeWeb.allow_net_connect?
        original_net_http_connect
        original_net_http_request(request, body, &block)
      else
        raise FakeWeb::NetConnectNotAllowedError,
              "Real HTTP connections are disabled. Unregistered request: #{request.method} #{uri}"
      end
    end

    def connect
    end
  end

end
