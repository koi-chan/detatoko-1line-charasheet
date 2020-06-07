# coding: UTF-8
require 'd1lcs/string'

require 'json'
require 'open-uri'
require 'logger'

module D1lcs
  class Element
    # 1キャラシ(1行)を作成する各要素を用意するためのクラス
    
    # オンラインキャラクターシートのJSON出力用URL
    CHARA_SHEET_URL = 'http://detatoko-saga.com/character/%d.js'

    # エラーが発生した時
    attr_reader :error

    # JSON でデータを取り込む
    # @return [String] 完成した1行キャラシ
    # ToDo: エラー処理を書く
    def initialize(request)
      @logger = Logger.new(STDERR)
      @logger.progname = 'Detatoko1LineCharaSheet'

      unless(@request = check_id(request))
        @error = "キャラクターシートID '#{request}' は無効です"
        return
      end
      if(@chara_sheet = json_parse) == nil
        @error = "キャラクターシートID '#{request}' を読み込めませんでした"
        return
      end
      unless(chara_exist)
        @error = "キャラクターシートID '#{request}' は存在しません"
        return
      end

      @formatted = [pcname,
                    level,
                    hpmp,
                    classes,
                    position_skill,
                    skills,
                    timing_janre,
                    charaID,
                    plname
      ].flatten
    end

    # 1行キャラクターシートを出力する
    # @return [String]
    def chara_sheet_line
      @formatted.clone.fill(nil, 6..6).compact.join('|')
    end
    alias :print :chara_sheet_line
    alias :to_s :chara_sheet_line

    private

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

    # 体力・気力・フラグ
    # @return [String]
    def hpmp
      hpmp = ''
      %w(h m).each { |type|
        hpmp << (@chara_sheet["#{type}p"]['total'].to_s * 2).insert(2, '/')
      }
      hpmp.insert(-6, ' ') << ' 0'
    end

    # クラス
    # @return [String]
    def classes
      @chara_sheet['class'].map { |array| classID_short(array['id']) }.join
    end

    # スキル
    # @return [String]
    def skills
      @chara_sheet['skill'].map { |array| array['name'].chars.first }.join
    end

    # ポジションスキル
    # @return [String]/[nil]
    def position_skill
      if(@chara_sheet['position'])
        positionID_short(@chara_sheet['position']['id'])
      else
        '　　'
      end
    end

    # スキルタイミング・ジャンル
    # @return [Array<String>] [timing, string] の順番
    def timing_janre
      timing = [0, 1, 2, 0]   # 常時, 対応, 行動, 誘発
      janre = Array.new(6, 0) # 意志, 感覚, 交渉, 肉体, 技術, 知識
      @chara_sheet['skill'].each { |skill|
        timing[skill['timing'].to_i] += 1
        janre[skill['janre'].to_i - 1] += 1
      }
      if(@chara_sheet['position'])
        timing[@chara_sheet['position_skill']['timing'].to_i] += 1
        janre[@chara_sheet['position_skill']['janre'].to_i - 1] += 1
      end
      [timing, janre].map { |array|
        array.map { |value|
          unify_dispsize2(value.to_s).tr('０', '　')
        }.join
      }
    end

    # キャラクターID
    # @return [String]
    def charaID
      "#{'% 4d' % @chara_sheet['id']}"
    end

    # プレイヤー名
    # @return [String]
    def plname
      @chara_sheet['player_name']
    end

    # リクエストされたキャラクターIDが正しいか確認する
    # @param [String] request
    # @return [Integer/false]
    def check_id(request)
      id = request.to_i
      case id
      when 0
        false
      else
        id
      end
    end

    # 公式キャラシから JSON をダウンロードし、Hash に変換する
    # @return [Hash]
    def json_parse
      begin
        open(
          URI.parse(CHARA_SHEET_URL % @request),
          'User-Agent' => D1lcs::USER_AGENT
        ) { |f|
          JSON.parse(f.read)
        }
      rescue => e
        @logger.error { ["requestID:#{@request}", e.class, e].join(' : ') }
        nil
      end
    end

    # キャラクターが存在するか調べる
    # @return [Boolean]
    def chara_exist
      @chara_sheet['id'] != 0
    end

    # 半角2文字幅で表示をそろえるため数字の全角・半角を調整する
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

    # クラスIDから全角2文字の短縮形に変換する
    # @param [Integer] class_id JSONから読み込むことを考慮し文字列型
    # @return [String]
    def classID_short(class_id)
      class_ids = ['勇者', '魔王', '姫様', 'ドラ', '戦士', '魔使',
                   '神聖', '暗黒', 'マス', 'モン', '謎　', 'ザコ',
                   'メカ', '商人', '占師',              # フロンティア
                   '忍者', '貴族', '死霊', '異形',      # ダークネス
                   '探偵', '侍　', '祈祷', '偶像'       # ワールドツアー
      ]
      class_ids[class_id.to_i - 1]
    end

    # ポジションIDから全角2文字の短縮形に変換する
    # @param [Integer] position_id JSONから読み込むことを考慮し文字列型
    # @return [String]
    def positionID_short(position_id)
      position_ids = ['冒険', '凡人', '夢追', '神話', '負犬', '守護',
                      '悪党', 'カリ', '修羅', '遊人', '従者', '不明',
                      '迷子', '伝説', '罪人', '傷追', '型破', '裏住',
                      '悪華', '堕落', '幹部', 'トリ', '無能', '支配',
                      '狂才', '要悪', '外道', '野獣', '死使', '破滅'
      ]
      position_ids[position_id - 1]
    end
  end
end
