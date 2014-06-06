require "bundler/gem_tasks"
require 'rspec/core/rake_task'

Rake.application.rake_require "oedipus_lex"

RSpec::Core::RakeTask.new(:spec)

task lexer: "lib/lexer.rex.rb"

task parser: [:lexer] do |t|
  ruby "-S racc lib/parser.y"
end

task action_parser: [:lexer] do |t|
  ruby "-S racc lib/action_parser.y"
end

#task :test => [:parser, :lexer] do |t|
#  sh "bundle exec ruby lib/parser.rb lib/sample.cfg"
#end
#
#task default: :test
