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

require 'fake_net_http'
require 'singleton'

module OpenURI #:nodoc: all
  class HTTPError < StandardError; end;
end

module FakeWeb

  # Resets the FakeWeb Registry. This will force all subsequent web requests to
  # behave as real requests.
  def FakeWeb.clean_registry; FakeWeb::Registry.instance.clean_registry; end

  # Register +uri+ to be handled according to +options+. +uri+ can be a
  # +String+ or an +URI+ object. +options+ must be a +Hash+ that must contain
  # any one of the following keys:
  #
  # <tt>:string</tt>::
  #   Takes a +String+ argument that is returned as the body of the response.
  #     FakeWeb.register_uri('http://example.com/', :string => "Hello World!") 
  # <tt>:file</tt>::
  #   Takes a valid filesystem path to a file that is slurped and returned as
  #   the body of the response.
  #     FakeWeb.register_uri('http://example.com/', :file => "/tmp/my_response_body.txt")
  # <tt>:response</tt>:: 
  #   Either an <tt>Net::HTTPResponse</tt>, an +IO+ or a +String+.
  # 
  #   The easier way by far is to pass the <tt>:response</tt> option to
  #   +register_uri+ as a +String+ or an (open for reads) +IO+ object which
  #   will be used as the complete HTTP response, including headers and body.
  #   If the string points to a readable file, this file will be used as the
  #   content for the request.
  # 
  #   To obtain a complete response document, you can use the +curl+ command,
  #   like so:
  #  
  #     curl -i http://www.example.com/ > response_for_www.example.com
  #
  #   which can then be used in your test environment like so:
  #
  #     FakeWeb.register_uri('http://www.example.com/', :response => 'response_for_www.example.com')
  #
  #   See the <tt>Net::HTTPResponse</tt>
  #   documentation[http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTPResponse.html]
  #   for more information on creating custom response objects.
  # 
  # Two optional arguments are also accepted:
  #
  # <tt>:status</tt>::
  #   Passing <tt>:status</tt> as a two-value array will set the response code
  #   and message. The defaults are <tt>200</tt> and <tt>OK</tt>, respectively.
  #   Example:
  #     FakeWeb.register_uri('http://www.example.com/', :response => "Go away!", :status => [ 404, "Not Found" ])
  # <tt>:exception</tt>::
  #   The argument passed via <tt>:exception</tt> will be raised when the
  #   specified URL is requested. Any +Exception+ class is valid. Example:
  #     FakeWeb.register_uri('http://www.example.com/', :exception => Net::HTTPError)
  #
  def FakeWeb.register_uri(uri, options); FakeWeb::Registry.instance.register_uri(uri, options); end

  # Returns the faked Net::HTTPResponse object associated with +uri+.
  def FakeWeb.response_for(uri, &block) #:nodoc: :yields: response
    FakeWeb::Registry.instance.response_for(uri, &block)
  end

  # Checks for presence of +uri+ in the +FakeWeb+ registry.
  def FakeWeb.registered_uri?(uri); FakeWeb::Registry.instance.registered_uri?(uri); end

  class Registry #:nodoc:
    include Singleton

    attr_accessor :uri_map

    def initialize
      clean_registry
    end

    def clean_registry
      self.uri_map = {}
    end

    def register_uri(uri, options)
      uri_map[normalize_uri(uri)] = FakeWeb::Responder.new(uri, options)
    end

    def registered_uri?(uri)
      uri_map.has_key?(normalize_uri(uri))
    end

    def registered_uri(uri)
      uri = normalize_uri(uri)
      return uri_map[uri] if registered_uri?(uri)
    end

    def response_for(uri, &block)
      return registered_uri(uri).response(&block)
    end

    private

    def normalize_uri(uri)
      case uri
      when URI: uri
      else
        uri = 'http://' + uri unless uri.match('^https?://')
        URI.parse(uri)
      end
    end
  end

  module Response #:nodoc:
    def read_body(*args, &block)
      yield @body if block_given?
      @body
    end
  end

  class Responder #:nodoc:

    attr_accessor :uri, :options

    def initialize(uri, options)
      self.uri = uri
      self.options = options
    end

    def response(&block)
      if has_baked_response?
        response = baked_response
      else
        code, msg = meta_information
        response = Net::HTTPResponse.send(:response_class, code.to_s).new(uri, code.to_s, msg)
        response.instance_variable_set(:@body, content)
      end
      response.instance_variable_set(:@read, true)
      response.extend FakeWeb::Response

      optionally_raise(response)

      yield response if block_given?

      response
    end

    private

    def content
      [ :file, :string ].each do |map_option|
        next unless options.has_key?(map_option)
        return self.send("#{map_option}_response", options[map_option])
      end

      return ''
    end

    def file_response(path)
      IO.readlines(path).join("\n")
    end

    def string_response(string)
      string
    end

    def baked_response
      resp = case options[:response]
      when Net::HTTPResponse: options[:response]
      when String
        socket = Net::BufferedIO.new(options[:response])
        r = Net::HTTPResponse.read_new(socket)
        r.instance_eval { @header['transfer-encoding'] = nil }
        r.reading_body(socket, true) {}
        r
      else raise StandardError, "Handler unimplemented for response #{options[:response]}"
      end
    end

    def has_baked_response?
      options.has_key?(:response)
    end

    def optionally_raise(response)
      return unless options.has_key?(:exception)
      ex_alloc = options[:exception].allocate
      ex_instance = case ex_alloc
      when Net::HTTPError, OpenURI::HTTPError: options[:exception].new('Exception from FakeWeb', response)
      else options[:exception].new
      end
      raise ex_instance
    end

    def meta_information
      if options.has_key?(:status); options[:status]
      else; [ 200, 'OK' ]
      end
    end
  end

  class SocketDelegator #:nodoc:

    def initialize(delegate=nil)
      @delegate = nil
    end

    def method_missing(method, *args, &block)
      return @delegate.send(method, *args, &block) if @delegate
      return self.send("my_#{method}", *args, &block)
    end

    def my_closed?
      @closed ||= true
    end

    def my_readuntil(*args)
    end
  end
end
