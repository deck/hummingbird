Gem::Specification.new do |gem|
  gem.name          = "lowmagic-migrations"
  gem.version       = "0.0.1"
  gem.authors       = ["Jacob Helwig"]
  gem.email         = ["jacob@technosorcery.net"]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = "http://github.com/jhelwig/lowmagic-migrations"
  gem.executables   = `git ls-tree -z HEAD #{File.join("bin","*")}`.split("\0").map{ |f| File.basename(f) }
  gem.files         = `git ls-tree -z HEAD`.split("\0")
  gem.test_files    = `git ls-tree -z HEAD #{File.join("spec","*")}`.split("\0")
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
end
