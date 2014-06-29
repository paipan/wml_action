module WMLAction

  class Tag::Expr

    attr_accessor :line

    Var = Struct.new(:name)
    Op = Struct.new(:value)

    def initialize(elements)
      @line = elements
    end

    def result(vars)
        stack=[]
        @line.each do |e|
            case e
            when Var then stack.push vars[e.name]
            when Op then
                x2 = stack.pop
                x1 = stack.pop
                raise SyntaxError.new("Invalid expression #{@line.join(' ')}, no values in stack") unless x1 && x2
                case e.value
                when '+' then stack.push(x1+x2)
                when '-' then stack.push(x1-x2)
                when '*' then stack.push(x1.to_f*x2)
                when '/' then stack.push(x1.to_f/x2)
                else raise NoMethodError.new("No such operation #{e.value}")
                end
            else stack.push e
            end
        end
        raise SyntaxError.new("Invalid expression #{@line.join(' ')}, still have #{stack.size} values") unless stack.size == 1
        stack[0].floor if stack[0].class==Float
        return stack[0]
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
