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
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    curl = Curl::Easy.new("http://example.com")
    assert_equal true, curl.perform
    assert_equal "example", curl.body_str
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

  def test_body_handler_is_used
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    curl = Curl::Easy.new("http://example.com")
    body = ""
    curl.on_body { |data| body << data; data.length }
    curl.perform
    assert_equal "example", body
    assert_nil curl.body_str
  end

  def test_body_handler_is_preserved
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    curl = Curl::Easy.new("http://example.com")
    body = ""
    curl.on_body { |data| body << data; data.length }
    curl.perform
    assert_equal "example", body
    body = ""
    curl.perform
    assert_equal "example", body
  end

  def test_perform_raises_when_body_handler_returns_wrong_number
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    curl = Curl::Easy.new("http://example.com")
    curl.on_body { |data| 0 }
    exception = assert_raise(Curl::Err::WriteError) { curl.perform }
    assert_equal "Failed writing received data to disk/application", exception.message
  end

  def test_perform_raises_when_body_handler_returns_non_number
    FakeWeb.register_uri(:get, "http://example.com", :body => "example")
    curl = Curl::Easy.new("http://example.com")
    curl.on_body { |data| data }
    warning, line = capture_stderr { curl.perform }, __LINE__
    assert warning.include? "test_curb.rb:#{line}: warning: Curl data handlers should return the number of bytes read as an Integer\n"
  end

end