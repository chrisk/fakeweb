# FakeWeb - Ruby Helper for Faking Web Requests
# Copyright 2006 Blaine Cook <romeda@gmail.com>.
# 
# FakeWeb is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# FakeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with FakeWeb; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'fake_web'

class TestFakeWeb < Test::Unit::TestCase

  def setup
    FakeWeb.clean_registry
    FakeWeb.register_uri('http://mock/test_example.txt', :file => File.dirname(__FILE__) + '/fixtures/test_example.txt')
  end

  def test_register_uri
    assert FakeWeb.registered_uri?('http://mock/test_example.txt')
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

  def test_register_uri_with_query_params
    FakeWeb.register_uri('http://example.com/?a=1&b=1', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/?a=1&b=1')
  end

  def test_register_uri_with_query_params_and_check_in_different_order
    FakeWeb.register_uri('http://example.com/?a=1&b=1', :string => 'foo')
    assert FakeWeb.registered_uri?('http://example.com/?b=1&a=1')
  end

  def test_content_for_registered_uri
    assert_equal 'test example content', FakeWeb.response_for('http://mock/test_example.txt').body
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


  def test_mock_request_with_block
    Net::HTTP.start('mock') do |http|
      response = http.get('/test_example.txt')
      assert_equal 'test example content', response.body
    end
  end
 
  def test_mock_post
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
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/test_request')
    response = nil
    Net::HTTP.start('www.google.com') do |query|
      response = query.get('/')
    end
    assert_equal '200', response.code
    assert response.body.include?('<title>Google</title>')
  end

  def test_mock_post_with_request_from_file_as_registered_uri
    FakeWeb.register_uri('http://www.google.com/', :response => File.dirname(__FILE__) + '/fixtures/test_request')
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
    resp = nil
    Net::HTTP.start('images.apple.com') do |query|
      resp = query.get('/main/rss/hotnews/hotnews.rss')
    end
    assert resp.body.include?('Apple')
    assert resp.body.include?('News')
  end

  def test_real_https_request
    http = Net::HTTP.new('images.apple.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # silence certificate warning
    response = http.get('/main/rss/hotnews/hotnews.rss')
    assert response.body.include?('Apple')
    assert response.body.include?('News')
  end

  def test_real_request_on_same_domain_as_mock
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
    
    uri = URI.parse('http://mock/test_example.txt')
    http = Net::HTTP::Proxy(proxy_address, proxy_port).new(
              uri.host, (uri.port or 80))
    response = http.start do
      http.get(uri.path)
    end
    assert_equal 'test example content', response.body
         
  end
  
  def test_reponse_type
    Net::HTTP.start('mock') do |http|
      response = http.get('/test_example.txt', '')
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

  def test_registry_sort_query_params
    assert_equal "a=1&b=2", FakeWeb::Registry.instance.send(:sort_query_params, "b=2&a=1")
  end

  def test_registry_sort_query_params_sorts_by_value_if_keys_collide
    assert_equal "a=1&a=2&b=2", FakeWeb::Registry.instance.send(:sort_query_params, "a=2&b=2&a=1")
  end

  def test_mock_rotate_responses
    FakeWeb.register_uri('http://mock/multiple_test_example.txt', [{ :file => File.dirname(__FILE__) + '/fixtures/test_example.txt',
                                                                     :times => 2 },
                                                                   { :string => "thrice",
                                                                     :times => 3 },
                                                                   { :string => "ever_more" } 
                                                                  ])
    response = nil
    uri = URI.parse('http://mock/multiple_test_example.txt')
    http = Net::HTTP.new(uri.host, uri.port)

    2.times {
      response = http.start do
        http.get(uri.path)
      end
      assert_equal 'test example content', response.body
    }

    3.times {
      response = http.start do
        http.get(uri.path)
      end
      assert_equal 'thrice', response.body
    }

    4.times {
      response = http.start do
        http.get(uri.path)
      end
      assert_equal 'ever_more', response.body
    }
  end
end
