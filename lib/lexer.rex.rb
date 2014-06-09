#--
# This file is automatically generated. Do not modify it.
# Generated by: oedipus_lex version 2.3.0.
# Source: lib/lexer.rex
#++


require "racc/parser"

module WMLAction

class Parser < Racc::Parser
  require 'strscan'

  OTAG    = /\[(\w+)\]/
  CTAG    = /\[\/(\w+)\]/
  ATTR    = /(\w+)=/
  ANUMBER = /-?\d+/
  ASTR    = /"[^"]*"/
  MACRO   = /\{.+\}/
  APLAIN  = /.+/
  SLASH   = /\//
  COMMENT = /\#.*$/
  BLANK   = /[ \t]+/

  class ScanError < StandardError ; end

  attr_accessor :lineno
  attr_accessor :filename
  attr_accessor :ss
  attr_accessor :state

  alias :match :ss

  def matches
    m = (1..9).map { |i| ss[i] }
    m.pop until m[-1] or m.empty?
    m
  end

  def action
    yield
  end

  def scanner_class
    StringScanner
  end unless instance_methods(false).map(&:to_s).include?("scanner_class")

  def parse str
    self.ss     = scanner_class.new str
    self.lineno = 1
    self.state  ||= nil

    do_parse
  end

  def parse_file path
    self.filename = path
    open path do |f|
      parse f.read
    end
  end

  def next_token

    token = nil

    until ss.eos? or token do
      token =
        case state
        when nil then
          case
          when text = ss.scan(/#{COMMENT}/) then
            # do nothing
          when text = ss.scan(/#{OTAG}/) then
            action { [:OTAG, match[1]] }
          when text = ss.scan(/#{CTAG}/) then
            action { [:CTAG, match[1]] }
          when text = ss.scan(/#{ATTR}/) then
            action { @state = :INATTR; [:ATTR, match[1]] }
          when text = ss.scan(/#{MACRO}/) then
            action { [:MACRO, text] }
          when text = ss.scan(/#{SLASH}/) then
            action { [:SLASH, text] }
          when text = ss.scan(/\-/) then
            action { [text,text] }
          when text = ss.scan(/\+/) then
            action { [text,text] }
          when text = ss.scan(/./) then
            # do nothing
          when text = ss.scan(/\n/) then
            # do nothing
          else
            text = ss.string[ss.pos .. -1]
            raise ScanError, "can not match (#{state.inspect}): '#{text}'"
          end
        when :INATTR then
          case
          when text = ss.scan(/\n/) then
            action { @state = nil }
          when text = ss.scan(/#{BLANK}/) then
            # do nothing
          when text = ss.scan(/#{ANUMBER}\s+/) then
            action { @state = nil; [:ANUMBER, text.to_i] }
          when text = ss.scan(/#{ASTR}/) then
            action { [:ASTR, text] }
          when text = ss.scan(/#{MACRO}/) then
            action { [:MACRO, text] }
          when text = ss.scan(/_/) then
            action { [:UNDERSC, text] }
          when text = ss.scan(/\+/) then
            action { [text,text] }
          when text = ss.scan(/#{APLAIN}/) then
            action { [:APLAIN, text] }
          else
            text = ss.string[ss.pos .. -1]
            raise ScanError, "can not match (#{state.inspect}): '#{text}'"
          end
        else
          raise ScanError, "undefined state: '#{state}'"
        end # token = case state

      next unless token # allow functions to trigger redo w/ nil
    end # while

    raise "bad lexical result: #{token.inspect}" unless
      token.nil? || (Array === token && token.size >= 2)

    # auto-switch state
    self.state = token.last if token && token.first == :state

    token
  end # def next_token
end # class

  end #module
