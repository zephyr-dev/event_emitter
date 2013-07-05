# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_emitter/version'

Gem::Specification.new do |spec|
  spec.name          = "event_emitter"
  spec.version       = EventEmitter::VERSION
  spec.authors       = ["Alex Babkin"]
  spec.email         = ["ababkin@gmail.com"]
  spec.description   = "gem that allows any rails application to emit all events over UDP"
  spec.summary       = "UDP event emitter for rails application"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails", ">= 3.1"
end
