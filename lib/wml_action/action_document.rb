require "wml_action/action_section"

module WmlAction

  class ActionDocument

    attr_reader :root

    def initialize(root_section)
      @root = root_section
    end

    def self.from_file(filename)
      root = WmlActionParser.new.parse_file(filename)
      #TODO file exceptions
      ActionDocument.new(root)
    end

  end

end
