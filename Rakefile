require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList[File.join('test','lib','hummingbird','**','*_test.rb')]
  t.verbose = true
end

YARD::Rake::YardocTask.new

task :default => :test
