
require "racc/parser"

module WMLAction

class Parser < Racc::Parser

options
    #debug

macro
    OTAG    /\[(\w+)\]/
    CTAG    /\[\/(\w+)\]/
    ATTR    /(\w+)=/
    MACRO   /\{.+\}/
    ANUMBER /-?\d+(\.\d+)?/
    ASTR    /"[^"]*"/
    APLAIN  /.+/
    SLASH   /\//
    COMMENT /\#.*$/
    BACKQ   /\`/
    VAR     /[\w]+/

    BLANK   /[ \t]+/

rule

            /#{COMMENT}/
            /#{OTAG}/           { [:OTAG, match[1]] }
            /#{CTAG}/           { [:CTAG, match[1]] }
            /#{ATTR}/           { @state = :INATTR; [:ATTR, match[1]] }
            /#{MACRO}/          { [:MACRO, text] }
            /#{SLASH}/          { [:SLASH, text] }
            /\-/                { [text,text] }
            /\+/                { [text,text] }

    :INATTR /\n/                { @state = nil }
    :INATTR /#{BLANK}/
    :INATTR /#{ANUMBER}\s+/     { @state = nil; [:ANUMBER, text.to_i] }
    :INATTR /#{ASTR}/           { [:ASTR, text] }
    :INATTR /#{MACRO}/          { [:AMACRO, text] }
    :INATTR /_/                 { [:UNDERSC, text] }
    :INATTR /\+/                { [:APLUS, text] }
    :INATTR /#{BACKQ}/          { @state = :INEXPR; [:BACKQ, text] }
    :INATTR /#{APLAIN}/         { [:APLAIN, text] }

    :INEXPR /#{BACKQ}/          { @state = nil; [:BACKQ, text] }
    :INEXPR /\+/                { [:EPLUS,text] }
    :INEXPR /\*/                { [:EMUL,text] } 
    :INEXPR /\//                { [:EDIV,text] }
    :INEXPR /\-/                { [:EMINUS,text] }
    :INEXPR /\(/                { [text,text] }
    :INEXPR /\)/                { [text,text] }
    :INEXPR /{#ANUMBER}/        { [:ENUM,text.to_f] }
    :INEXPR /#{ASTR}/           { [:ESTR,text] }
    :INEXPR /#{VAR}/            { [:EVAR,text] }

            /./
            /\n/

inner
end

end #module
