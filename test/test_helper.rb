require 'rubygems'
require 'bundler'
Bundler.setup

require 'helpers/start_simplecov'

require 'test/unit'
require 'open-uri'
require 'pathname'
require 'fake_web'
require 'rbconfig'


# See mocha's modifying
#   https://github.com/freerange/mocha/commit/6df882d33ba785e0b43b224b7d625841d8e203be#lib/mocha/setup.rb
begin
  require 'mocha/setup'
rescue LoadError
  require 'mocha'
end

# Give all tests a common setup and teardown that prevents shared state
class Test::Unit::TestCase
  alias setup_without_fakeweb setup
  def setup
    FakeWeb.clean_registry
    @original_allow_net_connect = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = false
  end

  alias teardown_without_fakeweb teardown
  def teardown
    FakeWeb.allow_net_connect = @original_allow_net_connect
  end
end


module FakeWebTestHelper
  BUILTIN_ASSERTIONS = Test::Unit::TestCase.instance_methods.select { |m| m.to_s =~ /^assert/ }.map { |m| m.to_sym }

  # Backport assert_empty for Ruby 1.8 (it comes from MiniTest)
  if !BUILTIN_ASSERTIONS.include?(:assert_empty)
    def assert_empty(actual, message = nil)
      message = build_message(message, "<?> is not empty", actual)
      assert_block message do
        actual.empty?
      end
    end
  end

  def fixture_path(basename)
    "test/fixtures/#{basename}"
  end

  def capture_stderr
    $stderr = StringIO.new
    yield
    $stderr.rewind && $stderr.read
  ensure
    $stderr = STDERR
  end

  # The path to the current ruby interpreter. Adapted from Rake's FileUtils.
  def ruby_path
    ext = ((RbConfig::CONFIG['ruby_install_name'] =~ /\.(com|cmd|exe|bat|rb|sh)$/) ? "" : RbConfig::CONFIG['EXEEXT'])
    File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'] + ext).sub(/.*\s.*/m, '"\&"')
  end

  # Returns the name of the currently-running Test::Unit test method. This
  # simply scans the call stack for the first method name starting with
  # "test_". (TODO: is there a first-class way to retrieve this in Test::Unit?)
  def current_test_name
    caller.detect { |line| line =~ /:\d+:in `(test_\w+)'$/ }
    $1.to_sym
  end

  def current_ruby_opts
    ruby_opts = []
    ruby_opts << "-w" if defined?($-w) && $-w

    # When you start JRuby with --debug, it does this:
    #
    #   # src/org/jruby/util/cli/ArgumentProcessor.java:371
    #   RubyInstanceConfig.FULL_TRACE_ENABLED = true;
    #   config.setCompileMode(RubyInstanceConfig.CompileMode.OFF);
    #
    # This checks the same settings from Rubyland. See our Rakefile for
    # some background on --debug.
    # TODO: is there a good way to retrieve the command-line options
    # used to start JRuby? --debug doesn't seem to have an analogue of
    # $-w, $-d, etc.
    if RUBY_PLATFORM == "java" &&
       JRuby.runtime.instance_config.class.FULL_TRACE_ENABLED &&
       JRuby.runtime.instance_config.compile_mode.to_s == "OFF"
      ruby_opts << "--debug"
    end

    ruby_opts
  end

  def remove_warnings_from_gems_and_stdlib(string)
    code_paths = [RbConfig::CONFIG["libdir"],
                  File.expand_path(File.join(File.dirname(__FILE__), "vendor")),
                  Gem.path].flatten
    splitter = string.respond_to?(:lines) ? :lines : :to_a
    string.send(splitter).reject { |line|
      line.strip.empty? ||
      code_paths.any? { |path| line =~ /^#{Regexp.escape(path)}.+:\d+:? warning:/ }
    }.join
  end

  # Sets several expectations (using Mocha) that a real HTTP request makes it
  # past FakeWeb to the socket layer. You can use this when you need to check
  # that a request isn't handled by FakeWeb.
  def setup_expectations_for_real_request(options = {})
    # Socket handling
    if options[:port] == 443
      socket = mock("SSLSocket")
      OpenSSL::SSL::SSLSocket.expects(:===).with(socket).returns(true).at_least_once
      OpenSSL::SSL::SSLSocket.expects(:new).with(socket, instance_of(OpenSSL::SSL::SSLContext)).returns(socket).at_least_once
      socket.stubs(:sync_close=).returns(true)

      if RUBY_VERSION <= "2.4.0"
        socket.expects(:connect).with().at_least_once
      end

      if RUBY_VERSION >= "2.0.0" && RUBY_PLATFORM != "java"
        socket.expects(:session).with().at_least_once
      end
    else
      socket = mock("TCPSocket")
      Socket.expects(:===).with(socket).at_least_once.returns(true)
    end

    # Net::HTTP#connect now sets TCP_NODELAY after opening the socket. See ruby-core:56158.
    if RUBY_VERSION >= "2.1.0"
      socket.stubs(:setsockopt).returns(0)
    end

    if RUBY_VERSION >= "2.0.0"
      TCPSocket.expects(:open).with(options[:host], options[:port], nil, nil).returns(socket).at_least_once
    else
      TCPSocket.expects(:open).with(options[:host], options[:port]).returns(socket).at_least_once
    end

    socket.stubs(:closed?).returns(false)
    socket.stubs(:close).returns(true)
    socket.stubs(:connect_nonblock).returns(true)

    # Request/response handling
    request_parts = ["#{options[:method]} #{options[:path]} HTTP/1.1", "Host: #{options[:host]}"]
    socket.expects(:write).with(all_of(includes(request_parts[0]), includes(request_parts[1]))).returns(100)
    if !options[:request_body].nil?
      socket.expects(:write).with(options[:request_body]).returns(100)
    end

    # MRI's Net::HTTP switched from #sysread to #read_nonblock in
    # 1.9.2; although subsequent JRuby releases reported version
    # numbers later than 1.9.2p0 when running in 1.9-mode, JRuby
    # didn't switch until 1.7.4 (a.k.a. 1.9.3p392 in 1.9-mode):
    # https://github.com/jruby/jruby/commit/d04857cb0f.
    if RUBY_PLATFORM == "java" && ((RUBY_VERSION == "1.9.3" && RUBY_PATCHLEVEL >= 392) || RUBY_VERSION > "1.9.3")
      read_method = :read_nonblock
    elsif RUBY_PLATFORM != "java" && RUBY_VERSION >= "1.9.2"
      read_method = :read_nonblock
    else
      read_method = :sysread
    end

    socket.expects(read_method).at_least_once.returns("HTTP/1.1 #{options[:response_code]} #{options[:response_message]}\nContent-Length: #{options[:response_body].length}\n\n#{options[:response_body]}").then.raises(EOFError)
  end


  # A helper that calls #setup_expectations_for_real_request for you, using
  # defaults for our commonly used test request to images.apple.com.
  def setup_expectations_for_real_apple_hot_news_request(options = {})
    defaults = { :host => "images.apple.com", :port => 80, :method => "GET",
                 :path => "/main/rss/hotnews/hotnews.rss",
                 :response_code => 200, :response_message => "OK",
                 :response_body => "<title>Apple Hot News</title>" }
    setup_expectations_for_real_request(defaults.merge(options))
  end

end

Test::Unit::TestCase.send(:include, FakeWebTestHelper)
