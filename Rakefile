# FakeWeb - Ruby Helper for Faking Web Requests
# Copyright 2006 Blaine Cook <romeda@gmail.com>.
# 
# FakeWeb is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# FakeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with FakeWeb; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

task :default => :test

desc "Run All Tests"
Rake::TestTask.new :test do |test|
  test.test_files = ["test/**/*.rb"]
  test.verbose = true
end

desc "Generate Documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.rdoc", "COPYING", "CHANGELOG", "lib/*.rb")
  rdoc.title = "FakeWeb"
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/**/test*.rb'] 
  t.rcov_opts << "--sort coverage"
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
    spec.gsub! /^(\s* s.(test_)?files \s* = \s* )( \[ [^\]]* \] | %w\( [^)]* \) )/mx do
      assignment = $1
      bunch = $2 ? list.grep(/^test\//) : list
      '%s%%w(%s)' % [assignment, bunch.join(' ')]
    end
      
    File.open(spec_file,   'w') {|f| f << spec }
  end
  File.open('.manifest', 'w') {|f| f << list.join("\n") }
end
