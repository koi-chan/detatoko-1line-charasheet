#!/usr/bin/ruby
# coding: utf-8

root_path = File.expand_path('.', File.dirname(__FILE__))
lib_path = "#{root_path}/lib"
$LOAD_PATH.push(lib_path)
require "#{root_path}/version"

require 'd1lcs'
include D1lcs

require 'cgi'
@cgi = CGI.new


# フォームから送られてきたデータを受け取る
def formread
  @type = 
    if(@cgi['type'] == 'text')
      'text'
    else
      'html'
    end
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
    <p>表示したいキャラクターシートのIDを半角数字で入力してください。<br />
    半角空白で区切ることで、複数のキャラクターの1行キャラクターシートを出力することができます。</p>
    <input type="text" name="target" value="#{@targets.join(' ')}" size="80" />
    <p>タイトル行を 
      <input type="radio" name="title_line" value="true" #{output_title_line_checked?(true)} />出力する
      <input type="radio" name="title_line" value="false" #{output_title_line_checked?(false)} />出力しない
    <br />
    出力を
      <input type="radio" name="type" value="html" checked />HTML版(フォームあり)
      <input type="radio" name="type" value="text" />テキスト版(フォームなし)
    にする</p>
    <input type="submit" value="出力開始" />
    <input type="reset" name="リセット" />
  </form>
</div>

__EOT__
end

# form のラジオボタンの既定値を決定する
# true: 出力
# @param value [Boolean] フォームの value 要素
# @return [String] 'checked' もしくは ''
def output_title_line_checked?(value)
  result = ['checked', '']
  result[1], result[0] = result if @output_title_line == false
  return value ? result[0] : result[1]
end

# HTMLで整形した1行キャラクターシートを出力する
def chara_sheet_html
  print(%{<div id="charasheet">\n})
  print(%{<h2>出力結果</h2>\n})
  print(%{<p>以下のテキストエリアの内容をコピーして、メモ帳などに貼り付けてお使いください。</p>\n})
  print(%{<textarea name="output" cols="120" rows="10" readonly wrap="off">\n})
  chara_sheet_text
  print("</textarea>\n")
  print(%{<p>出力データの解説は <a href="https://github.com/koi-chan/detatoko-1line-charasheet#%E5%87%BA%E5%8A%9B%E3%83%87%E3%83%BC%E3%82%BF%E8%A7%A3%E8%AA%AC">ヘルプ</a>をご覧ください。</p>\n})
  print("</div>\n\n")
end

# キャラクターシート本体を出力する
def chara_sheet_text
  return if @output_title_line == nil
  print("#{D1lcs.title_line}\n") if @output_title_line
  @targets.each { |value| 
    cs = D1lcs::Element.new(value)
    if cs.error == nil
      print("#{cs.chara_sheet_line}\n")
    else
      print("#{cs.error}\n")
    end
  }
end

# HTML ヘッダを出力する
def htmlheader
  print <<__EOT__
<html>
<head>
  <meta charset="UTF-8" />
  <title>でたとこサーガ 1行キャラクターシート出力 ver#{VERSION}</title>
  <style type="text/css">
    textarea {
      font-family: monospace;
    }
  </style>
</head>
<body>
<h1>でたとこサーガ 1行キャラクターシート出力 ver#{VERSION}</h1>

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
case @type
when 'html'
  @cgi.print("Content-Type: text/html\n\n")
  htmlheader
  formoutput
  chara_sheet_html
  htmlfooter
when 'text'
  @cgi.print("Content-Type: text/plain\n\n")
  chara_sheet_text
end
