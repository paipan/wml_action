require 'thor'
require 'wml_action'

module WmlAction

    class CLI < Thor

        desc "modify SRC DEST", "Modifies a wml"
        def modify(original,modlist)

            $LOG=Logger.new(STDERR)
            $LOG.sev_threshold = Logger::INFO

            target_name=original
            modlist_name=modlist

            unless File.exist?(target_name)
                    $LOG.fatal "Invalid target file: #{target_name}"
                    exit
            end
            unless File.exist?(modlist_name)
                    $LOG.fatal "Invalid modlist file: #{modlist_name}"
                    exit
            end

            modlist=File.open(modlist_name)

            target=WmlAction::Document.from_file(target_name)
            modlist_root=ActionSection.new.fromFile(modlist)

            modlist_root.applyActionSection(target.root)
            print target.root.dumpSection

            modlist.close
        end

        desc "read FILE", "Reads and outputs a wml"
        def read(filename)
            d=WmlAction::Document.from_file(filename)
            print d.root.dumpSection()
        end

    end

end
