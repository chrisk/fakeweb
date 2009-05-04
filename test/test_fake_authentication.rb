require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeAuthentication < Test::Unit::TestCase
  def setup
    FakeWeb.register_uri('http://user:pass@mock/auth.txt', :string => 'authorized')
    FakeWeb.register_uri('http://user2:pass@mock/auth.txt', :string => 'wrong user')
    FakeWeb.register_uri('http://mock/auth.txt', :string => 'unauthorized')
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

  def test_basic_auth_support_is_transparent_to_oauth
    FakeWeb.register_uri(:get, "http://sp.example.com/protected", :string => "secret")

    # from http://oauth.net/core/1.0/#auth_header
    auth_header = <<-HEADER
      OAuth realm="http://sp.example.com/",
            oauth_consumer_key="0685bd9184jfhq22",
            oauth_token="ad180jjd733klru7",
            oauth_signature_method="HMAC-SHA1",
            oauth_signature="wOJIO9A2W5mFwDgiDvZbTSMK%2FPY%3D",
            oauth_timestamp="137131200",
            oauth_nonce="4572616e48616d6d65724c61686176",
            oauth_version="1.0"
    HEADER
    auth_header.gsub!(/\s+/, " ").strip!

    http = Net::HTTP.new("sp.example.com", 80)
    response = nil
    http.start do |request|
      response = request.get("/protected", {"authorization" => auth_header})
    end
    assert_equal "secret", response.body
  end
end
