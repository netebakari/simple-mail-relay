#! /bin/bash
ls -1 /keys/*.private | \
  tr "/", "\n" | \
  grep ".private" | \
  sed -e 's/.private$//' > /tmp/domains.txt


cat /tmp/domains.txt | \
  awk '{print "*@" $1 " default._domainkey." $1}' \
  > /etc/opendkim/SigningTable


cat /tmp/domains.txt | \
  awk '{print "default._domainkey." $1 " " $1 ":default:/etc/dkimkeys/" $1 "/" $1 ".private"}' \
  > /etc/opendkim/KeyTable


cat /tmp/domains.txt | \
  awk '{print "mkdir /etc/dkimkeys/" $1 "; cp /keys/" $1 ".private /etc/dkimkeys/" $1 "; chmod 600 /etc/dkimkeys/" $1 "/" $1 ".private"}' \
  > /tmp/copy.sh

/bin/bash /tmp/copy.sh
chown -R opendkim:opendkim /etc/dkimkeys/
