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


  # Mocha's README says "versions 0.10.2, 0.10.3 & 0.11.0 of the
  # Mocha gem were broken. Please do not use these versions."
  broken_mocha_spec = ["!= 0.11.0", "!= 0.10.3", "!= 0.10.2"]

  if RUBY_VERSION <= "1.8.6"
    # Mocha 0.11.1 introduced a 1.8.6-incompatible |&blk| block, and
    # it's been there ever since (currently 0.13.3).
    s.add_development_dependency "mocha", ["< 0.11.1"] + broken_mocha_spec

    # Rake 0.9.6 and 10.0.3 used String#end_with?, which doesn't exist
    # in 1.8.6; Rake 0.9.1 had an incompatible |&blk| block parameter.
    s.add_development_dependency "rake", [">= 0.8.7", "!= 0.9.6", "!= 10.0.3", "!= 0.9.1"]

  else
    s.add_development_dependency "mocha", ["~> 0.13.3"] + broken_mocha_spec
    s.add_development_dependency "rake",  ["~> 10.0"]
  end

  if RUBY_PLATFORM == "java"
    s.add_development_dependency "jruby-openssl", ["~> 0.8"]
  end
end
