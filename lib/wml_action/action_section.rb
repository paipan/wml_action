require 'wml_action/log'
require 'set'

module WmlAction
  class ActionSection
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
    # TODO Filter should be using Set
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
      when WmlAction::ActionSection::Action then @actions<<content
      when WmlAction::ActionSection::Attribute then @keys.merge!( Hash[*content] )
      when WmlAction::ActionSection::Macro then @macros.add( content.value )
      when WmlAction::ActionSection::Filter then @filter.merge!( Hash[*content] )
      when WmlAction::ActionSection then @subs.push(content)
      else raise TypeError.new("Can not add #{content.class}: #{content} to a ActionSection")
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

    def applyActionSection(section)
      return if @name != section.name
      if not @filter.empty? then
        @filter.each_key do |key|
          return if not section.keys.has_key?(key)
          return if section.keys[key] != @filter[key]
        end
      end
      log.info"Applying [#{@name}] action section to [#{section.name}] with filter: #{@filter.to_a.join('=')}" 
      @keys.each_pair do |key,value|
        log.debug "Processing key: #{key}=#{value}"
        section.keys.store(key,value)
      end
      @macros.each do |macro|
        log.debug "Adding macro: #{macro}"
        section.macros<<(macro)
      end
      @subs.each do |act_sub|
        section.subs.each do |sub|
          act_sub.applyActionSection(sub)
        end
      end
      @actions.each do |a|
        case a.action
        when '+' then section << a.object.clone
        when '-' then delete( section, a.object )
        else raise NoMethodError.new("Don't know how to do#{a.action}")
        end
      end
    end

    def delete(section,content)
      case content
      when ActionSection then section.subs.delete_if { |s| s.match?( content.filter ) }
      when Macro then section.macros.delete(content.value)
      end
    end

    def match?( filter )
      return true if filter.empty?
      filter.each_key do |key|
        return false unless @keys.key?(key)
        return false if @keys[key] != @filter[key]
      end
      return true
    end

  end

end
