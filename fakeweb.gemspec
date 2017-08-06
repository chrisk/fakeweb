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
  s.rdoc_options     = ["--show-hash --charset=UTF-8"]


  # Mocha's README says "versions 0.10.2, 0.10.3 & 0.11.0 of the Mocha gem were
  # broken. Please do not use these versions."
  exclude_broken_mocha_spec = ["!= 0.11.0", "!= 0.10.3", "!= 0.10.2"]
  if RUBY_VERSION <= "1.8.6"
    # Mocha 0.11.1 introduced a call to #define_method with a block parameter
    # (like this: define_method { |*args, &blk| ... }), causing a syntax error
    # in 1.8.6. It's still there as of the latest release, 0.13.3. Older
    # versions of Mocha work great, though; 0.9.5 is the oldest I've tested so
    # far.
    mocha_spec = [">= 0.9.5", "< 0.11.1"]
  else
    # Otherwise, prefer up-to-date Mocha
    mocha_spec = ["~> 1.0"]
  end
  s.add_development_dependency "mocha", mocha_spec + exclude_broken_mocha_spec


  # * Rake 0.9.1 had the same syntax error on 1.8.6 as Mocha, but it was fixed
  #   for the next release.
  # * Rake 0.9.6 and 10.0.3 were both released with code using String#end_with?,
  #   which only works in 1.8.7+; both times, 1.8.6-compatibility was restored
  #   for the next release.
  # * Rake 10.2 and 10.2.1 removed Ruby 1.8 compatibility; 10.2.2 restored it.
  #   Then Rake 11.0 removed it again for good.
  if RUBY_VERSION <= "1.8.6"
    rake_spec = [">= 0.8.7", "!= 0.9.1", "!= 0.9.6", "!= 10.0.3",
                             "!= 10.2", "!= 10.2.1", "< 11.0"]
  elsif RUBY_VERSION == "1.8.7"
    rake_spec = [">= 0.8.7", "!= 10.2", "!= 10.2.1", "< 11.0"]
  elsif RUBY_VERSION < "1.9.3"
    # Rake's gemspec started requiring Ruby 1.9.3+ as of 11.0
    rake_spec = ["~> 10.0"]
  else
    # Otherwise, prefer up-to-date Rake
    rake_spec = ["~> 12.0"]
  end
  s.add_development_dependency "rake", rake_spec


  if RUBY_VERSION >= "1.8.7"
    # ZenTest (autotest) wants at least RubyGems 1.8, which is 1.8.7+
    # only, as is RDoc, the main dependency of sdoc.
    s.add_development_dependency "ZenTest", ["~> 4.9"]
    s.add_development_dependency "sdoc"

    # RDoc 4.3.0 only works on Ruby 1.9.3+
    if RUBY_VERSION < "1.9.3"
      s.add_development_dependency "rdoc", ["< 4.3.0"]
    end
  end


  # To monitor our tests' code coverage, the SimpleCov gem uses Ruby's built-in
  # Coverage module, which first shipped with Ruby 1.9.0. SimpleCov doesn't work
  # very well on pre-1.9.3, though.
  if RUBY_VERSION >= "1.9.3"
    s.add_development_dependency "simplecov",         ["~> 0.7"]
    s.add_development_dependency "simplecov-console", ["~> 0.1"]

    # SimpleCov depends on multi_json, which as of 1.7.3 prints a
    # warning when the Ruby 1.9 stdlib is the only available backend.
    # See https://github.com/intridea/multi_json/commit/e7438e7ba2.
    s.add_development_dependency "json",              ["~> 1.7"]
  end


  if RUBY_VERSION >= "2.2.0"
    # Test::Unit is no longer distributed with Ruby as of 2.2.0
    s.add_development_dependency "test-unit", ["~> 3.2"]
  end
end
