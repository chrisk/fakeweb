require 'net/http'
require 'net/https'
require 'stringio'

module Net  #:nodoc: all

  class BufferedIO
    alias initialize_without_fakeweb initialize
    def initialize(io, debug_output = nil)
      @read_timeout = 60
      @rbuf = ''
      @debug_output = debug_output

      @io = case io
      when Socket, OpenSSL::SSL::SSLSocket, IO
        io
      when String
        if !io.include?("\0") && File.exists?(io) && !File.directory?(io)
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
      alias socket_type_without_fakeweb socket_type
      def socket_type
        FakeWeb::StubSocket
      end
    end

    alias request_without_fakeweb request
    def request(request, body = nil, &block)
      protocol = use_ssl? ? "https" : "http"

      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/

      if request["authorization"] =~ /^Basic /
        userinfo = FakeWeb::Utility.decode_userinfo_from_header(request["authorization"])
        userinfo = FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo) + "@"
      else
        userinfo = ""
      end

      uri = "#{protocol}://#{userinfo}#{self.address}:#{self.port}#{path}"
      method = request.method.downcase.to_sym

      if FakeWeb.registered_uri?(method, uri)
        @socket = Net::HTTP.socket_type.new
        FakeWeb.response_for(method, uri, &block)
      elsif FakeWeb.allow_net_connect?
        connect_without_fakeweb
        request_without_fakeweb(request, body, &block)
      else
        uri = FakeWeb::Utility.strip_default_port_from_uri(uri)
        raise FakeWeb::NetConnectNotAllowedError,
              "Real HTTP connections are disabled. Unregistered request: #{request.method} #{uri}"
      end
    end

    alias connect_without_fakeweb connect
    def connect
    end
  end

end
