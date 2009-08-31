puts "Using ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fakeweb"
    gem.rubyforge_project = "fakeweb"
    gem.summary = "A tool for faking responses to HTTP requests"
    gem.description = "FakeWeb is a helper for faking web requests in Ruby. It works at a global level, without modifying code or writing extensive stubs."
    gem.email = ["chris@kampers.net", "romeda@gmail.com"]
    gem.authors = ["Chris Kampmeier", "Blaine Cook"]
    gem.homepage = "http://github.com/chrisk/fakeweb"
    gem.add_development_dependency "mocha", ">= 0.9.5"
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
    rubyforge.remote_doc_path = ""
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList["test/**/*.rb"].exclude("test/test_helper.rb")
  test.verbose = false
  test.warning = true
end

task :default => :test


begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList["test/**/*.rb"].exclude("test/test_helper.rb")
    t.rcov_opts << "--sort coverage"
    t.rcov_opts << "--exclude gems"
    t.warning = true
  end
rescue
  print "rcov support disabled "
  if RUBY_PLATFORM =~ /java/
    puts "(running under JRuby)"
  elsif RUBY_VERSION =~ /^1\.9/
    puts "(running under Ruby 1.9)"
  else
    puts "(install RCov to enable the `rcov` task)"
  end
end


begin
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""
    rdoc.main = "README.rdoc"
    rdoc.rdoc_files.include("README.rdoc", "CHANGELOG", "LICENSE.txt", "lib/*.rb")
    rdoc.title = "FakeWeb #{version} API Documentation"
    rdoc.options << '--line-numbers' << '--charset' << 'utf-8'
  end
rescue LoadError
  puts "\nIt looks like you're using an old version of RDoc, but FakeWeb requires a newer one."
  puts "You can try upgrading with `sudo gem install rdoc`.\n\n"
end
