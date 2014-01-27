require 'thor'
require 'wml_action'

module WmlAction

    class CLI < Thor

        desc "wml_modifier SRC DEST", "Modifies a wml"
        def wml_modifier(src,dst)
            puts "wml_modifier #{src},#{dst}"
        end

    end

end
