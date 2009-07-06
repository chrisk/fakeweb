puts "Using ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
begin
  require 'rdoc/task'
rescue LoadError
  puts "\nIt looks like you're using an old version of RDoc, but FakeWeb requires a newer one."
  puts "You can try upgrading with `sudo gem install rdoc`.\n\n"
  raise
end

task :default => :test

desc "Run All Tests"
Rake::TestTask.new :test do |test|
  test.test_files = ["test/**/*.rb"]
  test.verbose = false
end

desc "Generate Documentation"
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.rdoc", "CHANGELOG", "LICENSE.txt", "lib/*.rb")
  rdoc.title = "FakeWeb API Documentation"
  rdoc.options << '--line-numbers' << '--charset' << 'utf-8'
end

desc %{Update ".manifest" with the latest list of project filenames. Respect\
.gitignore by excluding everything that git ignores. Update `files` and\
`test_files` arrays in "*.gemspec" file if it's present.}
task :manifest do
  list = Dir['**/*'].sort
  spec_file = Dir['*.gemspec'].first
  list -= [spec_file] if spec_file

  File.read('.gitignore').each_line do |glob|
    glob = glob.chomp.sub(/^\//, '')
    list -= Dir[glob]
    list -= Dir["#{glob}/**/*"] if File.directory?(glob) and !File.symlink?(glob)
    puts "excluding #{glob}"
  end

  if spec_file
    spec = File.read spec_file
    spec.gsub!(/^(\s* s.(test_)?files \s* = \s* )( \[ [^\]]* \] | %w\( [^)]* \) )/mx) do
      assignment = $1
      bunch = $2 ? list.grep(/^test\//) : list
      '%s%%w(%s)' % [assignment, bunch.join(' ')]
    end

    File.open(spec_file,   'w') {|f| f << spec }
  end
  File.open('.manifest', 'w') {|f| f << list.join("\n") }
end

if RUBY_PLATFORM =~ /java/
  puts "rcov support disabled (running under JRuby)."
elsif RUBY_VERSION =~ /^1\.9/
  puts "rcov support disabled (running under Ruby 1.9)"
else
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/**/test*.rb'] 
    t.rcov_opts << "--sort coverage"
    t.rcov_opts << "--exclude gems"
  end
end

spec = eval(File.read(File.join(File.dirname(__FILE__), "fakeweb.gemspec")))
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_gz = true
  pkg.need_zip    = true
end
