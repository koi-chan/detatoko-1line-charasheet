# coding: UTF-8

require 'd1lcs/version'
require 'd1lcs/string'
require 'd1lcs/element'

module D1lcs
  # 名前項目の文字数(半角換算の幅)をいくつに設定するか。
  NAME_WIDTH = 12

  # 1行キャラシのタイトル行を出力する
  # @return [String]
  def self.title_line
    [ '名前'.dispformat(NAME_WIDTH),
      'Lv',
      '体力　気力 旗',
      'クラス　',
      'ポジ',
      'スキル　　　',
      '意感交肉技知',
      'ID  ',
      'プレイヤー'
    ].join('|')
  end
end
