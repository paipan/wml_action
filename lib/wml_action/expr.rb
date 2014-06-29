module WMLAction

  class Tag::Expr

    attr_accessor :line

    Var = Struct.new(:name)

    def initialize(elements)
      @line = elements
    end

    def <<(other)
        @line=@line+other.line
        return self
    end

    def [](*elements)
        new Array[elements]
    end

  end

end
