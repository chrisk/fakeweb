# encoding: utf-8

Gem::Specification.new do |s|
  s.name    = "fakeweb"
  s.version = "1.3.0"
  s.authors = ["Chris Kampmeier", "Blaine Cook"]
  s.email   = ["chris@kampers.net", "romeda@gmail.com"]

  s.description = "FakeWeb is a helper for faking web requests in Ruby. It works at a global level, without modifying code or writing extensive stubs."
  s.summary = "A tool for faking responses to HTTP requests"

  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.rdoc"
  ]
  s.files = [
    ".autotest",
     ".gitignore",
     "CHANGELOG",
     "LICENSE.txt",
     "README.rdoc",
     "Rakefile",
     "fakeweb.gemspec",
     "lib/fake_web.rb",
     "lib/fake_web/ext/net_http.rb",
     "lib/fake_web/registry.rb",
     "lib/fake_web/responder.rb",
     "lib/fake_web/response.rb",
     "lib/fake_web/stub_socket.rb",
     "lib/fake_web/utility.rb",
     "lib/fakeweb.rb",
     "test/fixtures/google_response_from_curl",
     "test/fixtures/google_response_with_transfer_encoding",
     "test/fixtures/google_response_without_transfer_encoding",
     "test/fixtures/test_example.txt",
     "test/fixtures/test_txt_file",
     "test/test_allow_net_connect.rb",
     "test/test_deprecations.rb",
     "test/test_fake_authentication.rb",
     "test/test_fake_web.rb",
     "test/test_fake_web_open_uri.rb",
     "test/test_helper.rb",
     "test/test_last_request.rb",
     "test/test_missing_open_uri.rb",
     "test/test_missing_pathname.rb",
     "test/test_other_net_http_libraries.rb",
     "test/test_precedence.rb",
     "test/test_query_string.rb",
     "test/test_regexes.rb",
     "test/test_response_headers.rb",
     "test/test_trailing_slashes.rb",
     "test/test_utility.rb",
     "test/vendor/right_http_connection-1.2.4/History.txt",
     "test/vendor/right_http_connection-1.2.4/Manifest.txt",
     "test/vendor/right_http_connection-1.2.4/README.txt",
     "test/vendor/right_http_connection-1.2.4/Rakefile",
     "test/vendor/right_http_connection-1.2.4/lib/net_fix.rb",
     "test/vendor/right_http_connection-1.2.4/lib/right_http_connection.rb",
     "test/vendor/right_http_connection-1.2.4/setup.rb",
     "test/vendor/samuel-0.2.1/.document",
     "test/vendor/samuel-0.2.1/.gitignore",
     "test/vendor/samuel-0.2.1/LICENSE",
     "test/vendor/samuel-0.2.1/README.rdoc",
     "test/vendor/samuel-0.2.1/Rakefile",
     "test/vendor/samuel-0.2.1/VERSION",
     "test/vendor/samuel-0.2.1/lib/samuel.rb",
     "test/vendor/samuel-0.2.1/lib/samuel/net_http.rb",
     "test/vendor/samuel-0.2.1/lib/samuel/request.rb",
     "test/vendor/samuel-0.2.1/samuel.gemspec",
     "test/vendor/samuel-0.2.1/test/request_test.rb",
     "test/vendor/samuel-0.2.1/test/samuel_test.rb",
     "test/vendor/samuel-0.2.1/test/test_helper.rb",
     "test/vendor/samuel-0.2.1/test/thread_test.rb"
  ]
  s.homepage = "https://github.com/chrisk/fakeweb"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "fakeweb"
  s.test_files = [
    "test/test_allow_net_connect.rb",
     "test/test_deprecations.rb",
     "test/test_fake_authentication.rb",
     "test/test_fake_web.rb",
     "test/test_fake_web_open_uri.rb",
     "test/test_helper.rb",
     "test/test_last_request.rb",
     "test/test_missing_open_uri.rb",
     "test/test_missing_pathname.rb",
     "test/test_other_net_http_libraries.rb",
     "test/test_precedence.rb",
     "test/test_query_string.rb",
     "test/test_regexes.rb",
     "test/test_response_headers.rb",
     "test/test_trailing_slashes.rb",
     "test/test_utility.rb",
     "test/vendor/right_http_connection-1.2.4/lib/net_fix.rb",
     "test/vendor/right_http_connection-1.2.4/lib/right_http_connection.rb",
     "test/vendor/right_http_connection-1.2.4/setup.rb",
     "test/vendor/samuel-0.2.1/lib/samuel/net_http.rb",
     "test/vendor/samuel-0.2.1/lib/samuel/request.rb",
     "test/vendor/samuel-0.2.1/lib/samuel.rb",
     "test/vendor/samuel-0.2.1/test/request_test.rb",
     "test/vendor/samuel-0.2.1/test/samuel_test.rb",
     "test/vendor/samuel-0.2.1/test/test_helper.rb",
     "test/vendor/samuel-0.2.1/test/thread_test.rb"
  ]

  s.add_development_dependency "mocha", [">= 0.9.5"]
  s.add_development_dependency "rake",  ["~> 10.0"]

  if RUBY_PLATFORM == "java"
    s.add_development_dependency "jruby-openssl", ["~> 0.8"]
  end
end
