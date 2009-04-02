require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeAuthentication < Test::Unit::TestCase
  def setup
    FakeWeb.register_uri('http://user:pass@mock/auth.txt', :string => 'authorized')
    FakeWeb.register_uri('http://user2:pass@mock/auth.txt', :string => 'wrong user')
    FakeWeb.register_uri('http://mock/auth.txt', :string => 'unauthorized')
  end

  def test_register_uri_with_authentication_and_pattern
    FakeWeb.register_uri(%r|http://user:pass@mock/example\.\w+|i, :string => "example")
    assert FakeWeb.registered_uri?('http://user:pass@mock/example.txt')
  end

  def test_register_uri_with_authentication
    FakeWeb.register_uri('http://user:pass@mock/test_example.txt', :string => "example")
    assert FakeWeb.registered_uri?('http://user:pass@mock/test_example.txt')
  end

  def test_register_uri_with_authentication_doesnt_trigger_without
    FakeWeb.register_uri('http://user:pass@mock/test_example.txt', :string => "example")
    assert !FakeWeb.registered_uri?('http://mock/test_example.txt')
  end

  def test_register_uri_with_authentication_doesnt_trigger_with_incorrect_credentials
    FakeWeb.register_uri('http://user:pass@mock/test_example.txt', :string => "example")
    assert !FakeWeb.registered_uri?('http://user:wrong@mock/test_example.txt')
  end

  def test_unauthenticated_request
    http = Net::HTTP.new('mock', 80)
    req = Net::HTTP::Get.new('/auth.txt')
    assert_equal http.request(req).body, 'unauthorized'
  end

  def test_authenticated_request
    http = Net::HTTP.new('mock',80)
    req = Net::HTTP::Get.new('/auth.txt')
    req.basic_auth 'user', 'pass'
    assert_equal http.request(req).body, 'authorized'
  end

  def test_incorrectly_authenticated_request
    http = Net::HTTP.new('mock',80)
    req = Net::HTTP::Get.new('/auth.txt')
    req.basic_auth 'user2', 'pass'
    assert_equal http.request(req).body, 'wrong user'
  end
end
