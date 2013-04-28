# encoding: utf-8

Gem::Specification.new do |s|
  s.name              = "fakeweb"
  s.rubyforge_project = "fakeweb"
  s.version           = "1.3.0"
  s.summary           = "A tool for faking responses to HTTP requests"

  s.homepage          = "https://github.com/chrisk/fakeweb"
  s.authors           = ["Chris Kampmeier", "Blaine Cook"]
  s.email             = ["chris@kampers.net", "romeda@gmail.com"]
  s.license           = "MIT"

  s.description = "FakeWeb is a helper for faking web requests in " +
                  "Ruby. It works at a global level, without " +
                  "modifying code or writing extensive stubs."

  root_docs          = %w(CHANGELOG LICENSE.txt README.rdoc)
  s.extra_rdoc_files = root_docs
  s.files            = Dir["lib/**/*.rb"] + root_docs
  s.require_paths    = ["lib"]
  s.rdoc_options     = ["--charset=UTF-8"]

  s.add_development_dependency "mocha", [">= 0.9.5"]
  s.add_development_dependency "rake",  ["~> 10.0"]

  if RUBY_PLATFORM == "java"
    s.add_development_dependency "jruby-openssl", ["~> 0.8"]
  end
end
