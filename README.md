# ubuntu-postfix-opendkim

## 概要
メール転送サーバー。
このコンテナに**認証なしで**メールを平文で送ると、送信元ドメインに応じて外部にDKIM署名付きでメールを転送する。
証明書はドメイン単位で固定。メールアドレスごとに証明書を変えることはできない。またDKIMのセレクタは `default` 固定。

## モチベーション
* シンプルなメール中継サーバーが欲しい
* ストレージの容量が許す限り、いつ・誰に・どんなメールを送ったかのログは残しておきたい
* Postfixのログは標準出力に出して取り回しを良くしたい

## 動作確認環境
Ubuntu 20.04 LTS + Docker 19.03.8

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

### 3. TrustedHosts修正
デフォルトではこうなっているので、必要に応じて修正する。
ここに記載されたIPアドレスから送られたメールがDKIMで署名される。

```
127.0.0.1
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
::1
```

### 4. 起動
```sh
docker-compose up -d
```

### 5. テスト送信
これで25番または1025番ポートにTELNETでアクセスしてメールが出せるはず。
DKIM設定を済ませてあるドメインを `From` に書けば署名が付く。

```
$ telnet localhost 1025
HELO localhost
MAIL FROM: test@example.com
RCPT TO: root@localhost
DATA
From: test@example.com
To: root@localhost
Subject: Test
Hello World!
.
QUIT
```

これでメールが送信できたので、 `./logs/raw/YYYY-MM-DD/` 以下のメール本文を確認する。ちゃんとDKIMの署名が付いていることが確認できるはず。

```
From test@example.com  Fri Jun  5 06:18:59 2020
Return-Path: <test@example.com>
X-Original-To: logging@localhost
Delivered-To: logging@localhost
Received: from localhost (unknown [172.27.0.1])
	by localhost (Postfix) with SMTP id 408003E21BC
	for <root@localhost>; Fri,  5 Jun 2020 06:18:59 +0000 (UTC)
DKIM-Filter: OpenDKIM Filter v2.11.0 localhost 408003E21BC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=example.com;
	s=default; t=1591337939;
	bh=z85OKVJZHnmg3qFlSpLbpPCZ00irfBdrzQUtabiSl3A=;
	h=From:To:Subject:From;
	b=eZGcbjWhjoh08eubcsRttWHDdFI+/JY7io+prVZd3feuEJvsyoj28IFRRbsFdkkn+
	 yPR8oPMQq9QAwJHeA+l0eME0eP44hSEeRxyBZseDTdMbvcXBtF+2Bkip/npbmo+9b9
	 xZUKxoBsBMA/cLyt9NCcdnkP0b7slnzdVg9FZvKl0k1jPYbCOD7mqh8RBfHEtSYMYN
	 JsigPVH6taF+XPpe0y0XV29/tVGVfZPELqQ1vX4d0SmWqZ8k9ca31eI9q2TjCURLU3
	 /uk+iJ0OTnGZa6UcaRlzdEIuURwQkKG0hfp1GCDLcaE89UfGvLWtmxtiCit2skXKs2
	 BQ/5bl/jnJGHw==
From: test@example.com
To: root@localhost
Subject: Test

Hello World!
```
