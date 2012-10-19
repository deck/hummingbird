# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), File.join('lib', 'hummingbird', 'version'))

Gem::Specification.new do |gem|
  gem.name                  = 'hummingbird'
  gem.version               = Hummingbird::VERSION
  gem.license               = 'MIT'
  gem.authors               = ['Jacob Helwig']
  gem.email                 = ['jacob@technosorcery.net']
  gem.description           = %q{Write your DB migrations in SQL and run them, hold the magic.}
  gem.summary               = <<-DESC
No DSL, as little magic as possible.  Write your DB migrations in SQL,
and run them in the order specified by a plan file.
DESC
  gem.homepage              = 'http://github.com/jhelwig/hummingbird'
  gem.executables           = `git ls-tree --name-only -r -z HEAD #{File.join("bin","*")}`.split("\0").map{ |f| File.basename(f) }
  gem.files                 = `git ls-tree --name-only -r -z HEAD`.split("\0")
  gem.test_files            = `git ls-tree --name-only -r -z HEAD #{File.join("test","*")}`.split("\0")
  gem.require_paths         = ['lib']
  gem.required_ruby_version = '>= 1.8.7'

  gem.add_dependency 'sequel'
  gem.add_dependency 'optimism'

  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-minitest'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'yard'
end
