Gem::Specification.new do |s|
  s.name     = "fakeweb"
  s.version  = "1.1.2.3"
  s.date     = "2008-10-23"
  s.summary  = "A test helper that makes it simple to test HTTP interaction"
  s.homepage = "http://github.com/chrisk/fakeweb"
  s.has_rdoc = true
  s.authors  = ["Blaine Cook"]
  s.files    = ["CHANGELOG", "COPYING", "fakeweb.gemspec", "Rakefile", "README",
                "setup.rb", "lib/fake_net_http.rb", "lib/fake_web.rb"]
  s.test_files = ["test/fixtures/test_example.txt", "test/fixtures/test_request",
                  "test/test_examples.rb", "test/test_fake_web.rb",
                  "test/test_fake_web_open_uri.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["CHANGELOG", "COPYING", "README"]
end