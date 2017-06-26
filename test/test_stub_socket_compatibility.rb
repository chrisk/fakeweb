require 'test_helper'

class TestStubSocketCompatibility < Test::Unit::TestCase
  def test_sending_timeout_accessors_after_starting_session
    # this tests an HTTPS request because #ssl_timeout= raises otherwise
    FakeWeb.register_uri(:get, "https://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 443)
    http.use_ssl = true
    http.get("/")
    timeouts = []
    http.methods.grep(/_timeout=/).each do |setter|
      http.send(setter, 5)
      getter = setter.to_s.sub(/=$/, "")
      timeouts << http.send(getter)
    end
    assert_equal [5], timeouts.uniq
  end

  def test_stub_socket_always_responds_to_read_timeout
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 80)
    http.get("/")
    assert_respond_to http.instance_variable_get(:@socket), :read_timeout=
  end

  def test_stub_socket_only_responds_to_continue_timeout_under_193_or_later
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 80)
    http.get("/")
    socket = http.instance_variable_get(:@socket)
    assert_equal RUBY_VERSION >= "1.9.3", socket.respond_to?(:continue_timeout=)
  end

  def test_stub_socket_responds_to_close_and_always_returns_true
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 80)
    http.get("/")
    socket = http.instance_variable_get(:@socket)
    assert_equal socket.close, true
  end

  def test_stub_socket_tracks_closed_state
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 80)
    http.get("/")
    socket = http.instance_variable_get(:@socket)
    assert !socket.closed?
    socket.close
    assert socket.closed?
  end
end
