require 'test_helper'

class TestRegisteringWithIO < Test::Unit::TestCase

  def test_registering_a_file_handle_without_transfer_encoding
    file = File.new(fixture_path("google_response_without_transfer_encoding"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_registering_a_file_handle_with_transfer_encoding
    file = File.new(fixture_path("google_response_with_transfer_encoding"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_registering_a_file_handle_from_curl
    file = File.new(fixture_path("google_response_from_curl"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_registering_a_stringio
    stringio = StringIO.new(File.read(fixture_path("google_response_from_curl")))
    FakeWeb.register_uri(:get, "http://google.com", :response => stringio)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_creating_net_buffered_io_directly_with_an_unsupported_underlying_object
    # It's not possible to exercise this code path through an end-user API because
    # FakeWeb::Responder performs an equivalent check on the object before passing
    # it on to Net::BufferedIO. So this is just an internal sanity check.
    string = ""
    Net::BufferedIO.new(string)

    stringio = StringIO.new(File.read(fixture_path("google_response_from_curl")))
    Net::BufferedIO.new(stringio)

    unsupported = Time.now
    assert_raises ArgumentError do
      Net::BufferedIO.new(unsupported)
    end
  end

  def test_creating_net_buffered_io_with_ruby_24_method_signature
    # These keyword arguments were added to BufferedIO.new's params in Ruby 2.4
    call_with_keyword_args = lambda do
      eval <<-RUBY
        Net::BufferedIO.new("", read_timeout: 1, continue_timeout: 1, debug_output: nil)
      RUBY
    end

    if RUBY_VERSION >= "2.4.0"
      # Should not raise
      call_with_keyword_args.call
    elsif RUBY_VERSION >= "2.0.0"
      # From Ruby 2.0 to 2.3, keyword arguments are generally valid syntax, but
      # had not been added to BufferedIO.new's method signature
      assert_raises(ArgumentError) { call_with_keyword_args.call }
    elsif RUBY_VERSION >= "1.9.0"
      # Ruby 1.9 will interpret the arguments as a new-style options hash,
      # which is also not in the method signature
      assert_raises(ArgumentError) { call_with_keyword_args.call }
    else
      # Ruby 1.8 won't know how to parse this, since it had neither new-style
      # hashes nor keyword arguments
      assert_raises(SyntaxError) { call_with_keyword_args.call }
    end
  end
end
