#!/usr/bin/env ruby

require 'json'
require 'net/http'

root_path = File.expand_path('.', File.dirname(__FILE__))
require "#{root_path}/lib/string"

module Detatoko1LineCharaSheet
  # 名前項目の文字数(幅)をいくつに設定するか。
  NAME_WIDTH = 16

  # 1行キャラシのタイトル行を出力する
  # @return [String]
  def title_line
    [ '名前'.dispformat(NAME_WIDTH),
      'Lv',
      '体力　気力 ',
      '常行対誘',
      '意感交肉技知',
      'ID  :プレイヤー'
    ].join('|')
  end

  class Detatoko1LineCharaSheetElement
    # 1キャラシ(1行)を作成する各要素を用意するためのクラス
    
    # オンラインキャラクターシートのJSON出力用URL
    CHARA_SHEET_URL = 'http://detatoko-saga.com/character/%d.json'

    # JSON でデータを取り込む
    # @param id [Fixnum] オンラインキャラシの登録ID
    # @return [String] 完成した1行キャラシ
    # ToDo: エラー処理を書く
    def initialize(id)
      @chara_sheet = JSON.parse(Net::HTTP.get(URI.parse(CHARA_SHEET_URL % id)))

      @pcname = pcname
      @level = level
      @hpmp = hpmp
      @timing, @janre = timing_janre
      @footer = footer
    end

    # 1行キャラクターシートを出力する
    # @return [String]
    def chara_sheet_line
      [@pcname, @level, @hpmp, @timing, @janre, @footer].join('|')
    end

    # PC の名前
    # @return [String]
    def pcname
      @chara_sheet['name'].dispformat(NAME_WIDTH)
    end

    # PC のレベル
    # @return [String]
    def level
      unify_dispsize2(@chara_sheet['level'].to_s)
    end

    # 体力・気力
    # @return [String]
    def hpmp
      hpmp = ''
      %w(h m).each { |type|
        hpmp << (@chara_sheet["#{type}p"]['total'].to_s * 2).insert(2, '/')
      }
      hpmp.insert(-6, ' ')
    end

    # スキルタイミング・ジャンル
    # @return [Array<String>] [timing, string] の順番
    def timing_janre
      timing = [0, 2, 1, 0]
      janre = Array.new(6, 0)
      @chara_sheet['skill'].each { |skill|
        timing[skill['timing'].to_i - 1] += 1
        janre[skill['janre'].to_i - 1] += 1
      }
      [timing, janre].map { |array|
        array.map { |value|
          unify_dispsize2(value.to_s).tr('０', '　')
        }.join
      }
    end

    # フッター(キャラクターID・PL名)
    # @return [String]
    def footer
      "#{'% 4d' % @chara_sheet['id']}: #{@chara_sheet['player_name']}"
    end

    # @param [String] num 整数(1桁もしくは2桁)
    # @result [String] 1桁なら全角に、2桁なら半角の整数
    def unify_dispsize2(num)
      case num.size
      when 1
        num.half_to_full
      when 2
        num.full_to_half
      end
    end
    private :unify_dispsize2
  end
end


