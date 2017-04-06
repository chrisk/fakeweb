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
    # Mocha 0.11.1 introduced a call to #define_method with a block
    # parameter (like this: define_method { |*args, &blk| ... }),
    # causing a syntax error in 1.8.6. It's still there as of the
    # latest release, 0.13.3. Older versions of Mocha work great,
    # though; 0.9.5 is the oldest I've tested so far.
    s.add_development_dependency "mocha", [">= 0.9.5", "< 0.11.1"] + broken_mocha_spec

    # Rake 0.9.1 had the same issue with 1.8.6, but it was fixed for
    # the next release. Later on, Rake 0.9.6 and 10.0.3 were both
    # released with code using String#end_with?, which only works in
    # 1.8.7+; both times, 1.8.6-compatibility was restored for the
    # next release.
    s.add_development_dependency "rake", [">= 0.8.7", "!= 0.9.1", "!= 0.9.6", "!= 10.0.3"]

  else
    # Otherwise, prefer up-to-date dev tools
    s.add_development_dependency "mocha", ["~> 0.14"] + broken_mocha_spec
    s.add_development_dependency "rake",  ["~> 10.0"]

    # ZenTest (autotest) wants at least RubyGems 1.8, which is 1.8.7+
    # only, as is RDoc, the main dependency of sdoc.
    s.add_development_dependency "ZenTest", ["~> 4.9"]
    s.add_development_dependency "sdoc"
  end


  if RUBY_VERSION >= "1.9.0"
    s.add_development_dependency "simplecov",         ["~> 0.7"]
    s.add_development_dependency "simplecov-console", ["~> 0.1"]

    # SimpleCov depends on multi_json, which as of 1.7.3 prints a
    # warning when the Ruby 1.9 stdlib is the only available backend.
    # See https://github.com/intridea/multi_json/commit/e7438e7ba2.
    s.add_development_dependency "json",              ["~> 1.7"]
    s.add_development_dependency "test-unit",         ["~> 3.2"]
  end


  if RUBY_PLATFORM == "java"
    s.add_development_dependency "jruby-openssl", ["~> 0.8"]
  end
end
