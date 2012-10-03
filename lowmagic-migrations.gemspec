# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), File.join('lib', 'lowmagic', 'migrations', 'version'))

Gem::Specification.new do |gem|
  gem.name                  = "lowmagic-migrations"
  gem.version               = LowMagic::Migrations::VERSION
  gem.license               = "MIT"
  gem.authors               = ["Jacob Helwig"]
  gem.email                 = ["jacob@technosorcery.net"]
  gem.description           = %q{Write your DB migrations in SQL and run them, hold the magic.}
  gem.summary               = <<-DESC
No DSL, as little magic as possible.  Write your DB migrations in SQL,
and run them in the order specified by a plan file.
DESC
  gem.homepage              = "http://github.com/jhelwig/lowmagic-migrations"
  gem.executables           = `git ls-tree --name-only -r -z HEAD #{File.join("bin","*")}`.split("\0").map{ |f| File.basename(f) }
  gem.files                 = `git ls-tree --name-only -r -z HEAD`.split("\0")
  gem.test_files            = `git ls-tree --name-only -r -z HEAD #{File.join("test","*")}`.split("\0")
  gem.require_paths         = ["lib"]
  gem.required_ruby_version = ">= 1.8.7"

  gem.add_dependency 'sequel'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
end
