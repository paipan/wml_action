require "wml_action/section"
require "wml_action/parser.tab"

module WMLAction

  class Document

    attr_reader :root

    def initialize(root_section)
      @root = root_section
    end

    def self.from_file(filename)
      root = Parser.new.parse_file(filename)
      #TODO file exceptions
      Document.new(root)
    end

  end

end
