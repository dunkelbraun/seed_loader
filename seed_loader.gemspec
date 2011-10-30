# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "seed_loader/version"

Gem::Specification.new do |s|
  s.name        = "seed_loader"
  s.version     = SeedLoader::VERSION
  s.authors     = ["Marc Essindi"]
  s.email       = ["marc.essindi@dunkelbraun.com"]
  s.homepage    = "https://github.com/dunkelbraun/Seed-Loader"
  s.summary     = "YAML seed file loading for Rails."

  s.rubyforge_project = "seed_loader"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">=3.0.3"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"

end
