require 'wml_action/log'
require 'set'

module WmlAction
  class ActionSection
    include Log

    attr_accessor :name,:subs,:keys,:macros,:filter, :actions

    @@tab_counter=-1

    Attribute = Struct.new(:name, :value)
    Macro = Struct.new(:value)
    Action = Struct.new(:object, :action)
    # TODO Filter should be using Set
    Filter = Struct.new(:name, :value)

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
    end

    def load_content(contents)
      contents.each { |c| self<<c }
    end

    def dumpSection
      text=String.new
      text+="\t"*@@tab_counter if @@tab_counter >= 0
      text+="[#{@name}]\n" if @name != "Global"
      @filter.each do |filter|
        text+="\t"*(@@tab_counter+1) if @@tab_counter >= 0
        text+="/ " + filter.to_a.join("=") + "\n"
      end
      @keys.each do |key|
        text+="\t"*(@@tab_counter+1) if @@tab_counter >= 0
        text+=key[:action] + " #{key[:value].to_a.join("=")}\n"
      end
      @macros.each do |macro|
        text+="\t"*(@@tab_counter+1) if @@tab_counter >= 0
        text+=macro[:action] + " #{macro[:value]}\n"
      end
      @subs.each do |sub|
        text+=sub[:action] + " "
        @@tab_counter+=1
        text+=sub[:value].dumpSection
      end
      text+="\t"*@@tab_counter if @@tab_counter >= 0
      text+=("[/#{@name}]\n") if @name != "Global"
      @@tab_counter-=1
      return text
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
