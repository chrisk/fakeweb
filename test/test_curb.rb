require 'test_helper'

class TestCurb < Test::Unit::TestCase

  def test_curl_easy_perform
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    response = Curl::Easy.perform("http://example.com")
    assert_equal "example", response.body_str
  end

  def test_curl_easy_perform_2
    FakeWeb.register_uri(:get, "http://example.com", :body => "example2")
    response = Curl::Easy.perform("http://example.com")
    assert_equal "example2", response.body_str
  end

  def test_easy_perform_with_unregistered_uri_raises
    assert_raise FakeWeb::NetConnectNotAllowedError do
      Curl::Easy.perform("http://example.com")
    end
  end

end