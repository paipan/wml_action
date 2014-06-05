require 'logger'
require 'debugger'

$LOG=Logger.new(STDERR)
$LOG.sev_threshold = Logger::INFO

module WmlAction
  class Section
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

    def fromFile(file,section_name="Global")

      $LOG.debug "Setting section name to: #{section_name}"

      @name=section_name

      while not file.eof? do
        line=file.readline

        $LOG.debug "Readed #{line}"

        case line
        when /^\s*$/; next
        when /\s*\[\/(\w+)\]/;
          $LOG.debug "Found exit from: #{$1}"
          if @name != $1 then
            puts "Found exit from #{$1}, expected #{@name}"
            exit
          end
          break
        when /\s*\[(\w+)\]/;  
          $LOG.debug "Found new section: #{$1}" 
          @subs.push(Section.new.fromFile(file,$1))
          next
        when /\s*(\w+)=(.*)/;
          $LOG.debug "Found new key,value pair: #{$1} => #{$2}" 
          key=$1
          value=$2
          #multiline keys are evil
          if line=~/\"/ and not line=~/.*\".*\".*/ then
            value+="\n"
            begin
              line=file.readline
              value+=line
            end until line=~/\"/
            value.chomp!
            $LOG.debug "Found multiline key:\n #{key}=#{value}" 
          end
          @keys.store(key,value)
          next
        when /\s*(\{.*\})/;
          $LOG.debug "Found new macro: #{$1}" 
          @macros.push($1)
          next
        when /\s*(\#.*)/;
          $LOG.debug "Found new misc: #{$1}" 
          @macros.push($1)
          next
        else
          $LOG.fatal "Can't understand \"#{line}\""
          exit
        end
      end

      return self
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
      $LOG.debug "Section name: [#{[@name]}]"
      act_sect.subs.each do |sub|
        $LOG.debug "Section sub: #{sub[:value].name}"
        @subs.push(sub[:value])
      end
      act_sect.keys.each do |key|
        $LOG.debug "Section key: #{key[:value].to_a.join("=")}"
        @keys.update(key[:value])
      end
      act_sect.macros.each do |macro|
        $LOG.debug "Section macro: #{macro[:value]}"
        @macros.push(macro[:value])
      end

      return self
    end
  end
end
