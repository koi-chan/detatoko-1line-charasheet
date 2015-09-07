#!/usr/bin/env ruby

require 'pp'
require 'json'
require 'net/http'

root_path = File.expand_path('.', File.dirname(__FILE__))
require "#{root_path}/lib"

CHARA_SHEET_URL = 'http://detatoko-saga.com/character/%d.json'
chara_line = []

chara_line << [
  '名前　　　',
  'Lv',
  '体力　気力 ',
  '常行対誘',
  '意感交肉技知',
  'ID  :プレイヤー'
].join('|')

ARGV.each { |id|
  result = []

  # JSON 読み込み
#  return 'Error' unless id.class.to_s == 'Fixnum'
  chara_sheet = JSON.parse(Net::HTTP.get(URI.parse(CHARA_SHEET_URL % id)))

  # PC名
  namelong = chara_sheet['name'].dispsize
  result << 
    case namelong
    when 1..9
      chara_sheet['name'] + ' ' * (10 - namelong)
    when 10
      chara_sheet['name']
    else
      chara_sheet['name'].dispsize_cut(10, true)
    end

  # レベル
  result << unify_dispsize2(chara_sheet['level'].to_s)

  # 体力・気力
  hpmp = ''
  %w(h m).each { |type|
    hpmp << (chara_sheet["#{type}p"]['total'].to_s * 2).insert(2, '/')
  }
  result << hpmp.insert(-6, ' ')

  # スキルタイミング・ジャンル
  timing = [0, 2, 1, 0]
  janre = Array.new(6, 0)
  chara_sheet['skill'].each { |skill|
    timing[skill['timing'].to_i - 1] += 1
    janre[skill['janre'].to_i - 1] += 1
  }
  [timing, janre].each { |array|
    str = ''
    array.each { |value|
      str << unify_dispsize2(value.to_s)
    }
    result << str
  }

  # キャラクターID・PL名
  result << "#{'% 4d' % chara_sheet['id']}: #{chara_sheet['player_name']}"

  # 1行になったキャラシを配列に保存
  chara_line << result.join('|')
}

pp chara_line
