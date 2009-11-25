require 'test_helper'

class TestCurb < Test::Unit::TestCase

  def test_curl_easy_class_perform
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    response = Curl::Easy.perform("http://example.com")
    assert_equal "example", response.body_str
  end

  def test_curl_easy_class_perform_with_different_body
    FakeWeb.register_uri(:get, "http://example.com", :body => "example2")
    response = Curl::Easy.perform("http://example.com")
    assert_equal "example2", response.body_str
  end

  def test_curl_easy_instance_perform
    FakeWeb.register_uri(:get, "http://example.com", :body => "example3")
    curl = Curl::Easy.new("http://example.com")
    assert_equal true, curl.perform
    assert_equal "example3", curl.body_str
  end

  def test_easy_class_perform_with_unregistered_uri_raises
    assert_raise FakeWeb::NetConnectNotAllowedError do
      Curl::Easy.perform("http://example.com")
    end
  end

  def test_easy_instance_perform_with_unregistered_uri_raises
    curl = Curl::Easy.new("http://example.com")
    assert_raise FakeWeb::NetConnectNotAllowedError do
      curl.perform
    end
  end


end