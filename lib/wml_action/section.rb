require 'wml_action/log'
require 'set'

module WMLAction
  class Section
    include Log

    attr_accessor :name,:subs,:keys,:macros,:filter, :actions

    Attribute = Struct.new(:name, :value) do
      def to_s(indent=0)
        "#{name}=#{value}"
      end
    end

    Macro = Struct.new(:value) do
      def to_s(indent=0,dummy=0)
        value.to_s
      end
    end

    Action = Struct.new(:object, :action) do
      def to_s(indent=0)
        "#{action} #{object.to_s(indent,0)}"
      end
    end

    # TODO Filter should be using Set or Array
    Filter = Struct.new(:name, :value) do
      def to_s(indent=0)
        "/ #{name}=#{value}"
      end
    end

    def initialize(values={})
      @name=values[:name]||""
      @subs=values[:subs]||Array.new
      @keys=values[:keys]||Hash.new
      @macros=values[:macros]||Set.new
      @filter=values[:filter]||Hash.new
      @actions=values[:actions]||Array.new
      load_content( values[:content] ) if values.key? :content
    end

    def <<(content)
      case content
      when Action then @actions<<content
      when Attribute then @keys.merge!( Hash[*content] )
      when Macro then @macros.add( content.value )
      when Filter then @filter.merge!( Hash[*content] )
      when Section then @subs.push(content)
      else raise TypeError.new("Can not add #{content.class}: #{content} to a Section")
      end
      return self
    end

    def load_content(contents)
      contents.each { |c| self<<c }
    end

    def to_s(indent=0,indent_first_line=1)
      i=indent
      t="\t"
      ifl=indent_first_line
      return <<-EOS.gsub(/^\s+\|/, '').gsub(/^$\n/,'')
        |#{t*i*ifl}[#{@name}]
        |#{(@filter.map { |k,v| "#{t*(i+1)}/ #{k}=#{v}" }).join("\n")}
        |#{(@actions.map { |a| "#{t*(i+1)}#{a.to_s(i+1)}" }).join("\n")}
        |#{(@keys.map   { |k,v| "#{t*(i+1)}#{k}=#{v}" }).join("\n")}
        |#{(@macros.map { |m| "#{t*(i+1)}#{m}" }).join("\n")}
        |#{(@subs.map   { |s| "#{s.to_s(i+1)}" }).join("\n")}
        |#{t*i}[/#{@name}]
      EOS
    end

    def merge(other)
      return self unless @name == other.name
      return self unless match?( other.filter )
      log.info "Merging [#{@name}] section with [#{other.name}] with filter: #{other.filter}"
      other.keys.each_pair do |key,value|
        log.debug "Processing key: #{key}=#{value}"
        @keys.store(key,value)
      end
      other.macros.each do |macro|
        log.debug "Adding macro: #{macro}"
        @macros<<(macro)
      end
      other.subs.each do |other_sub|
        @subs.map { |sub| sub.merge(other_sub) }
      end
      other.actions.each do |a|
        case a.action
        when '+' then self << a.object
        when '-' then delete( a.object )
        else raise NoMethodError.new("Don't know what to do with #{a.action} action")
        end
      end
      return self
    end

    def delete(content)
      case content
      when Section then @subs.delete_if { |s| content.name == s.name && s.match?( content.filter ) }
      when Macro then @macros.delete(content.value)
      end
    end

    def match?( filter )
      return true if filter.empty?
      filter.each_key do |key|
        return false unless @keys.key?(key)
        return false if @keys[key] != filter[key]
      end
      return true
    end

  end

end
