require File.join(File.dirname(__FILE__), "test_helper")

class TestFakeWeb < Test::Unit::TestCase

  def setup
    FakeWeb.allow_net_connect = true
    FakeWeb.clean_registry
  end

  def test_register_uri
    FakeWeb.register_uri('http://mock/test_example.txt', :string => "example")
    assert FakeWeb.registered_uri?('http://mock/test_example.txt')
  end

  def test_register_uri_with_wrong_number_of_arguments
    assert_raises ArgumentError do
      FakeWeb.register_uri("http://example.com")
    end
    assert_raises ArgumentError do
      FakeWeb.register_uri(:get, "http://example.com", "/example", :string => "example")
    end
  end

  def test_registered_uri_with_wrong_number_of_arguments
    assert_raises ArgumentError do
      FakeWeb.registered_uri?
    end
    assert_raises ArgumentError do
      FakeWeb.registered_uri?(:get, "http://example.com", "/example")
    end
  end

  def test_response_for_with_wrong_number_of_arguments
    assert_raises ArgumentError do
      FakeWeb.response_for
    end
    assert_raises ArgumentError do
      FakeWeb.response_for(:get, "http://example.com", "/example")
    end
  end

  def test_register_uri_without_domain_name
    assert_raises URI::InvalidURIError do
      FakeWeb.register_uri('test_example2.txt', File.dirname(__FILE__) + '/fixtures/test_example.txt')
    end
  end

  def test_register_uri_with_port_and_check_with_port
    FakeWeb.register_uri('http://example.com:3000/', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com:3000/')
  end

  def test_register_uri_with_port_and_check_without_port
    FakeWeb.register_uri('http://example.com:3000/', :string => 'foo')
    assert !FakeWeb.registered_uri?('http://example.com/')
  end

  def test_register_uri_with_default_port_for_http_and_check_without_port
    FakeWeb.register_uri('http://example.com:80/', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/')
  end

  def test_register_uri_with_default_port_for_https_and_check_without_port
    FakeWeb.register_uri('https://example.com:443/', :string => 'foo')
    assert FakeWeb.registered_uri?('https://example.com/')
  end

  def test_register_uri_with_no_port_for_http_and_check_with_default_port
    FakeWeb.register_uri('http://example.com/', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com:80/')
  end

  def test_register_uri_with_no_port_for_https_and_check_with_default_port
    FakeWeb.register_uri('https://example.com/', :string => 'foo')
    assert FakeWeb.registered_uri?('https://example.com:443/')
  end

  def test_register_uri_with_no_port_for_https_and_check_with_443_on_http
    FakeWeb.register_uri('https://example.com/', :string => 'foo')
    assert !FakeWeb.registered_uri?('http://example.com:443/')
  end

  def test_register_uri_with_no_port_for_http_and_check_with_80_on_https
    FakeWeb.register_uri('http://example.com/', :string => 'foo')
    assert !FakeWeb.registered_uri?('https://example.com:80/')
  end

  def test_register_uri_for_any_method_explicitly
    FakeWeb.register_uri(:any, "http://example.com/rpc_endpoint", :string => "OK")
    assert FakeWeb.registered_uri?(:get, "http://example.com/rpc_endpoint")
    assert FakeWeb.registered_uri?(:post, "http://example.com/rpc_endpoint")
    assert FakeWeb.registered_uri?(:put, "http://example.com/rpc_endpoint")
    assert FakeWeb.registered_uri?(:delete, "http://example.com/rpc_endpoint")
    assert FakeWeb.registered_uri?(:any, "http://example.com/rpc_endpoint")
    assert FakeWeb.registered_uri?("http://example.com/rpc_endpoint")
  end

  def test_register_uri_for_get_method_only
    FakeWeb.register_uri(:get, "http://example.com/users", :string => "User list")
    assert FakeWeb.registered_uri?(:get, "http://example.com/users")
    assert !FakeWeb.registered_uri?(:post, "http://example.com/users")
    assert !FakeWeb.registered_uri?(:put, "http://example.com/users")
    assert !FakeWeb.registered_uri?(:delete, "http://example.com/users")
    assert !FakeWeb.registered_uri?(:any, "http://example.com/users")
    assert !FakeWeb.registered_uri?("http://example.com/users")
  end

  def test_response_for_with_registered_uri
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    assert_equal 'test example content', FakeWeb.response_for('http://mock/test_example.txt').body
  end

  def test_response_for_with_unknown_uri
    assert_equal nil, FakeWeb.response_for(:get, 'http://example.com/')
  end

  def test_response_for_with_put_method
    FakeWeb.register_uri(:put, "http://example.com", :string => "response")
    assert_equal 'response', FakeWeb.response_for(:put, "http://example.com").body
  end

  def test_response_for_with_any_method_explicitly
    FakeWeb.register_uri(:any, "http://example.com", :string => "response")
    assert_equal 'response', FakeWeb.response_for(:get, "http://example.com").body
    assert_equal 'response', FakeWeb.response_for(:any, "http://example.com").body
  end

  def test_content_for_registered_uri_with_port_and_request_with_port
    FakeWeb.register_uri('http://example.com:3000/', :string => 'test example content')
    Net::HTTP.start('example.com', 3000) do |http|
      response = http.get('/')
      assert_equal 'test example content', response.body
    end
  end

  def test_content_for_registered_uri_with_default_port_for_http_and_request_without_port
    FakeWeb.register_uri('http://example.com:80/', :string => 'test example content')
    Net::HTTP.start('example.com') do |http|
      response = http.get('/')
      assert_equal 'test example content', response.body
    end
  end

  def test_content_for_registered_uri_with_no_port_for_http_and_request_with_default_port
    FakeWeb.register_uri('http://example.com/', :string => 'test example content')
    Net::HTTP.start('example.com', 80) do |http|
      response = http.get('/')
      assert_equal 'test example content', response.body
    end
  end

  def test_content_for_registered_uri_with_default_port_for_https_and_request_with_default_port
    FakeWeb.register_uri('https://example.com:443/', :string => 'test example content')
    http = Net::HTTP.new('example.com', 443)
    http.use_ssl = true
    response = http.get('/')
    assert_equal 'test example content', response.body
  end

  def test_content_for_registered_uri_with_no_port_for_https_and_request_with_default_port
    FakeWeb.register_uri('https://example.com/', :string => 'test example content')
    http = Net::HTTP.new('example.com', 443)
    http.use_ssl = true
    response = http.get('/')
    assert_equal 'test example content', response.body
  end

  def test_content_for_registered_uris_with_ports_on_same_domain_and_request_without_port
    FakeWeb.register_uri('http://example.com:3000/', :string => 'port 3000')
    FakeWeb.register_uri('http://example.com/', :string => 'port 80')
    Net::HTTP.start('example.com') do |http|
      response = http.get('/')
      assert_equal 'port 80', response.body
    end
  end

  def test_content_for_registered_uris_with_ports_on_same_domain_and_request_with_port
    FakeWeb.register_uri('http://example.com:3000/', :string => 'port 3000')
    FakeWeb.register_uri('http://example.com/', :string => 'port 80')
    Net::HTTP.start('example.com', 3000) do |http|
      response = http.get('/')
      assert_equal 'port 3000', response.body
    end
  end

  def test_content_for_registered_uri_with_get_method_only
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://example.com/", :string => "test example content")
    Net::HTTP.start('example.com') do |http|
      assert_equal 'test example content', http.get('/').body
      assert_raises(FakeWeb::NetConnectNotAllowedError) { http.post('/', nil) }
      assert_raises(FakeWeb::NetConnectNotAllowedError) { http.put('/', nil) }
      assert_raises(FakeWeb::NetConnectNotAllowedError) { http.delete('/', nil) }
    end
  end

  def test_content_for_registered_uri_with_any_method_explicitly
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:any, "http://example.com/", :string => "test example content")
    Net::HTTP.start('example.com') do |http|
      assert_equal 'test example content', http.get('/').body
      assert_equal 'test example content', http.post('/', nil).body
      assert_equal 'test example content', http.put('/', nil).body
      assert_equal 'test example content', http.delete('/').body
    end
  end

  def test_content_for_registered_uri_with_any_method_implicitly
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri("http://example.com/", :string => "test example content")
    Net::HTTP.start('example.com') do |http|
      assert_equal 'test example content', http.get('/').body
      assert_equal 'test example content', http.post('/', nil).body
      assert_equal 'test example content', http.put('/', nil).body
      assert_equal 'test example content', http.delete('/').body
    end
  end

  def test_mock_request_with_block
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    Net::HTTP.start('mock') do |http|
      response = http.get('/test_example.txt')
      assert_equal 'test example content', response.body
    end
  end

  def test_mock_request_with_undocumented_full_uri_argument_style
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    Net::HTTP.start('mock') do |query|
      response = query.get('http://mock/test_example.txt')
      assert_equal 'test example content', response.body
    end
  end

  def test_mock_request_with_undocumented_full_uri_argument_style_and_query
    FakeWeb.register_uri('http://mock/test_example.txt?a=b', :string => 'test query content')
    Net::HTTP.start('mock') do |query|
      response = query.get('http://mock/test_example.txt?a=b')
      assert_equal 'test query content', response.body
    end
  end

  def test_mock_post
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    response = nil
    Net::HTTP.start('mock') do |query|
      response = query.post('/test_example.txt', '')
    end
    assert_equal 'test example content', response.body
  end

  def test_mock_post_with_string_as_registered_uri
    response = nil
    FakeWeb.register_uri('http://mock/test_string.txt', :string => 'foo')
    Net::HTTP.start('mock') do |query|
      response = query.post('/test_string.txt', '')
    end
    assert_equal 'foo', response.body
  end

  def test_mock_get_with_request_as_registered_uri
    fake_response = Net::HTTPOK.new('1.1', '200', 'OK')
    FakeWeb.register_uri('http://mock/test_response', :response => fake_response)
    response = nil
    Net::HTTP.start('mock') do |query|
      response = query.get('/test_response')
    end

    assert_equal fake_response, response
  end

  def test_mock_get_with_request_from_file_as_registered_uri
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/google_response_without_transfer_encoding')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert_equal '200', response.code
    assert response.body.include?('<title>Google</title>')
  end

  def test_mock_post_with_request_from_file_as_registered_uri
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/google_response_without_transfer_encoding')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.post('/', '')
    end
    assert_equal "200", response.code
    assert response.body.include?('<title>Google</title>')
  end

  def test_proxy_request
    FakeWeb.register_uri('http://www.example.com/', :string => "hello world")
    FakeWeb.register_uri('http://your.proxy.host/', :string => "lala")
    proxy_addr = 'your.proxy.host'
    proxy_port = 8080

    Net::HTTP::Proxy(proxy_addr, proxy_port).start('www.example.com') do |http|
      response = http.get('/')
      assert_equal "hello world", response.body
    end
  end

  def test_https_request
    FakeWeb.register_uri('https://www.example.com/', :string => "Hello World")
    http = Net::HTTP.new('www.example.com', 443)
    http.use_ssl = true
    response = http.get('/')
    assert_equal "Hello World", response.body
  end

  def test_register_unimplemented_response
    FakeWeb.register_uri('http://mock/unimplemented', :response => 1)
    assert_raises StandardError do
      Net::HTTP.start('mock') { |q| q.get('/unimplemented') }
    end
  end

  def test_real_http_request
    setup_expectations_for_real_apple_hot_news_request

    resp = nil
    Net::HTTP.start('images.apple.com') do |query|
      resp = query.get('/main/rss/hotnews/hotnews.rss')
    end
    assert resp.body.include?('Apple')
    assert resp.body.include?('News')
  end

  def test_real_http_request_with_undocumented_full_uri_argument_style
    setup_expectations_for_real_apple_hot_news_request(:path => 'http://images.apple.com/main/rss/hotnews/hotnews.rss')

    resp = nil
    Net::HTTP.start('images.apple.com') do |query|
      resp = query.get('http://images.apple.com/main/rss/hotnews/hotnews.rss')
    end
    assert resp.body.include?('Apple')
    assert resp.body.include?('News')
  end

  def test_real_https_request
    setup_expectations_for_real_apple_hot_news_request(:port => 443)

    http = Net::HTTP.new('images.apple.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # silence certificate warning
    response = http.get('/main/rss/hotnews/hotnews.rss')
    assert response.body.include?('Apple')
    assert response.body.include?('News')
  end

  def test_real_request_on_same_domain_as_mock
    setup_expectations_for_real_apple_hot_news_request

    FakeWeb.register_uri('http://images.apple.com/test_string.txt', :string => 'foo')

    resp = nil
    Net::HTTP.start('images.apple.com') do |query|
      resp = query.get('/main/rss/hotnews/hotnews.rss')
    end
    assert resp.body.include?('Apple')
    assert resp.body.include?('News')
  end

  def test_mock_request_on_real_domain
    FakeWeb.register_uri('http://images.apple.com/test_string.txt', :string => 'foo')
    resp = nil
    Net::HTTP.start('images.apple.com') do |query|
      resp = query.get('/test_string.txt')
    end
    assert_equal 'foo', resp.body
  end

  def test_mock_post_that_raises_exception
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => StandardError)
    assert_raises(StandardError) do
      Net::HTTP.start('mock') do |query|
        query.post('/raising_exception.txt', 'some data')
      end
    end
  end

  def test_mock_post_that_raises_an_http_error
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => Net::HTTPError)
    assert_raises(Net::HTTPError) do
      Net::HTTP.start('mock') do |query|
        query.post('/raising_exception.txt', '')
      end
    end
  end

  def test_mock_instance_syntax
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    response = nil
    uri = URI.parse('http://mock/test_example.txt')
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.start do
      http.get(uri.path)
    end

    assert_equal 'test example content', response.body
  end

  def test_mock_via_nil_proxy
    response = nil
    proxy_address = nil
    proxy_port = nil
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
    uri = URI.parse('http://mock/test_example.txt')
    http = Net::HTTP::Proxy(proxy_address, proxy_port).new(
              uri.host, (uri.port or 80))
    response = http.start do
      http.get(uri.path)
    end

    assert_equal 'test example content', response.body
  end

  def test_response_type
    FakeWeb.register_uri('http://mock/test_example.txt', :string => "test")
    Net::HTTP.start('mock') do |http|
      response = http.get('/test_example.txt')
      assert_kind_of(Net::HTTPSuccess, response)
    end
  end

  def test_mock_request_that_raises_an_http_error_with_a_specific_status
    FakeWeb.register_uri('http://mock/raising_exception.txt', :exception => Net::HTTPError, :status => ['404', 'Not Found'])
    exception = assert_raises(Net::HTTPError) do
      Net::HTTP.start('mock') { |http| response = http.get('/raising_exception.txt') }
    end
    assert_equal '404', exception.response.code
    assert_equal 'Not Found', exception.response.msg
  end

  def test_mock_rotate_responses
    FakeWeb.register_uri('http://mock/multiple_test_example.txt',
                         [ {:file => File.dirname(__FILE__) + '/fixtures/test_example.txt', :times => 2},
                           {:string => "thrice", :times => 3},
                           {:string => "ever_more"} ])

    uri = URI.parse('http://mock/multiple_test_example.txt')
    2.times { assert_equal 'test example content', Net::HTTP.get(uri) }
    3.times { assert_equal 'thrice',               Net::HTTP.get(uri) }
    4.times { assert_equal 'ever_more',            Net::HTTP.get(uri) }
  end

  def test_mock_request_using_response_with_transfer_encoding_header_has_valid_transfer_encoding_header
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/google_response_with_transfer_encoding')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert_not_nil response['transfer-encoding']
    assert response['transfer-encoding'] == 'chunked'
  end

  def test_mock_request_using_response_without_transfer_encoding_header_does_not_have_a_transfer_encoding_header
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/google_response_without_transfer_encoding')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert !response.key?('transfer-encoding')
  end

  def test_mock_request_using_response_from_curl_has_original_transfer_encoding_header
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/google_response_from_curl')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert_not_nil response['transfer-encoding']
    assert response['transfer-encoding'] == 'chunked'
  end

  def test_txt_file_should_have_three_lines
    FakeWeb.register_uri('http://www.google.com/', :file => File.dirname(__FILE__) + '/fixtures/test_txt_file')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert response.body.split(/\n/).size == 3, "response has #{response.body.split(/\n/).size} lines should have 3"
  end

  def test_requiring_fakeweb_instead_of_fake_web
    require "fakeweb"
  end
end
