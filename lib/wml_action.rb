require "wml_action/version"
require "wml_action/section"
require "wml_action/action_section"

module WmlAction

#$LOG=Logger.new(STDERR)
#$LOG.sev_threshold = Logger::INFO
#
#    if __FILE__ == $0 then
#            if ARGV.count == 2 then
#                    target_name=ARGV[0]
#                    modlist_name=ARGV[1]
#
#                    if not File.exist?(target_name) then
#                            $LOG.fatal "Invalid target file: #{target_name}"
#                            exit
#                    end
#                    if not File.exist?(modlist_name) then
#                            $LOG.fatal "Invalid modlist file: #{modlist_name}"
#                            exit
#                    end
#
#                    target=File.open(target_name)
#                    modlist=File.open(modlist_name)
#                    target_root=Section.new.fromFile(target)
#                    #print target_root.dumpSection
#                    
#                    modlist_root=ActionSection.new.fromFile(modlist)
#                    #modlist_root.dumpSection
#                    
#                    modlist_root.applyActionSection(target_root)
#                    print target_root.dumpSection
#                    
#                    target.close
#                    modlist.close
#            else
#                    $LOG.error "Usage: wml_modifier {target_file} {modlist_file}"
#            end
#    end

end
