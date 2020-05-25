# ubuntu-postfix-opendkim

## 概要
メール転送サーバー。
このコンテナに**認証なしで**メールを平文で送ると、送信元ドメインに応じて外部にDKIM署名付きでメールを転送する。

## 動作確認環境OS
Ubuntu 20.04 LTS + Docker version 19.03.8

## ログ
Postfixはログを標準出力に吐き出すので `Docker logs` で見られる。

## 実行方法
### 1. DKIM設定
鍵を作成し、 `keys/` 以下に `example.com.private` のような名前で配置する。
また公開鍵をDNSに登録する。

### 2. docker run
