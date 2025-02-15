FROM ubuntu:22.04

RUN apt -y update && yes "2" | apt -y --no-install-recommends install openssl telnet vim ruby tzdata postfix opendkim
RUN gem install mail
RUN  mv /etc/postfix/main.cf /etc/postfix/main.cf.org
RUN  echo "hostname -f" > /etc/mailname
COPY postfix/main.cf /etc/postfix/
COPY postfix/master.cf /etc/postfix/
RUN  chmod 644 /etc/postfix/master.cf /etc/postfix/main.cf
RUN  mv /etc/opendkim.conf /etc/opendkim.conf.org
COPY opendkim/opendkim.conf /etc/
COPY opendkim/TrustedHosts  /etc/opendkim/

# メールのログ関係
RUN mkdir -p /maillogs/raw
RUN mkdir -p /maillogs/list
RUN mkdir /opt/maillog
COPY postfix/log.rb /opt/maillog/
RUN  echo 'logging: "|/usr/bin/ruby /opt/maillog/log.rb"' >> /etc/aliases
RUN  newaliases
COPY scripts/startup.sh /tmp

ENTRYPOINT ["/bin/bash", "/tmp/startup.sh"]

EXPOSE 25
