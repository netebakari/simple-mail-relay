FROM ubuntu:20.10

RUN apt-get -y update
RUN apt-get -y --no-install-recommends install openssl telnet vim ruby
RUN echo "2" > input.txt
RUN apt-get -y --no-install-recommends install postfix < input.txt
RUN apt-get -y --no-install-recommends install opendkim
RUN rm -f input.txt

RUN gem install mail

RUN  mv /etc/postfix/main.cf /etc/postfix/main.cf.org
COPY postfix/mailname /etc/
COPY postfix/main.cf /etc/postfix/
COPY postfix/master.cf /etc/postfix/

RUN  mv /etc/opendkim.conf /etc/opendkim.conf.org
COPY opendkim/opendkim.conf /etc/
COPY opendkim/TrustedHosts  /etc/opendkim/

# メールのログ関係
RUN  mkdir /opt/maillog
RUN  mkdir /opt/maillog/log
RUN  mkdir /opt/maillog/log/list
RUN  mkdir /opt/maillog/log/raw
COPY postfix/log.rb /opt/maillog
RUN  chmod -R 777 /opt/maillog
RUN  echo 'logging: "|/usr/bin/ruby /opt/maillog/log.rb"' >> /etc/aliases
RUN  newaliases

COPY  startup.sh /tmp
COPY  setup.sh   /tmp

#CMD ["/bin/bash", "/tmp/startup.sh"]
ENTRYPOINT ["/bin/bash", "/tmp/startup.sh"]

EXPOSE 25
