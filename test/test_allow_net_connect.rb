require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebAllowNetConnect < Test::Unit::TestCase

  def test_unregistered_requests_are_passed_through_when_allow_net_connect_is_true
    original_value = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = true

    setup_expectations_for_real_apple_hot_news_request
    Net::HTTP.get(URI.parse("http://images.apple.com/main/rss/hotnews/hotnews.rss"))

    FakeWeb.allow_net_connect = original_value
  end

  def test_raises_for_unregistered_requests_when_allow_net_connect_is_false
    original_value = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = false

    assert_raise RuntimeError do
      Net::HTTP.get(URI.parse('http://example.com/'))
    end

    FakeWeb.allow_net_connect = original_value
  end

  def test_question_mark_method_returns_true_after_setting_allow_net_connect_to_true
    original_value = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = true
    assert FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = original_value
  end

  def test_question_mark_method_returns_false_after_setting_allow_net_connect_to_false
    original_value = FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = false
    assert !FakeWeb.allow_net_connect?
    FakeWeb.allow_net_connect = original_value
  end

  def test_allow_net_connect_is_true_by_default
    assert FakeWeb.allow_net_connect?
  end

end
