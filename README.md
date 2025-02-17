# Ubuntu-Postfix-OpenDKIM
Japanese README is [here](README_JP.md)

# What is this?
A mail relay server. When you send mail to this container, it forwards the mail externally with a DKIM signature, depending on the sender domain. The DKIM selector is fixed to default.

Docker Hub repository is [here](https://hub.docker.com/r/netebakari/ubuntu-postfix-opendkim).

# Motivation
* I want a simple mail relay server and know how DKIM works.
* I want to keep logs of when, to whom, and what kind of emails were sent, as long as storage capacity allows.
* I want to output Postfix logs to standard output for easy handling.

# Environment Tested
Ubuntu 22.04 LTS + Docker 27.5.1

# Docker Hub
https://hub.docker.com/r/netebakari/ubuntu-postfix-opendkim

# Logs
## Postfix log
Since logs are output to standard output, you can check them with `docker logs` or `docker compose logs`.

## Mail logs
Two types of log files are output:
* CSV file summarizing the mail's timestamp, subject, and recipient in one line.
* Plain text file containing all information, including the mail header, body, attachment of single mail.


# How to Start
## 1. Create Mail Log Directories
```sh
$ mkdir -p logs/list
$ mkdir -p logs/raw
$ chmod 777 logs/list logs/raw
  or
$ chown YOUR-USER-WHOSE-ID-IS-1000 logs/list logs/raw
```

Mail logs are stored by the `maillog` user, whose user / group id is 1000:1000.

## 2. DKIM Configuration
### Create DKIM keys
```sh
$ mkdir keys
```

Create DKIM public/private keys using the `opendkim-genkey` command and put them into the `keys/` directory. You can store keys for multiple domains.

The filename should be in the format `FQDN + .private`, such as `example.com.private`.

### Register keys in your DNS
Register the public key in your DNS TXT record. Since DKIM is verified by the recipient, you can skip this step if you are just testing.

```
$ dig +short txt default._domainkey.example.com
"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0...."
```

## 3. Start
Initially, all emails are forwarded to [mailcatcher](https://hub.docker.com/r/schickling/mailcatcher/). Don't worry, no mails will be sent externally!

```sh
docker compose up -d
```

## 4. Send Test Email
### Send a mail
Now you can connect to port TCP/25 or TCP/1025 of localhost using TELNET or something you would like and send emails. If you write an email address of a domain with DKIM configuration completed in From, it will be signed.

```sh
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

### Check the mail logs
Check the email body by mailcatcher (working at [http://localhost:1080](http://localhost:1080)) or log file in `/logs/raw/YYYY-MM-DD/`. It would be just like:

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

## 5. Custom Transport File
If you would like forwar emails to a specific server, create a Postfix [transport](https://www.postfix.org/transport.5.html)⁠ file and mount it to `/etc/postfix/transport`. The `postmap` command is executed at start up time.

```
localhost   local:
*           smtp:[email-smtp.ap-northeast-1.amazonaws.com]:25
```
