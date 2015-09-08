#!/usr/bin/env ruby

root_path = File.expand_path('.', File.dirname(__FILE__))
require "#{root_path}/detatoko_1line_charasheet"

include Detatoko1LineCharaSheet

puts title_line
ARGV.each { |value| 
  cs = Detatoko1LineCharaSheetElement.new(value)
  puts cs.chara_sheet_line
}

