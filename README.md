# でたとこサーガ用1行キャラシ出力ツール ver2.x

[![Build Status](https://travis-ci.org/koi-chan/detatoko-1line-charasheet.svg?branch=master)](https://travis-ci.org/koi-chan/detatoko-1line-charasheet)

[でたとこサーガ](http://detatoko-saga.com/) で使える、1行で表現されたキャラクターシートです。  
GM がキー判定を決めるときに、PL が他のキャラクターの支援をするときに、パッと見て PC の状態が分かります。

アイディア元はSW2などのプレイサイト [月光華亭](http://geekou.net/) の「技能表」です。

## 出力データ解説

```
名前        |Lv|体力　気力 旗|クラス　|ポジ|スキル　　　|意感交肉技知|ID  |プレイヤー
王道勇者    |１|11/11 10/10 0|勇者戦士|　　|聖希折鉄強必|１１　４　　|   1|でたとこサーガ
暗黒魔王    |１|10/10 11/11 0|魔王暗黒|　　|無圧極ド暗愉|３１１　　１|   2|でたとこサーガ
```

_名前_ と _Lv_ の項目は説明がなくとも問題ないでしょう。

_体力・気力_ は、分子・分母のどちらにも、常に最大値が出力されます。  
_「旗」_ はフラグのことで、こちらは常に0が出力されます。

_クラス_ は 基本ルールブック「でたとこサーガ」掲載の12クラスに加え、サプリ「でたとこファンタジア」で追加された3クラスを、全て2文字に短縮して出力されます。

_ポジ_ はサプリ「でたとこファンタジア」で追加された3ポジションを、クラス同様2文字に短縮して出力されます。

_スキル_ は「アタック」「モノローグ」「ガード」を除いた6つの、それぞれの頭文字を出力します。掲載順に並べ替えられています。

続く項目は _スキルジャンル_ の集計結果です。  
順に「意志」「感覚」「交渉」「肉体」「技術」「知識」を表しています。  
基本となる12クラスのスキルの他、ポジションスキルがもつスキルジャンルも合算します。

_ID_ はキャラクターシートのIDです。  
_プレイヤー_ はキャラクターシートの登録者名です。


## 同梱ファイル

このリポジトリに含まれるファイルの一覧です。

### README.md

このプログラムの使い方説明書です。このファイルのことです。

### index.cgi

CGI として動作させるためのファイルです。  
ウェブブラウザからはこのファイルが呼び出されます。

### version.rb

このプログラムのバージョンを管理しているファイルです。

### lib/

Ruby ライブラリ(gem)である [d1lcs](https://rubygems.org/gems/d1lcs) のコア部分が格納されています。  
実際に[公式キャラクターシート](http://detatoko-saga.com/character/)からデータを取得し加工しているのはこの部分です。

### .htaccess

ウェブサーバーの設定を行ないます。

### v1.x/

ver1.x 系のファイルが格納されています。ver1.x はポジションに対応していません。  
ruby-gem を使わない(データの読み込みを独自に実装している)バージョンです。今後、更新される予定はありません。
ver2.x 以降をお使いになる場合、このディレクトリは必要ありません。

### .travis.yml

プログラムの自動テストを行なうための設定が書かれています。  
開発用であり、プログラムの動作には必要ありません。


## 動作環境

動作確認を行なっている環境は以下の通りです。

### Ruby

* 2.3.1

またこのほかに、Travis-CI を使い以下のバージョンの自動テストを行なっています。

* 1.9.3
* 2.0.0-p648
* 2.1.10
* 2.2.5

### ウェブサーバ

* Apache 2.4.6 (CentOS 7.2: httpd-2.4.6-40.el7.centos.1.x86_64)

### ブラウザ

* Firefox 47.0.1

InternetExplorer11.0(Windows10) では、テキストエリア内の文字が固定幅フォントで表示されません。メモ帳などにコピペしてご利用ください。


## 設置方法

1. [圧縮ファイル](https://github.com/koi-chan/detatoko-1line-charasheet/releases/download/v2.2/Detatoko1LineCharaSheetCGI_2.2.zip)をダウンロードし、解凍します。
2. Ruby インタプリタのパスを調べ、index.cgi の1行目を書き換えます。  
レンタルホームページスペースのマニュアルなどを確認してください。
3. 次のファイル・ディレクトリをレンタルホームページスペースなどにアップロードします。  
  * index.cgi
  * version.rb
  * .htaccess
  * lib/
4. index.cgi のパーミッションを変更します。大抵は 755(rwxr-xr-x) ですが、レンタルスペースによっては 705(rwx---r-x) などの場合もあります。
5. 動作確認を行ないます。
