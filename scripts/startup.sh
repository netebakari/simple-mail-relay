#! /bin/bash
# set up OpenDKIM configuration
ls -1 /keys/*.private | tr "/", "\n" | grep ".private" | sed -e 's/.private$//' > /tmp/domains.txt
cat /tmp/domains.txt | awk '{print "*@" $1 " default._domainkey." $1}' > /etc/opendkim/SigningTable
cat /tmp/domains.txt | awk '{print "default._domainkey." $1 " " $1 ":default:/etc/dkimkeys/" $1 "/" $1 ".private"}' > /etc/opendkim/KeyTable
cat /tmp/domains.txt | awk '{print "mkdir /etc/dkimkeys/" $1 "; cp /keys/" $1 ".private /etc/dkimkeys/" $1 "; chmod 600 /etc/dkimkeys/" $1 "/" $1 ".private"}' | /bin/bash
chown -R opendkim:opendkim /etc/dkimkeys/

# depending on whether the transport file exists (binded)
if [ ! -e /etc/postfix/transport ]; then
    echo 'localhost   local:' > /etc/postfix/transport
    echo '*           smtp:' >> /etc/postfix/transport
else
    chown root /etc/postfix/transport
fi
postmap /etc/postfix/transport

# start services
/usr/sbin/opendkim -x /etc/opendkim.conf
postfix start-fg
