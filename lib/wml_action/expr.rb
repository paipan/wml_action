module WMLAction

  class Tag::Expr

    attr_accessor :line

    Var = Struct.new(:name)
    Op = Struct.new(:value)

    def initialize(elements)
      @line = elements
    end

    def ==(other)
        @line==other.line
    end

    def to_s
        @line.to_s
    end

    def <<(other)
        @line=@line+other.line
        return self
    end

    def self.[](*elements)
        new elements
    end

  end

end
