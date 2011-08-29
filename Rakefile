require 'rubygems'
require 'rake'

task :check_dependencies do
  begin
    require "bundler"
  rescue LoadError
    abort "FakeWeb uses bundler to manage development dependencies. Install it with `gem install bundler`."
  end
  system("bundle check") || abort
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList["test/**/*.rb"].exclude("test/test_helper.rb", "test/vendor/**/*")
  test.libs << "test"
  test.verbose = false
  test.warning = true
end

task :default => [:check_dependencies, :test]


begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList["test/**/*.rb"].exclude("test/test_helper.rb", "test/vendor/**/*")
    t.libs << "test"
    t.rcov_opts << "--sort coverage"
    t.rcov_opts << "--exclude gems"
    t.warning = true
  end
rescue LoadError
  print "rcov support disabled "
  if RUBY_PLATFORM =~ /java/
    puts "(running under JRuby)"
  else
    puts "(install RCov to enable the `rcov` task)"
  end
end


begin
  require 'sdoc'
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    rdoc.main = "README.rdoc"
    rdoc.rdoc_files.include("README.rdoc", "CHANGELOG", "LICENSE.txt", "lib/*.rb")
    rdoc.title = "FakeWeb 1.3.0 API Documentation"
    rdoc.rdoc_dir = "doc"
    rdoc.template = "direct"
    rdoc.options << "--line-numbers" << "--show-hash" << "--charset=utf-8"
  end
rescue LoadError
  puts "SDoc (or a dependency) not available. Install it with: gem install sdoc"
end
