require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWebOpenURI < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
  end

  def test_content_for_registered_uri
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    assert_equal 'test example content', FakeWeb.response_for('http://mock/test_example.txt').body
  end
  
  def test_mock_open
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    assert_equal 'test example content', open('http://mock/test_example.txt').read
  end
  
  def test_mock_open_with_string_as_registered_uri
    FakeWeb.register_uri('http://mock/test_string.txt', :string => 'foo')
    assert_equal 'foo', open('http://mock/test_string.txt').string
  end
  
  def test_real_open
    setup_expectations_for_real_apple_hot_news_request
    resp = open('http://images.apple.com/main/rss/hotnews/hotnews.rss')
    assert_equal "200", resp.status.first
    body = resp.read
    assert body.include?('Apple')
    assert body.include?('News')
  end
  
  def test_mock_open_that_raises_exception
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => StandardError)
    assert_raises(StandardError) do
      open('http://mock/raising_exception.txt')
    end
  end

  def test_mock_open_that_raises_an_http_error
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => OpenURI::HTTPError)
    assert_raises(OpenURI::HTTPError) do
      open('http://mock/raising_exception.txt')
    end
  end

  def test_mock_open_that_raises_an_http_error_with_a_specific_status
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => OpenURI::HTTPError, :status => ['123', 'jodel'])
    exception = assert_raises(OpenURI::HTTPError) do
      open('http://mock/raising_exception.txt')
    end
    assert_equal '123', exception.io.code
    assert_equal 'jodel', exception.io.message
  end

  def test_mock_open_with_block
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    open('http://mock/test_example.txt') do |f|
      assert 'test example content', f.readlines
    end
  end
end
