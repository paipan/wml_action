# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wml_action/version'

Gem::Specification.new do |spec|
  spec.name          = "wml_action"
  spec.version       = WmlAction::VERSION
  spec.authors       = ["Pancho"]
  spec.email         = ["paul.schko@gmail.com"]
  spec.description   = %q{Parse wml and wml action files}
  spec.summary       = %q{Parse wml and wml action files}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "thor"
end
