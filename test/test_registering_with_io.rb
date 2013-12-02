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

  def test_registering_a_stringio
    stringio = StringIO.new(File.read(fixture_path("google_response_from_curl")))
    FakeWeb.register_uri(:get, "http://google.com", :response => stringio)
    response = Net::HTTP.start("google.com") { |query| query.get('/') }
    assert response.body.include?("<title>Google</title>")
  end

  def test_creating_net_buffered_io_directly_with_an_unsupported_underlying_object
    # It's not possible to exercise this code path through an end-user API because
    # FakeWeb::Responder performs an equivalent check on the object before passing
    # it on to Net::BufferedIO. So this is just an internal sanity check.
    string = ""
    Net::BufferedIO.new(string)

    stringio = StringIO.new(File.read(fixture_path("google_response_from_curl")))
    Net::BufferedIO.new(stringio)

    unsupported = Time.now
    assert_raises ArgumentError do
      Net::BufferedIO.new(unsupported)
    end
  end
end
