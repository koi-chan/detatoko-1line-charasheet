#!/usr/bin/env ruby
# coding: UTF-8

root_path = File.expand_path('.', File.dirname(__FILE__))
require "#{root_path}/detatoko_1line_charasheet"

include Detatoko1LineCharaSheet

puts title_line
ARGV.map { |value|
  value.to_i != 0 ? value.to_i : nil
}.compact.each { |value| 
  cs = Detatoko1LineCharaSheetElement.new(value)
  if cs.error == nil
    puts cs.chara_sheet_line
  else
    puts cs.error
  end
}

