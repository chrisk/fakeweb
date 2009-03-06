require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeAuthentication < Test::Unit::TestCase
  def setup
    FakeWeb.register_uri('http://test:awesome@mock/auth.txt', :string => 'authorized')
    FakeWeb.register_uri('http://dude:radical@mock/auth.txt', :string => 'wrong user')
    FakeWeb.register_uri('http://mock/auth.txt', :string => 'unauthorized')
  end

  def test_register_uri_with_authentication
    FakeWeb.register_uri('http://test:awesome@mock/test_example.txt', :string => "example")
    assert FakeWeb.registered_uri?('http://test:awesome@mock/test_example.txt') 
  end

  def test_register_uri_with_authentication_doesnt_trigger_without
    FakeWeb.register_uri('http://test:awesome@mock/test_example.txt', :string => "example")
    assert !FakeWeb.registered_uri?('http://mock/test_example.txt')
  end

  def test_unauthenticated_request
    http = Net::HTTP.new('mock',80)
    req = Net::HTTP::Get.new('/auth.txt')
    assert_equal http.request(req).body, 'unauthorized'
  end

  def test_authenticated_request
    http = Net::HTTP.new('mock',80)
    req = Net::HTTP::Get.new('/auth.txt')
    req.basic_auth 'test', 'awesome'
    assert_equal http.request(req).body, 'authorized'
  end

  def test_incorrectly_authenticated_request
    http = Net::HTTP.new('mock',80)
    req = Net::HTTP::Get.new('/auth.txt')
    req.basic_auth 'dude', 'radical'
    assert_equal http.request(req).body, 'wrong user'
  end
end
