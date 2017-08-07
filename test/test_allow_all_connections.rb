require 'test_helper'

class TestAllowAllConnections < Test::Unit::TestCase
  def test_net_http_can_reconnect_on_keep_alive_timeout_when_allow_all_connections
    FakeWeb.allow_net_connect = true
    uri = URI.parse("http://images.apple.com/main/rss/hotnews/hotnews.rss")
    req = Net::HTTP::Get.new(uri)
    Net::HTTP.new(uri.host, uri.port).start do |http|
      http.keep_alive_timeout = 0
      http.request(req)
      http.request(req)
    end
  end if RUBY_VERSION >= "2.0.0"

  def test_allow_all_connections_returns_true_without_registered_uris_or_passthroughs
    FakeWeb.allow_net_connect = true
    assert_equal true, FakeWeb.allow_all_connections?
  end

  def test_allow_all_connections_returns_false_with_passthrough
    FakeWeb.allow_net_connect = "http://example.com"
    assert_equal false, FakeWeb.allow_all_connections?
  end

  def test_allow_all_connections_returns_false_without_allow_net_connect
    FakeWeb.allow_net_connect = false
    assert_equal false, FakeWeb.allow_all_connections?
  end

  def test_allow_all_connections_returns_false_registered_uris
    FakeWeb.allow_net_connect = true
    FakeWeb.register_uri(:get, "http://example.com", :status => [404, "Not Found"])
    assert_equal false, FakeWeb.allow_all_connections?
  end
end
