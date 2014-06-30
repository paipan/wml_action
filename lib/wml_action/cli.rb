require 'thor'
require 'wml_action'

module WMLAction

  class CLI < Thor
    include Log

    class_option :verbose, type: :boolean, aliases: '-v'
    class_option :debug, type: :boolean, aliases: '-d'

    desc "modify FILE MODS_FILES", "Modifies a WML"
    def modify(target_name,*modlist_names)
      log.level=Logger::INFO if options[:verbose]
      log.level=Logger::DEBUG if options[:debug]

      unless File.exist?(target_name)
        log.fatal "Invalid target file: #{target_name}"
        exit
      end

      if modlist_names.empty?
        log.fatal "Need at least one modlist file"
        exit
      end

      non_exist = modlist_names.clone.delete_if {|f| File.exist? f} 
      unless non_exist.empty?
        log.fatal "Modlist files does not exist: #{non_exist.join(" ")}"
        exit
      end

      target=Document.from_file(target_name)
      modlist_names.each do |name|
        modlist=Document.from_file(name)
        target.root.merge(modlist.root)
      end

      print target.root.to_s
    end

    desc "read FILE", "Reads and outputs a wml"
    def read(filename)
      log.level=Logger::INFO if options[:verbose]
      log.level=Logger::DEBUG if options[:debug]
      d=Document.from_file(filename)
      print d.root.to_s
    end

    desc "action_read FILE", "Reads and outputs an action wml"
    def action_read(filename)
      log.level=Logger::INFO if options[:verbose]
      log.level=Logger::DEBUG if options[:debug]
      d=Document.from_file(filename)
      print d.root.to_s
    end

  end

end
