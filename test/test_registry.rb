require 'test_helper'

class TestUtility < Test::Unit::TestCase

  def test_uri_map_inspect_returns_an_array_of_a_known_uri
    FakeWeb.register_uri(:get,"http://google.com",:status => 200,:body => {})
    assert_equal ["http://google.com/"], FakeWeb::Registry.instance.uri_map.inspect
  end

  def test_uri_map_inspect_returns_an_array_of_known_uris
    FakeWeb.register_uri(:get,"http://google.com",:status => 200,:body => {})
    FakeWeb.register_uri(:get,"http://heroku.com",:status => 200,:body => {})
    assert_equal ["http://heroku.com/","http://google.com/"], FakeWeb::Registry.instance.uri_map.inspect
  end

end
