require 'rubygems'
require 'rake'

task :print_header do
  version_string = `rvm current`.strip
  version_string = RUBY_DESCRIPTION if !$?.success?
  puts "\n# Starting tests using \e[1m#{version_string}\e[0m\n\n"
end


task :check_dependencies do
  begin
    require "bundler"
  rescue LoadError
    abort "Error: FakeWeb uses Bundler to manage development dependencies,\n" +
          "but it's not installed. Try `gem install bundler`.\n\n"
  end
  system("bundle check") || abort
end


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList["test/**/*.rb"].exclude("test/test_helper.rb",
                                                     "test/helpers/**/*",
                                                     "test/vendor/**/*")
  test.libs << "test"
  test.verbose = false
  test.warning = true

  # This quells a JRuby warning from SimpleCov: "tracing (e.g.
  # set_trace_func) will not capture all events without --debug flag".
  # This flag changes two internal options: it enables the runtime's
  # "full-trace" mode, then sets its "compile mode" to OFF so that
  # all code runs through the interpreter. (See test_helper.rb for
  # the Java and Ruby code exposing these.)
  #
  # Note that --debug is unrelated to lots of similar-sounding flags
  # common to many implementations (-d, -D, --debugger, etc.) and so we
  # don't need to set any of those. For details, see JRuby's
  # util/cli/ArgumentProcessor.java.
  test.ruby_opts << "--debug" if RUBY_PLATFORM == "java"
end
Rake::Task["test"].enhance ["test:preflight"]
Rake::Task["test"].clear_comments.add_description <<-DESC.gsub(/^  /, "")
  Run preflight checks, then all tests (default task).

  Set COVERAGE_REPORT=1 to produce an HTML-formatted code-coverage
  report during the run. It will be written to /coverage.
DESC

namespace :test do
  desc "Perform all startup checks without running tests"
  task :preflight => [:print_header, :check_dependencies]
end

task :default => :test


desc "Remove build/test/release artifacts"
task :clean do
  paths = %w(.rbx/ coverage/ doc/ Gemfile.lock log/ pkg/)
  paths.each do |path|
    rm_rf File.join(File.dirname(__FILE__), path)
  end
end

if RUBY_VERSION >= "1.8.7"
  rdoc_options = %w(--show-hash --charset utf-8 --github)
  begin
    require 'sdoc'
    rdoc_options += %w(--format sdoc)
  rescue LoadError
  end
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    rdoc.title    = "FakeWeb 1.3.0 API Documentation"
    rdoc.main     = "README.rdoc"
    rdoc.rdoc_dir = "doc"
    rdoc.options += rdoc_options
    rdoc.rdoc_files.include("README.rdoc", "CHANGELOG", "LICENSE.txt", "lib/*.rb")
  end
else
  warn "Warning: RDoc requires ruby >= 1.8.7; doc tasks disabled"
end
