#! /bin/bash

/bin/bash /tmp/setup.sh
/usr/sbin/opendkim -x /etc/opendkim.conf
postmap /etc/postfix/transport
postfix start-fg
