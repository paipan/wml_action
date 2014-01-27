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

            if not File.exist?(target_name) then
                    $LOG.fatal "Invalid target file: #{target_name}"
                    exit
            end
            if not File.exist?(modlist_name) then
                    $LOG.fatal "Invalid modlist file: #{modlist_name}"
                    exit
            end

            target=File.open(target_name)
            modlist=File.open(modlist_name)
            target_root=Section.new.fromFile(target)
            #print target_root.dumpSection
            
            modlist_root=ActionSection.new.fromFile(modlist)
            #modlist_root.dumpSection
            
            modlist_root.applyActionSection(target_root)
            print target_root.dumpSection
            
            target.close
            modlist.close
        end

    end

end
