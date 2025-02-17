FROM ruby:3.4.2-alpine3.21
RUN  apk update && apk add openssl ruby postfix opendkim bash sudo
RUN  mv /etc/postfix/main.cf /etc/postfix/main.cf.org
RUN  mv /etc/postfix/master.cf /etc/postfix/master.cf.org
COPY postfix/main.cf /etc/postfix/
COPY postfix/master.cf /etc/postfix/
RUN  chmod 644 /etc/postfix/master.cf /etc/postfix/main.cf

# OpenDKIM
RUN  mv /etc/opendkim/opendkim.conf /etc/opendkim/opendkim.conf.org
COPY opendkim/opendkim.conf /etc/opendkim/
COPY opendkim/TrustedHosts  /etc/opendkim/

# add "maillog" user and install mail gem (this needs sudo)
RUN  addgroup -S -g 1000 maillog
RUN  adduser -u 1000 -G maillog -D maillog
RUN  sudo -u maillog gem install mail
RUN  apk del sudo

# mail log
RUN mkdir -p /maillogs/raw
RUN mkdir -p /maillogs/list
RUN mkdir /opt/maillog
COPY postfix/log.rb /opt/maillog/
RUN  echo 'logging: "|/usr/local/bin/ruby /opt/maillog/log.rb"' >> /etc/postfix/aliases
COPY scripts/startup.sh /tmp
ENTRYPOINT ["/bin/bash", "/tmp/startup.sh"]

EXPOSE 25
