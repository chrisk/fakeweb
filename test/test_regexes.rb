require File.join(File.dirname(__FILE__), "test_helper")

class TestRegexes < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
    @original_allow_net_connect = FakeWeb.allow_net_connect?
  end

  def teardown
    FakeWeb.allow_net_connect = @old_allow_net_conncet
  end

  def fake_pattern_match
    @fake_pattern_match ||= [
      {:pattern => %r|http://www.yahoo.com|, :responders => [FakeWeb::Responder.new(:get, "http://www.yahoo.com", {:response => 'Welcome to Yahoo!'}, 1)], :method => :get},
      {:pattern => %r|https://www.yahoo.com|, :responders => [FakeWeb::Responder.new(:get, "https://www.yahoo.com", {:response => 'Welcome to secure Yahoo!'}, 1)], :method => :get}
    ]
  end

  def test_pattern_map_matches
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert_equal [fake_pattern_match.first], FakeWeb::Registry.instance.send(:pattern_map_matches, :get, "http://www.yahoo.com")
  end

  def test_pattern_map_match
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert_equal fake_pattern_match.first, FakeWeb::Registry.instance.send(:pattern_map_match, :get, "http://www.yahoo.com")
  end

  def test_register_uri_pattern
    FakeWeb.register_uri(%r|http://mock/test_example/\d+|, :string => "example")
    assert FakeWeb.registered_uri?('http://mock/test_example/25')
  end

  def test_pattern_map_can_find_matches
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert FakeWeb::Registry.instance.send(:pattern_map_matches?, :get, "http://www.yahoo.com")
  end

  def test_pattern_map_can_find_matches_with_port
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert FakeWeb::Registry.instance.send(:pattern_map_matches?, :get, "http://www.yahoo.com:80")
  end

  def test_pattern_map_can_find_matches_with_port_and_trailing_slash
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert FakeWeb::Registry.instance.send(:pattern_map_matches?, :get, "http://www.yahoo.com:80/")
  end

  def test_pattern_map_can_find_matches_with_https_port
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert FakeWeb::Registry.instance.send(:pattern_map_matches?, :get, "https://www.yahoo.com:443")
  end

  def test_pattern_map_can_find_matches_with_https_port_and_trailing_slash
    FakeWeb::Registry.any_instance.stubs(:pattern_map).returns(fake_pattern_match)
    assert FakeWeb::Registry.instance.send(:pattern_map_matches?, :get, "https://www.yahoo.com:443/")
  end

  def test_registering_with_overlapping_regexes_uses_first_registered
    FakeWeb.register_uri(:get, %r|http://example\.com/|, :string => "first")
    FakeWeb.register_uri(:get, %r|http://example\.com/a|, :string => "second")
    response = Net::HTTP.start("example.com") { |query| query.get('/a') }
    assert_equal "first", response.body
  end

  def test_registry_does_not_find_using_mismatched_protocols_or_ports_when_registered_with_both
    FakeWeb.register_uri(:get, %r|http://www.yahoo.com:80|, :response => "Welcome to Yahoo!")
    assert !FakeWeb.registered_uri?(:get, "https://www.yahoo.com:80")
    assert !FakeWeb.registered_uri?(:get, "http://www.yahoo.com:443")
  end

  def test_registry_matches_using_mismatched_port_when_registered_without
    FakeWeb.register_uri(:get, %r|http://www.yahoo.com|, :response => "Welcome to Yahoo!")
    assert FakeWeb.registered_uri?(:get, "http://www.yahoo.com:80")
    assert FakeWeb.registered_uri?(:get, "http://www.yahoo.com:443")
    assert FakeWeb.registered_uri?(:get, "http://www.yahoo.com:12345")
    assert !FakeWeb.registered_uri?(:get, "https://www.yahoo.com:443")
    assert !FakeWeb.registered_uri?(:get, "https://www.yahoo.com")
  end

  def test_registry_matches_using_any_protocol_and_port_when_registered_without_protocol_or_port
    FakeWeb.register_uri(:get, %r|www.example.com|, :response => "example")
    assert FakeWeb.registered_uri?(:get, "http://www.example.com")
    assert FakeWeb.registered_uri?(:get, "http://www.example.com:80")
    assert FakeWeb.registered_uri?(:get, "http://www.example.com:443")
    assert FakeWeb.registered_uri?(:get, "https://www.example.com")
    assert FakeWeb.registered_uri?(:get, "https://www.example.com:80")
    assert FakeWeb.registered_uri?(:get, "https://www.example.com:443")
  end

end
