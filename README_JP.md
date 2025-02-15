# Ubuntu-Postfix-Opendkim

## 概要
メール転送サーバー。
このコンテナにメールを平文で送ると、送信元ドメインに応じて外部にDKIM署名付きでメールを転送する。
証明書はドメイン単位で固定。メールアドレスごとに証明書を変えることはできない。またDKIMのセレクタは `default` 固定。

## モチベーション
* シンプルなメール中継サーバーが欲しい
* ストレージの容量が許す限り、いつ・誰に・どんなメールを送ったかのログは残しておきたい
* Postfixのログは標準出力に出して取り回しを良くしたい

## 動作確認環境
Ubuntu 22.04 LTS + Docker 27.5.1

## Docker Hub
https://hub.docker.com/r/netebakari/ubuntu-postfix-opendkim

## ログ
### Postfixのログ
標準出力に吐いているので `Docker logs` または `docker-compose logs` で見られる。

### メールログ
* `logs/list` 以下にメールのタイムスタンプやタイトル、送信先を1行にまとめたCSVがたまる。
* `logs/raw` にはメール1件を1個のテキストファイルにしたログがたまる。

## 起動方法
### 1. ログ用ディレクトリ作成
```sh
$ mkdir -p logs/list
$ mkdir -p logs/raw
$ chmod 777 logs/list logs/raw
```

### 2. DKIM設定
#### 鍵作成
`opendkim-genkey` コマンドで鍵を作成し、 `keys/` 以下に `example.com.private` のような `FQDN + .private` という名前で配置する。

複数ドメインの鍵を作る場合も同じ階層に入れる。

#### 鍵登録
公開鍵をDNSに登録する。 DKIM検証は受信側が行うものなので、テストのためならこの手順はスキップしても良い。

```
$ dig +short txt default._domainkey.example.com
"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0...."
```

### 3. テスト起動
コンテナを起動する。初期状態では全てのメールが [mailcatcher](https://hub.docker.com/r/schickling/mailcatcher/) に転送される（他のサーバーへは出て行かない）。

```sh
docker compose up -d
```

### 4. メールテスト送信
#### メール送信
これでlocalhostの25番または1025番ポートにTELNET（またはその他好きなツール）でアクセスしてメールが出せるようになった。DKIM設定を済ませてあるドメインのメールアドレスを `From` に書けば署名が付く。

```
$ telnet localhost 1025
HELO localhost
MAIL FROM: test@example.com
RCPT TO: someone@netebakari.local
DATA
From: test@example.com
To: someone@netebakari.local
Subject: Test
Hello World!
.
QUIT
```

#### メールログ確認
http://localhost:1080 でメールを確認する。あるいは `/logs/raw/YYYY-MM-DD/` 以下のメール本文を確認する。ちゃんとDKIMの署名が付いていることが確認できるはず。

```
From test@example.com  Fri Feb 14 06:29:47 2025
Return-Path: <test@example.com>
X-Original-To: logging@localhost
Delivered-To: logging@localhost
DKIM-Filter: OpenDKIM Filter v2.11.0 localhost 163543B422
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=example.com;
	s=default; t=1739546987;
	bh=z85OKVJZHnmg3qFlSpLbpPCZ00irfBdrzQUtabiSl3A=;
	h=From:To:Subject:From;
	b=Mj4Ru4JCf9dVMtAN9wcMG38/I91KGrKCVjI1rT3ORVfG3gP95XQdpabR6O4Gc07W6
	 Hbo4rbgV+MlGz06gkzpmeGTXlovEbY5v4WBdH56a21OX9ALYbPNQTadzp/fCcj93XG
	 X86qDjFmrXn3pHe0bvlFmEnynRLKffQl8Cw4zercSw8hsgtHlFc5HTPkNhna8mzM1W
	 jvTYblNPpyq6jgeG88TEDhR7Wt4MCOPH4iPFTX2VbzdY00YV8avI/+b2CUhQLJUkxC
	 buG+PfphmT9NkP8s9Y6mtmlikw6MUNSOPPGnO5MhgDg04Je1AChre+c1waV7fFh+1O
	 qnrFWlKqz9pLg==
Received: from localhost (unknown [172.19.0.1])
	by localhost (Postfix) with SMTP id 163543B422
	for <someone@netebakari.local>; Fri, 14 Feb 2025 06:29:34 -0900 (AKST)
From: test@example.com
To: someone@netebakari.local
Subject: Test

Hello World!
```

## 5. カスタムの transport ファイル
メールをすべて特定のサーバーに転送したい場合などは、 Postfixの[transport](https://www.postfix.org/transport.5.html)⁠ファイルを作成し、 `/etc/postfix/transport` にマウントする。`postmap` コマンドはスタートアップ時に実行される。

```
localhost   local:
*           smtp:[email-smtp.ap-northeast-1.amazonaws.com]:25
```
