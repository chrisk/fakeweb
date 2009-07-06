require 'singleton'

require 'fake_web/ext/net_http'
require 'fake_web/registry'
require 'fake_web/response'
require 'fake_web/responder'
require 'fake_web/stub_socket'
require 'fake_web/utility'

module FakeWeb

  # Resets the FakeWeb Registry. This will force all subsequent web requests to
  # behave as real requests.
  def self.clean_registry
    Registry.instance.clean_registry
  end

  # Enables or disables real HTTP connections for requests that don't match
  # registered URIs.
  #
  # If you set <tt>FakeWeb.allow_net_connect = false</tt> and subsequently try
  # to make a request to a URI you haven't registered with #register_uri, a
  # NetConnectNotAllowedError will be raised. This is handy when you want to
  # make sure your tests are self-contained, or want to catch the scenario
  # when a URI is changed in implementation code without a corresponding test
  # change.
  #
  # When <tt>FakeWeb.allow_net_connect = true</tt> (the default), requests to
  # URIs not stubbed with FakeWeb are passed through to Net::HTTP.
  def self.allow_net_connect=(allowed)
    @allow_net_connect = allowed
  end

  # Enable pass-through to Net::HTTP by default.
  self.allow_net_connect = true

  # Returns +true+ if requests to URIs not registered with FakeWeb are passed
  # through to Net::HTTP for normal processing (the default). Returns +false+
  # if an exception is raised for these requests.
  def self.allow_net_connect?
    @allow_net_connect
  end

  # This exception is raised if you set <tt>FakeWeb.allow_net_connect =
  # false</tt> and subsequently try to make a request to a URI you haven't
  # stubbed.
  class NetConnectNotAllowedError < StandardError; end;

  # This exception is raised if a Net::HTTP request matches more than one of
  # the regular expression-based stubs you've registered. To fix the problem,
  # disambiguate the regular expressions by making them more specific.
  class MultipleMatchingRegexpsError < StandardError; end;

  # call-seq:
  #   FakeWeb.register_uri(method, uri, options)
  #
  # Register requests using the HTTP method specified by the symbol +method+
  # for +uri+ to be handled according to +options+. If you specify the method
  # <tt>:any</tt>, the response will be reigstered for any request for +uri+.
  # +uri+ can be a +String+, +URI+, or +Regexp+ object. +options+ must be either
  # a +Hash+ or an +Array+ of +Hashes+ (see below), which must contain one of
  # these two keys:
  #
  # <tt>:body</tt>::
  #   A string which is used as the body of the response. If the string refers
  #   to a valid filesystem path, the contents of that file will be read and used
  #   as the body of the response instead. (This used to be two options,
  #   <tt>:string</tt> and <tt>:file</tt>, respectively. These are now deprecated.)
  # <tt>:response</tt>:: 
  #   Either an <tt>Net::HTTPResponse</tt>, an +IO+, or a +String+ which is used
  #   as the full response for the request.
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
  #     FakeWeb.register_uri(:get, 'http://www.example.com/', :response => 'response_for_www.example.com')
  #
  #   See the <tt>Net::HTTPResponse</tt>
  #   documentation[http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTPResponse.html]
  #   for more information on creating custom response objects.
  # 
  # +options+ may also be an +Array+ containing a list of the above-described
  # +Hash+. In this case, FakeWeb will rotate through each provided response,
  # you may optionally provide:
  #
  # <tt>:times</tt>::
  #   The number of times this response will be used. Decremented by one each time it's called.
  #   FakeWeb will use the final provided request indefinitely, regardless of its :times parameter.
  # 
  # Two optional arguments are also accepted:
  #
  # <tt>:status</tt>::
  #   Passing <tt>:status</tt> as a two-value array will set the response code
  #   and message. The defaults are <tt>200</tt> and <tt>OK</tt>, respectively.
  #   Example:
  #     FakeWeb.register_uri("http://www.example.com/", :body => "Go away!", :status => [404, "Not Found"])
  # <tt>:exception</tt>::
  #   The argument passed via <tt>:exception</tt> will be raised when the
  #   specified URL is requested. Any +Exception+ class is valid. Example:
  #     FakeWeb.register_uri('http://www.example.com/', :exception => Net::HTTPError)
  #
  # If you're using the <tt>:body</tt> response type, you can pass additional
  # options to specify the HTTP headers to be used in the response. Example:
  #
  #   FakeWeb.register_uri(:get, "http://example.com/index.txt", :body => "Hello", :content_type => "text/plain")
  def self.register_uri(*args)
    case args.length
    when 3
      Registry.instance.register_uri(*args)
    when 2
      print_missing_http_method_deprecation_warning(*args)
      Registry.instance.register_uri(:any, *args)
    else
      raise ArgumentError.new("wrong number of arguments (#{args.length} for 3)")
    end
  end

  # call-seq:
  #   FakeWeb.response_for(method, uri)
  #
  # Returns the faked Net::HTTPResponse object associated with +method+ and +uri+.
  def self.response_for(*args, &block) #:nodoc: :yields: response
    case args.length
    when 2
      Registry.instance.response_for(*args, &block)
    when 1
      print_missing_http_method_deprecation_warning(*args)
      Registry.instance.response_for(:any, *args, &block)
    else
      raise ArgumentError.new("wrong number of arguments (#{args.length} for 2)")
    end
  end

  # call-seq:
  #   FakeWeb.registered_uri?(method, uri)
  #
  # Returns true if a +method+ request for +uri+ is registered with FakeWeb.
  # Specify a method of <tt>:any</tt> to check for against all HTTP methods.
  def self.registered_uri?(*args)
    case args.length
    when 2
      Registry.instance.registered_uri?(*args)
    when 1
      print_missing_http_method_deprecation_warning(*args)
      Registry.instance.registered_uri?(:any, *args)
    else
      raise ArgumentError.new("wrong number of arguments (#{args.length} for 2)")
    end
  end

  private

  def self.print_missing_http_method_deprecation_warning(*args)
    method = caller.first.match(/`(.*?)'/)[1]
    new_args = args.map { |a| a.inspect }.unshift(":any")
    new_args.last.gsub!(/^\{|\}$/, "").gsub!("=>", " => ") if args.last.is_a?(Hash)
    $stderr.puts
    $stderr.puts "Deprecation warning: FakeWeb requires an HTTP method argument (or use :any). Try this:"
    $stderr.puts "  FakeWeb.#{method}(#{new_args.join(', ')})"
    $stderr.puts "Called at #{caller[1]}"
  end
end
