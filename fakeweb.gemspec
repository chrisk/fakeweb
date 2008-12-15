Gem::Specification.new do |s|
  s.name     = "fakeweb"
  s.version  = "1.2.0"
  s.date     = "2008-12-15"
  s.summary  = "A test helper that makes it simple to test HTTP interaction"
  s.homepage = "http://github.com/chrisk/fakeweb"
  s.has_rdoc = true
  s.authors  = ["Blaine Cook"]
  s.files    = %w(CHANGELOG COPYING README.rdoc Rakefile lib lib/fake_net_http.rb lib/fake_web.rb test test/fixtures test/fixtures/test_example.txt test/fixtures/test_request test/test_examples.rb test/test_fake_web.rb test/test_fake_web_open_uri.rb test/test_query_string.rb)
  s.test_files = %w(test/fixtures test/fixtures/test_example.txt test/fixtures/test_request test/test_examples.rb test/test_fake_web.rb test/test_fake_web_open_uri.rb test/test_query_string.rb)
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["CHANGELOG", "COPYING", "README.rdoc"]
end