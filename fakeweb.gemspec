Gem::Specification.new do |s|
  s.name         = "fakeweb"
  s.version      = "1.2.5"
  s.date         = "2009-07-08"
  s.summary      = "A tool for faking responses to HTTP requests"
  s.description  = "FakeWeb is a helper for faking web requests in Ruby. It works at a global level, without modifying code or writing extensive stubs."
  s.homepage     = "http://github.com/chrisk/fakeweb"
  s.has_rdoc     = true
  s.authors      = ["Chris Kampmeier", "Blaine Cook"]
  s.email        = ["chris@kampers.net", "romeda@gmail.com"]
  s.files        = %w(CHANGELOG LICENSE.txt README.rdoc Rakefile lib lib/fake_web lib/fake_web.rb lib/fake_web/ext lib/fake_web/ext/net_http.rb lib/fake_web/registry.rb lib/fake_web/responder.rb lib/fake_web/response.rb lib/fake_web/stub_socket.rb lib/fake_web/utility.rb lib/fakeweb.rb test test/fixtures test/fixtures/google_response_from_curl test/fixtures/google_response_with_transfer_encoding test/fixtures/google_response_without_transfer_encoding test/fixtures/test_example.txt test/fixtures/test_txt_file test/test_allow_net_connect.rb test/test_deprecations.rb test/test_fake_authentication.rb test/test_fake_web.rb test/test_fake_web_open_uri.rb test/test_helper.rb test/test_missing_open_uri.rb test/test_precedence.rb test/test_query_string.rb test/test_regexes.rb test/test_response_headers.rb test/test_trailing_slashes.rb test/test_utility.rb)
  s.test_files   = %w(test/fixtures test/fixtures/google_response_from_curl test/fixtures/google_response_with_transfer_encoding test/fixtures/google_response_without_transfer_encoding test/fixtures/test_example.txt test/fixtures/test_txt_file test/test_allow_net_connect.rb test/test_deprecations.rb test/test_fake_authentication.rb test/test_fake_web.rb test/test_fake_web_open_uri.rb test/test_helper.rb test/test_missing_open_uri.rb test/test_precedence.rb test/test_query_string.rb test/test_regexes.rb test/test_response_headers.rb test/test_trailing_slashes.rb test/test_utility.rb)
  s.rdoc_options = ["--main", "README.rdoc",
                    "--title", "FakeWeb API Documentation",
                    "--charset", "utf-8",
                    "--line-numbers",
                    "--inline-source"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE.txt", "README.rdoc"]
  s.rubyforge_project = "fakeweb"
  s.add_development_dependency "mocha", ">= 0.9.5"
end