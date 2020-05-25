# ubuntu-postfix-opendkim

## 概要
メール転送サーバー。
このコンテナに**認証なしで**メールを平文で送ると、送信元ドメインに応じて外部にDKIM署名付きでメールを転送する。
DKIMのセレクタは `default` 固定。

## 動作確認環境
Ubuntu 20.04 LTS + Docker version 19.03.8

## ログ
### Postfixのログ
標準出力に吐いているので `Docker logs` で見られる。

### メールログ
* `logs/list` 以下にメールのタイムスタンプやタイトル、送信先を1行にまとめたCSVがたまる。
* `logs/raw` にはメール1件を1個のテキストファイルにしたログがたまる。容量が膨大になるので適当に削除する必要がある。

## 実行方法
### 1. DKIM設定
`opendkim-genkey` コマンドで鍵を作成し、 `keys/` 以下に `example.com.private` のような `FQDN + .private` という名前で配置する。
複数ドメインに対応させる場合も同じ階層に入れる。
また公開鍵をDNSに登録する。

### 2. ログ用ディレクトリ作成
```
mkdir logs; mkdir logs/list; mkdir logs/raw
chmod -R 777 logs
```

### 3. docker run
```sh
docker run --rm -d \
  -p 25:25 -p 1025:25 \
  -v "$(pwd)/keys:/keys" \
  -v "$(pwd)/logs/raw:/mailraw" \
  -v "$(pwd)/logs/list:/maillist" \
  ubuntu-postfix-opendkim
```

### 4. テスト送信
これで25番または1025番ポートにTELNETでアクセスしてメールが出せるはず。

```
HELO localhost
MAIL FROM: root@localhost
RCPT TO: root@localhost
DATA
From: root@localhost
To: root@localhost
Subject: Test
Hello World!
.
QUIT
```
