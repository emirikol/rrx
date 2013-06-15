# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reactive/version'

Gem::Specification.new do |gem|
  gem.name          = "rrx"
  gem.version       = Rrx::VERSION
  gem.authors       = ["Daniel Davis"]
  gem.email         = ["shoefish@gmail.com"]
  gem.description   = %q{Reactive Extensions provide an enumerable-like interface to process temporal data(events) with the eash usually reserved for structural Enumerables }
  gem.summary       = %q{Ruby Reactive Extensions}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_runtime_dependency 'eventmachine'
  gem.add_runtime_dependency 'active_support'
end
