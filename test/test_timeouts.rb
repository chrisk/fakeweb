require 'test_helper'

class TestTimeouts < Test::Unit::TestCase
  def test_sending_timeout_accessors_after_starting_session
    # this tests an HTTPS request because #ssl_timeout= raises otherwise
    FakeWeb.register_uri(:get, "https://example.com", :status => [200, "OK"])
    http = Net::HTTP.new("example.com", 443)
    http.use_ssl = true
    http.get("/")
    timeouts = []
    http.methods.grep(/_timeout=/).each do |setter|
      http.send(setter, 5)
      getter = setter.to_s.sub(/=$/, "")
      timeouts << http.send(getter)
    end
    assert_equal [5], timeouts.uniq
  end
end
