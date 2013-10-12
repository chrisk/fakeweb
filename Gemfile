source "https://rubygems.org"
gemspec

# Rubinius 2.0 distributes the standard library as gems
platform :rbx do
  stdlibs = %w(benchmark cgi coverage delegate erb find logger net-http open-uri
               optparse ostruct prettyprint singleton tempfile test-unit tmpdir yaml)
  stdlibs.each { |lib| gem "rubysl-#{lib}", "~> 2.0" }
  gem "psych", "~> 2.0"
end
