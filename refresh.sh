#! /bin/bash
docker build -t ubuntu-postfix-opendkim .
docker run --rm -it -v "$(pwd)/keys:/var/keys" -v "$(pwd)/log/raw:/mailraw" -v "$(pwd)/log/list:/maillist" ubuntu-postfix-opendkim /bin/bash
