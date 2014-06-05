class WmlAction::WmlParser
rule
    target      :
                | wml_doc { $LOG.debug "Found a target" }

    wml_doc     : section { $LOG.debug "Found a doc"; return WmlAction::Section.new(name: "Global", subs: [val[0]]) }

    section     : OTAG contents CTAG { $LOG.debug("Creating section #{val[0]}"); return WmlAction::Section.new(name: val[0], content: val[1]) }

    contents    :                   { return [] }
                | contents content  { $LOG.debug("Append #{val[1]} to #{val[0]}"); return val[0]? val[0].push(val[1]) : [val[1]] }

    content     : section   { $LOG.debug "Found a content subsection #{val[0]}" }
                | attribute
                | MACRO    { $LOG.debug "Found a macro #{val[0]}"; return WmlAction::Section::Macro[val[0]] }

    attribute   : ATTR          { $LOG.debug "Found empty attribute: #{val[0]}"; return WmlAction::Section::Attribute[val[0],''] }
                | ATTR APLAIN   { $LOG.debug "Found plain attribute: #{val[0]}:#{val[1]}"; return WmlAction::Section::Attribute[val[0],val[1]] }
                | ATTR string_val     { $LOG.debug "Found string attribute: #{val[0]}:#{val[1]}"; return WmlAction::Section::Attribute[val[0],val[1]] }
                | ATTR MACRO   { $LOG.debug "Found macro attribute: #{val[0]}:#{val[1]}"; return WmlAction::Section::Attribute[val[0],val[1]] }
                | ATTR ANUMBER  { $LOG.debug "Found numeric attribute: #{val[0]}:#{val[1]}"; return WmlAction::Section::Attribute[val[0],val[1]]  }

    string_val  : ASTR { return " #{val[0]}" }
                | UNDERSC ASTR { return " "+val[0]+" "+val[1] }
                | string_val '+' MACRO { return val[0] + "+" + val[2] }

end

---- header ----
#
# generated by racc
#
require 'lexer.rex'
require 'wml_action/section'

$LOG=Logger.new(STDERR)
$LOG.sev_threshold = Logger::INFO

---- inner ----

---- footer ----

