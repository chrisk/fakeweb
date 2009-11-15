require File.join(File.dirname(__FILE__), "test_helper")

class TestMissingPathname < Test::Unit::TestCase

  def setup
    super
    @saved_pathname = Pathname
    Object.send(:remove_const, :Pathname)
  end

  def teardown
    super
    Object.const_set(:Pathname, @saved_pathname)
  end

  # FakeWeb supports using Pathname objects where filenames are expected, but
  # Pathname isn't required to use FakeWeb. Make sure everything still works
  # when Pathname isn't in use.

  def test_register_using_body_without_pathname
    filename = File.dirname(__FILE__) + "/fixtures/test_example.txt"
    FakeWeb.register_uri(:get, "http://example.com/", :body => filename)
    Net::HTTP.start("example.com") { |http| http.get("/") }
  end

  def test_register_using_response_without_pathname
    filename = File.dirname(__FILE__) + "/fixtures/google_response_without_transfer_encoding"
    FakeWeb.register_uri(:get, "http://example.com/", :response => filename)
    Net::HTTP.start("example.com") { |http| http.get("/") }
  end

  def test_register_using_unsupported_response_without_pathname
    FakeWeb.register_uri(:get, "http://example.com/", :response => 1)
    assert_raise StandardError do
      Net::HTTP.start("example.com") { |http| http.get("/") }
    end
  end

end
