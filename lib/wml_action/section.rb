require 'wml_action/log'

module WmlAction
  class Section
    include Log

    attr_accessor :name,:subs,:keys,:macros

    @@tab_counter=-1

    Attribute = Struct.new(:name,:value)
    Macro = Struct.new(:value)

    def initialize(values={})
      @name=values[:name]||""
      @subs=values[:subs]||Array.new
      @keys=values[:keys]||Hash.new
      @macros=values[:macros]||Array.new
      #TODO Maybe this should be merge of a sections?
      load_content( values[:content] ) if values.key? :content
    end

    def <<(content)
      case content
      when WmlAction::Section::Attribute then @keys.merge!( Hash[*content] )
      when WmlAction::Section::Macro then @macros<<content.value
      when WmlAction::Section then @subs<<content
      else raise TypeError.new("Can not add #{content.class}: #{content} to a Section")
      end
      self
    end

    def load_content(contents)
      contents.each { |c| self<<c }
    end

    def dumpSection
      text=String.new
      text+="\t"*@@tab_counter if @@tab_counter >= 0
      text+="[#{@name}]\n" if @name != "Global"
      @keys.each_pair do |key,value|
        text+="\t"*(@@tab_counter+1) if @@tab_counter >= 0
        text+="#{key}=#{value}\n"
      end
      @macros.each do |macro|
        text+="\t"*(@@tab_counter+1) if @@tab_counter >= 0
        text+="#{macro}\n"
      end
      @subs.each do |sub|
        @@tab_counter+=1
        text+=sub.dumpSection
      end
      text+="\t"*@@tab_counter if @@tab_counter >= 0
      text+="[/#{@name}]\n" if @name != "Global"
      @@tab_counter-=1
      return text
    end

    def fromActionSection(act_sect)
      @name=act_sect.name
      log.debug "Section name: [#{[@name]}]"
      act_sect.subs.each do |sub|
        log.debug "Section sub: #{sub[:value].name}"
        @subs.push(sub[:value])
      end
      act_sect.keys.each do |key|
        log.debug "Section key: #{key[:value].to_a.join("=")}"
        @keys.update(key[:value])
      end
      act_sect.macros.each do |macro|
        log.debug "Section macro: #{macro[:value]}"
        @macros.push(macro[:value])
      end

      return self
    end
  end
end
