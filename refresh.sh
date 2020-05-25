#! /bin/bash
docker build -t ubuntu-postfix-opendkim .
docker run --rm -d \
  -p 25:25 -p 1025:25 \
  -v "$(pwd)/keys:/keys" \
  -v "$(pwd)/logs/raw:/mailraw" \
  -v "$(pwd)/logs/list:/maillist" \
  --log-opt max-size=50m \
  --log-opt max-file=500 \
  ubuntu-postfix-opendkim
