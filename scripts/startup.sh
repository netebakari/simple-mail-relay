#! /bin/bash

/bin/bash /tmp/setup.sh
/usr/sbin/opendkim -x /etc/opendkim.conf
postfix start-fg
