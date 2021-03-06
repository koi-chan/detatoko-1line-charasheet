#!/usr/bin/env ruby
# coding: UTF-8

require 'cgi'

@cgi = CGI.new('html4')
@cgi.print("Content-Type: text/html\n\n")

root_path = File.expand_path('.', File.dirname(__FILE__))
require "#{root_path}/detatoko_1line_charasheet"
include Detatoko1LineCharaSheet

# フォームから送られてきたデータを受け取る
def formread
  @targets = @cgi['target'].split(' ').map { |value|
    value.to_i != 0 ? value.to_i : nil
  }.compact
  @output_title_line = 
    case @cgi['title_line']
    when 'true'
      true
    when 'false'
      false
    else
      # @output_title_line が Boolean 値でなかった場合、
      # 入力データがないものとする
      nil
    end
end

# フォームを出力する
def formoutput
  print <<__EOT__
<div id="form">
  <h2>出力したいキャラクターの指定</h2>
  <form method="get">
    <p>表示したいキャラクターシートのIDを入力してください。</p>
    <p>半角空白で区切ることで、複数のキャラクターの1行キャラクターシートを出力することができます。</p>
    <input type="text" name="target" value="#{@targets.join(' ')}" size="80" />
    <p>タイトル行を 
      <input type="radio" name="title_line" value="true" #{output_title_line_checked?(true)} />出力する
      <input type="radio" name="title_line" value="false" #{output_title_line_checked?(false)} />出力しない
    </p>
    <input type="submit" value="出力開始" />
    <input type="reset" name="リセット" />
  </form>
</div>

__EOT__
end

# form のラジオボタンの既定値を決定する
# @param value [Boolean] フォームの value 要素
# @return [String] 'checked' もしくは ''
def output_title_line_checked?(value)
  result = ['checked', '']
  result[1], result[0] = result if @output_title_line == false
  return value ? result[0] : result[1]
end

# 1行キャラクターシートを出力する
def chara_sheet
  print(%{<div id="charasheet">\n})
  print(%{<h2>出力結果</h2>\n})
  print(%{<p>以下のテキストエリアの内容をコピーして、メモ帳などに貼り付けてお使いください。</p>\n})
  print(%{<textarea name="output" cols="120" rows="10" readonly wrap="off">\n})
  print("#{title_line}\n") if @output_title_line
  @targets.each { |value| 
    cs = Detatoko1LineCharaSheetElement.new(value)
    if cs.error == nil
      print("#{cs.chara_sheet_line}\n")
    else
      print("#{cs.error}\n")
    end
  }
  print("</textarea>\n")
  print(%{<p>出力データの解説は <a href="https://github.com/koi-chan/detatoko-1line-charasheet#%E5%87%BA%E5%8A%9B%E3%83%87%E3%83%BC%E3%82%BF%E8%A7%A3%E8%AA%AC">ヘルプ</a>をご覧ください。</p>\n})
  print("</div>\n\n")
end

# HTML ヘッダを出力する
def htmlheader
  print <<__EOT__
<html>
<head>
  <meta charset="UTF-8" />
  <title>でたとこサーガ 1行キャラクターシート出力</title>
  <style type="text/css">
    textarea {
      font-family: monospace;
    }
  </style>
</head>
<body>
<h1>でたとこサーガ 1行キャラクターシート出力</h1>

__EOT__
end

# HTML フッタを出力する
def htmlfooter
  print <<__EOT__
</body>
</html>
__EOT__
end


# 実行部
formread
htmlheader
chara_sheet unless @output_title_line == nil
formoutput
htmlfooter
