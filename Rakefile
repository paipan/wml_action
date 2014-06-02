require "bundler/gem_tasks"
Rake.application.rake_require "oedipus_lex"

task lexer: "lib/lexer.rex.rb"

task parser: [:lexer] do |t|
  ruby "-S racc lib/parser.y"
end

#task :test => [:parser, :lexer] do |t|
#  sh "bundle exec ruby lib/parser.rb lib/sample.cfg"
#end
#
#task default: :test
