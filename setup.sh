#! /bin/bash
ls -1 /var/keys/*.private | \
  tr "/", "\n" | \
  grep ".private" | \
  sed -r 's/(.*)/*@\1 default._domainkey.\1/' > /etc/opendkim/SigningTable

ls -1 /var/keys/*.private | \
  tr "/", "\n" | \
  grep ".private" | \
  sed -r 's/(.*)\.private/default._domainkey.\1 \1:default:\/etc\/dkimkeys\/\1\/\1.private/' > /etc/opendkim/KeyTable

service opendkim start
service postfix start
