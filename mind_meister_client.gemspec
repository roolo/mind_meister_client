# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mind_meister_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'mind_meister_client'
  spec.version       = MindMeisterClient::VERSION
  spec.authors       = ['Mailo Svetel']
  spec.email         = ['development@rooland.cz']
  spec.summary       = 'Client for API of web based mind mapping app -- MindMeister'
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'https://github.com/roolo/mind_meister_client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.7'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rspec',    '~> 3.3.0'
end
