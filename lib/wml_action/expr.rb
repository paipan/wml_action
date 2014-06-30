module WMLAction

  class Tag::Expr

    attr_accessor :line

    Var = Struct.new(:name) do
      def to_s
        name.to_s
      end
    end

    Op = Struct.new(:value) do
      def to_s
        value.to_s
      end
    end


    def initialize(elements)
      @line = elements
    end

    def result(vars={})
      return '' if @line.empty?
      stack=[]
      @line.each do |e|
        case e
        when Var then stack.push vars[e.name]
        when Op then
          x2 = stack.pop
          x1 = stack.pop
          raise SyntaxError.new("Invalid expression #{dump}, no values in stack") unless x1 && x2
          case e.value
          when '+' then stack.push(x1+x2)
          when '-' then stack.push(x1-x2)
          when '*' then stack.push(x1.to_f*x2)
          when '/' then stack.push(x1.to_f/x2)
          when '.' then stack.push(dot_concat(x1,x2))
          else raise NoMethodError.new("No such operation #{e.value}")
          end
        else stack.push e
        end
      end
      raise SyntaxError.new("Invalid expression #{dump}, still have #{stack.size} values") unless stack.size == 1
      return stack[0].to_i if stack[0].class==Float
      return stack[0]
    end

    def dot_concat(s1,s2)
      quote=/\"/
      m1=s1.match(quote)
      m2=s2.match(quote)
      raise NoMethodError.new("Can not dot-concat #{s1} and #{s2}, all have quotes") if m1 && m2
      return s1.clone.insert(s1.rindex(quote),s2) if m1
      return s2.clone.insert(s2.index(quote)+1,s1) if m2
    end

    def ==(other)
      @line==other.line
    end

    def to_s
      #TODO should revert to infix notation for file output
      # needed to read outputted file
      dump
    end

    def dump
      @line.join(' ')
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
