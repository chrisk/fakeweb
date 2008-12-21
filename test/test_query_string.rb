require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebQueryString < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
  end

  def test_register_uri_with_query_params
    FakeWeb.register_uri('http://example.com/?a=1&b=1', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/?a=1&b=1')
  end

  def test_register_uri_with_query_params_and_check_in_different_order
    FakeWeb.register_uri('http://example.com/?a=1&b=1', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/?b=1&a=1')
  end

  def test_registered_uri_gets_recognized_with_empty_query_params
    FakeWeb.register_uri('http://example.com/', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/?')
  end

  def test_register_uri_with_empty_query_params_and_check_with_none
    FakeWeb.register_uri('http://example.com/?', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/')
  end

  def test_registry_sort_query_params
    assert_equal "a=1&b=2", FakeWeb::Registry.instance.send(:sort_query_params, "b=2&a=1")
  end

  def test_registry_sort_query_params_sorts_by_value_if_keys_collide
    assert_equal "a=1&a=2&b=2", FakeWeb::Registry.instance.send(:sort_query_params, "a=2&b=2&a=1")
  end

end
