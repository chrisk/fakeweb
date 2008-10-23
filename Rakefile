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
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

spec = Gem::Specification.new do |s| 
  s.add_dependency('rake')
  s.add_dependency('rcov')
  s.name = "FakeWeb" 
  s.version = "1.1.2.3"
  s.author = "Blaine Cook" 
  s.email = "romeda@gmail.com" 
  s.homepage = "http://fakeweb.rubyforge.org/" 
  s.platform = Gem::Platform::RUBY 
  s.summary = "A test helper that makes it simple to test HTTP interaction" 
  s.files = FileList["{test,lib}/**/*", '[A-Z]*'].exclude("rdoc", ".svn").to_a 
  s.require_path = "lib" 
  s.test_files = Dir.glob("test/test_*.rb")
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README", "COPYING"] 
  s.rubyforge_project = "fakeweb"
end 

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.gem_spec = spec
  pkg.need_tar = true 
  pkg.need_zip = true
end

desc "Default Task"
task :default => [:tests]

desc "Run All Tests"
Rake::TestTask.new :tests do |test|
  test.test_files = ["test/**/*.rb"]
  test.verbose = true
end

desc "Generate Documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.main = "README"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README", "COPYING", "lib/*.rb")
  rdoc.title = "FakeWeb"
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/**/test*.rb'] 
  t.rcov_opts << "--sort coverage"
end
