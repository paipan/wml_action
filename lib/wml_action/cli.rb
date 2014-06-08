require 'thor'
require 'wml_action'

module WmlAction

    class CLI < Thor
      include Log

      class_option :verbose, type: :boolean, aliases: '-v'
      class_option :debug, type: :boolean, aliases: '-d'

        desc "modify SRC DEST", "Modifies a wml"
        def modify(original,modlist)
            log.level=Logger::INFO if options[:verbose]
            log.level=Logger::DEBUG if options[:debug]

            target_name=original
            modlist_name=modlist

            unless File.exist?(target_name)
                    log.fatal "Invalid target file: #{target_name}"
                    exit
            end
            unless File.exist?(modlist_name)
                    log.fatal "Invalid modlist file: #{modlist_name}"
                    exit
            end

            target=Document.from_file(target_name)
            modlist=Document.from_file(modlist_name)

            modlist.root.applySection(target.root)
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
