require 'test_helper'

class TestRegisteringWithIO < Test::Unit::TestCase

  def test_registering_a_file_handle_without_transfer_encoding
    file = File.new(fixture_path("google_response_without_transfer_encoding"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_registering_a_file_handle_with_transfer_encoding
    file = File.new(fixture_path("google_response_with_transfer_encoding"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_registering_a_file_handle_from_curl
    file = File.new(fixture_path("google_response_from_curl"))
    FakeWeb.register_uri(:get, "http://google.com", :response => file)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

end
