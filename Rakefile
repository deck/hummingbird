require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList[File.join('test','lib','lowmagic','migrations','**','*_test.rb')]
  t.verbose = true
end

task :default => :test
