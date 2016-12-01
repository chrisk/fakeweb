require 'test_helper'

class TestResponseDelay < Test::Unit::TestCase
  # this doesn't work because it's all the same thread
  #def test_response_delay_timeout
    #FakeWeb.register_uri(:get, "http://example.com", :delay => 2)
    #assert_raise TimeoutError do
      #Net::HTTP.start("example.com") do |http|
        #http.read_timeout = 1
        #http.get("/")
      #end
    #end
  #end

  def test_response_delay_wait
    FakeWeb.register_uri(:get, "http://example.com", :delay => 2, :body => fixture_path("test_example.txt"))
    start_time = Time.now
    response = Net::HTTP.start("example.com") do |http|
      http.get("/")
    end
    end_time = Time.now
    assert (end_time - start_time) > 2.0
    assert_equal "test example content", response.body
  end

  def test_response_delay_timeout
    FakeWeb.register_uri(:get, "http://example.com", :delay => 1, :body => fixture_path("test_example.txt"))
    start_time = Time.now
    response = Net::HTTP.start("example.com") do |http|
      http.get("/")
    end
    end_time = Time.now
    assert (end_time - start_time) < 3.0
    assert_equal "test example content", response.body
  end
end
