
require File.join(File.dirname(__FILE__), "test_helper")

class FakeWebExampleTest < Test::Unit::TestCase
  include FakeWebTestHelper

  def test_request
    FakeWeb.register_uri('http://example.com/test_me', :string => "Hello World!")
    content = Net::HTTP.get(URI.parse('http://example.com/test_me'))
    assert_equal "Hello World!", content
  end

  def test_request_with_response
    FakeWeb.register_uri('http://www.google.com/', :response => `curl -is http://www.google.com/`)
    Net::HTTP.start('www.google.com') do |req|
      response = req.get('/')
      if response.code == 200
        assert_equal "OK", response.message
        assert response.body.include?('<title>Google')
      elsif response.code == 302
        # Google redirects foreign sites to ccTLDs.
        assert_equal "Found", response.message
        assert response.body.include?('The document has moved')
      end
    end
  end

  def test_request_with_custom_status
    FakeWeb.register_uri('http://example.com/', :string => "Nothing to be found 'round here",
                                                :status => ['404', 'Not Found'])
    Net::HTTP.start('example.com') do |req|
      response = req.get('/')
      assert_equal "404", response.code
      assert_equal "Not Found", response.message
      assert_equal "Nothing to be found 'round here", response.body
    end
  end

  def test_open_uri
    FakeWeb.register_uri('http://example.com/', :string => "Hello, World!")
    content = open('http://example.com/').string
    assert_equal "Hello, World!", content
  end

  def test_rotated_response
    FakeWeb.register_uri('http://example.com/', [{:string => "Hello, World!"}, {:string => "Goodbye, Cruel World!"}])

    content = open('http://example.com/').string
    assert_equal "Hello, World!", content

    content = open('http://example.com/').string
    assert_equal "Goodbye, Cruel World!", content
  end
end
