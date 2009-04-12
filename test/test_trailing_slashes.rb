require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebTrailingSlashes < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
    @original_allow_net_connect = FakeWeb.allow_net_connect?
  end

  def teardown
    FakeWeb.allow_net_connect = @old_allow_net_conncet
  end

  def test_registering_root_without_slash_and_ask_predicate_method_with_slash
    FakeWeb.register_uri(:get, "http://www.example.com", :string => "root")
    assert FakeWeb.registered_uri?(:get, "http://www.example.com/")
  end

  def test_registering_root_without_slash_and_request
    FakeWeb.register_uri(:get, "http://www.example.com", :string => "root")
    response = Net::HTTP.start("www.example.com") { |query| query.get('/') }
    assert_equal "root", response.body
  end

  def test_registering_root_with_slash_and_ask_predicate_method_without_slash
    FakeWeb.register_uri(:get, "http://www.example.com/", :string => "root")
    assert FakeWeb.registered_uri?(:get, "http://www.example.com")
  end

  def test_registering_root_with_slash_and_request
    FakeWeb.register_uri(:get, "http://www.example.com/", :string => "root")
    response = Net::HTTP.start("www.example.com") { |query| query.get('/') }
    assert_equal "root", response.body
  end

  def test_registering_path_without_slash_and_ask_predicate_method_with_slash
    FakeWeb.register_uri(:get, "http://www.example.com/users", :string => "User list")
    assert !FakeWeb.registered_uri?(:get, "http://www.example.com/users/")
  end

  def test_registering_path_without_slash_and_request_with_slash
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.example.com/users", :string => "User list")
    assert_raise FakeWeb::NetConnectNotAllowedError do
      response = Net::HTTP.start("www.example.com") { |query| query.get('/users/') }
    end
  end

  def test_registering_path_with_slash_and_ask_predicate_method_without_slash
    FakeWeb.register_uri(:get, "http://www.example.com/users/", :string => "User list")
    assert !FakeWeb.registered_uri?(:get, "http://www.example.com/users")
  end

  def test_registering_path_with_slash_and_request_without_slash
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.example.com/users/", :string => "User list")
    assert_raise FakeWeb::NetConnectNotAllowedError do
      response = Net::HTTP.start("www.example.com") { |query| query.get('/users') }
    end
  end

end
