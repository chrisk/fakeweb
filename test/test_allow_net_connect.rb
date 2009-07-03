require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebAllowNetConnect < Test::Unit::TestCase

  def test_unregistered_requests_are_passed_through_when_allow_net_connect_is_true
    FakeWeb.allow_net_connect = true
    setup_expectations_for_real_apple_hot_news_request
    Net::HTTP.get(URI.parse("http://images.apple.com/main/rss/hotnews/hotnews.rss"))
  end

  def test_raises_for_unregistered_requests_when_allow_net_connect_is_false
    FakeWeb.allow_net_connect = false
    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      Net::HTTP.get(URI.parse("http://example.com/"))
    end
  end

  def test_exception_message_includes_unregistered_request_method_and_uri_but_no_default_port
    FakeWeb.allow_net_connect = false
    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      Net::HTTP.get(URI.parse("http://example.com/"))
    end
    assert exception.message.include?("GET http://example.com/")

    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      http = Net::HTTP.new("example.com", 443)
      http.use_ssl = true
      http.get("/")
    end
    assert exception.message.include?("GET https://example.com/")
  end

  def test_exception_message_includes_unregistered_request_port_when_not_default
    FakeWeb.allow_net_connect = false
    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      Net::HTTP.start("example.com", 8000) { |http| http.get("/") }
    end
    assert exception.message.include?("GET http://example.com:8000/")

    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      http = Net::HTTP.new("example.com", 4433)
      http.use_ssl = true
      http.get("/")
    end
    assert exception.message.include?("GET https://example.com:4433/")
  end

  def test_exception_message_includes_unregistered_request_port_when_not_default_with_path
    FakeWeb.allow_net_connect = false
    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      Net::HTTP.start("example.com", 8000) { |http| http.get("/test") }
    end
    assert exception.message.include?("GET http://example.com:8000/test")

    exception = assert_raise FakeWeb::NetConnectNotAllowedError do
      http = Net::HTTP.new("example.com", 4433)
      http.use_ssl = true
      http.get("/test")
    end
    assert exception.message.include?("GET https://example.com:4433/test")
  end

  def test_question_mark_method_returns_true_after_setting_allow_net_connect_to_true
    FakeWeb.allow_net_connect = true
    assert FakeWeb.allow_net_connect?
  end

  def test_question_mark_method_returns_false_after_setting_allow_net_connect_to_false
    FakeWeb.allow_net_connect = false
    assert !FakeWeb.allow_net_connect?
  end

end


class TestFakeWebAllowNetConnectWithCleanState < Test::Unit::TestCase
  # Our test_helper.rb sets allow_net_connect = false in an inherited #setup
  # method. Disable that here to test the default setting.
  def setup; end
  def teardown; end

  def test_allow_net_connect_is_true_by_default
    assert FakeWeb.allow_net_connect?
  end
end
