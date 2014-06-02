require "wml_action/section"

module WmlAction

  class Document

    attr_reader :root

    def initialize(root_section)
      @root = root_section
    end

    def self.from_file(filename)
      root = WmlAction::WmlParser.new.parse_file(filename)
      #TODO file exceptions
      WmlAction::Document.new(root)
    end

  end

end
