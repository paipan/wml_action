require 'thor'
require 'wml_action'

module WmlAction

    class CLI < Thor
      include Log

        desc "modify SRC DEST", "Modifies a wml"
        def modify(original,modlist)

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
            modlist=ActionDocument.from_file(modlist_name)

            modlist.root.applyActionSection(target.root)
            print target.root.dumpSection

        end

        desc "read FILE", "Reads and outputs a wml"
        def read(filename)
            d=Document.from_file(filename)
            print d.root.dumpSection()
        end

        desc "action_read FILE", "Reads and outputs an action wml"
        def action_read(filename)
            d=ActionDocument.from_file(filename)
            print d.root.dumpSection()
        end

    end

end
