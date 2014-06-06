require 'wml_action/log'

module WmlAction
  class ActionSection
    include Log

    attr_accessor :name,:subs,:keys,:macros,:filter

    @@tab_counter=-1

    Attribute = Struct.new(:name, :value)
    Macro = Struct.new(:value)
    Action = Struct.new(:object, :action)
    # TODO Filter should be using Set
    Filter = Struct.new(:name, :value)

    def initialize(values={})
      @name=values[:name]||""
      @subs=values[:subs]||Array.new
      @keys=values[:keys]||Array.new
      @macros=values[:macros]||Array.new
      @filter=values[:filter]||Hash.new
      load_content( values[:content] ) if values.key? :content
    end

    def <<(content, action='=')
      case content
      when WmlAction::ActionSection::Action then self.<<(*content)
      when WmlAction::ActionSection::Attribute then @keys.push( {:action => '=', :value => Hash[*content] })
      when WmlAction::ActionSection::Macro then @macros.push( {:action => action, :value => content.value } )
      when WmlAction::ActionSection::Filter then @filter.merge!( Hash[*content] )
      when WmlAction::ActionSection then @subs.push({:action => action, :value => content})
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
      @keys.each do |key|
        log.debug "Processing key: #{key[:value].to_a.join("=")}"
        section.keys.update(key[:value]) if key[:action] =~ /\+|\=/
        #TODO: if action == "-"
      end
      @macros.each do |macro|
        log.debug "Adding macro: #{macro[:value]}"
        section.macros.push(macro[:value]) if macro[:action] =~ /\+|\=/
        section.macros.delete(macro[:value]) if macro[:action] =~ /\-/
      end
      @subs.each do |act_sub|
        section.subs.each do |sub|
          act_sub[:value].removeActionSection(section,sub,act_sub[:value].filter) if act_sub[:action] =~ /\-/ and sub.name==act_sub[:value].name
          act_sub[:value].applyActionSection(sub) if act_sub[:action] =~ /\=/
        end
      end
      @subs.each do |act_sub|
        act_sub[:value].addActionSection(section) if act_sub[:action] =~ /\+/
      end
    end

    def addActionSection(section)
      log.info "Adding [#{@name}] action section to [#{section.name}]"
      section.subs.push(Section.new.fromActionSection(self))
    end

    def removeActionSection(section,sub,filter={})
      log.info "Removing [#{sub.name}] section from [#{section.name}] with filter #{filter.to_a.join('=')}"
      if not filter.empty? then
        filter.each_key do |key|
          return if not sub.keys.has_key?(key)
          return if sub.keys[key] != @filter[key]
        end
      end
      section.subs.delete(sub)
    end

  end

end
