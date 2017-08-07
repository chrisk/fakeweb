require 'test_helper'

class TestRequestHistory < Test::Unit::TestCase

  def test_request_history_returns_request_stack_class
    assert_instance_of RequestStack, FakeWeb.request_history
  end

  def test_request_history_stacks_requests
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    expected_stack_count = 3
    expected_stack_count.times do
      Net::HTTP.start("example.com") { |http| http.get("/") }
    end

    assert_equal expected_stack_count, FakeWeb.request_history.count
    FakeWeb.request_history.each do |request|
      assert_equal "GET", request.method
      assert_equal "/", request.path
      assert_nil request.body
      assert_nil request.content_length
    end
  end

  def test_request_hitory_stacks_requests_untill_30
    FakeWeb.register_uri(:get, "http://example.com", :status => [200, "OK"])
    40.times do
      Net::HTTP.start("example.com") { |http| http.get("/") }
    end
    assert_equal 30, FakeWeb.request_history.count
  end
end
