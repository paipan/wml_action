
require "racc/parser"

module WMLAction

class WMLParser < Racc::Parser

options
    #debug

macro
    OTAG    /\[(\w+)\]/
    CTAG    /\[\/(\w+)\]/
    ATTR    /(\w+)=/
    ANUMBER /-?\d+/
    ASTR    /"[^"]*"/
    MACRO   /\{.+\}/
    APLAIN  /.+/
    SLASH   /\//
    COMMENT /\#.*$/

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
    :INATTR /#{MACRO}/          { [:MACRO, text] }
    :INATTR /_/                 { [:UNDERSC, text] }
    :INATTR /\+/                { [text,text] }
    :INATTR /#{APLAIN}/         { [:APLAIN, text] }

            /./
            /\n/

inner
end

end #module
