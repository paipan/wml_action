# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wml_action/version'

Gem::Specification.new do |spec|
  spec.name          = "wml_action"
  spec.version       = WMLAction::VERSION
  spec.authors       = ["Pancho"]
  spec.email         = ["paul.schko@gmail.com"]
  spec.description   = %q{Parses WML files and performs actions on them}
  spec.summary       = %q{Parse WML and simple WML extension to make modifications to WML files }
  spec.homepage      = "https://github.com/PaiPan/wml_action"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "debugger", "~> 1.6.8"
  spec.add_development_dependency "ruby-prof"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "cucumber"


  spec.add_development_dependency "racc"
  spec.add_development_dependency "oedipus_lex"

  spec.add_dependency "thor"
end
