#!/usr/bin/bash

if [ -z "$EMAIL" ]; then
  echo "Error: EMAIL is required"
  exit 1
fi

if [ -z "$MAIN_DOMAIN" ]; then
  echo "Error: MAIN_DOMAIN is required"
  exit 1
fi

# if [ -z "$DOMAINS" ]; then
#   echo "Error: DOMAINS is required"
#   exit 1
# fi

# if [ -z "$SUB_DOMAINS" ]; then
#   echo "Error: SUB_DOMAINS is required"
#   exit 1
# fi

if [ -z "CLIENT_PROVIDER" ]; then
  echo "Error: CLIENT_PROVIDER is required"
  exit 1
fi

if [ -z "CLIENT_ID" ]; then
  echo "Error: CLIENT_ID is required"
  exit 1
fi

if [ -z "CLIENT_SECRET" ]; then
  echo "Error: CLIENT_SECRET is required"
  exit 1
fi

# dependencies
export ACME_EMAIL=$EMAIL
# zmicro install acme
# zmicro package install acme

# Register Email Accmount
export ACCOUNT_EMAIL=$ACME_EMAIL
zmicro acme --register-account -m $ACCOUNT_EMAIL

case $CLIENT_PROVIDER in
  aly)
    # aliyun
    #   more: https://github.com/acmesh-official/acme.sh/wiki/dnsapi#11-use-aliyun-domain-api-to-automatically-issue-cert
    CLIENT_PROVIDER=ali
    export Ali_Key=$CLIENT_ID
    export Ali_Secret=$CLIENT_SECRET
    ;;
  cf)
    # cloudflare
    #   more: https://github.com/acmesh-official/acme.sh/wiki/dnsapi#11-use-aliyun-domain-api-to-automatically-issue-cert
    export CF_Account_ID=$CLIENT_ID
    export CF_Token=$CLIENT_SECRET
    ;;
  *)
    echo "Error: unsupported client provider (${CLIENT_PROVIDER})"
    exit 1
    ;;
esac 


COMMAND_DOMAIN="-d $MAIN_DOMAIN"

# Example:
#   DOMAINS=*.example.com,*.t.example.com
if [ -n "$DOMAINS" ]; then
  DOMAINS_ARRAY=($(echo $DOMAINS | awk -F ',' '{out=""; for(i=1;i<=NF;i++){out=out" "$i}; print out}'))

  for d in ${DOMAINS_ARRAY[@]}; do
    COMMAND_DOMAIN="$COMMAND_DOMAIN -d $d"
  done
fi

# Example:
#   SUB_DOMAINS=*,*.t
#  
#   equals:
#     DOMAINS=*.example.com,*.t.example.com
if [ -n "$SUB_DOMAINS" ]; then
  DOMAINS_ARRAY=($(echo $SUB_DOMAINS | awk -F ',' '{out=""; for(i=1;i<=NF;i++){out=out" "$i}; print out}'))

  for d in ${DOMAINS_ARRAY[@]}; do
    COMMAND_DOMAIN="$COMMAND_DOMAIN -d $d.$MAIN_DOMAIN"
  done
fi

# 1. Get Cert
COMMAND="zmicro acme --issue --dns dns_$CLIENT_PROVIDER $COMMAND_DOMAIN"

if [ -n "$DEBUG" ]; then
  COMMAND="$COMMAND --debug"
fi

echo "Run: $COMMAND"
$COMMAND

# 2. Install Cert
CERT_DIR=/data/ssl/$MAIN_DOMAIN
if [ ! -d "$CERT_DIR" ]; then
  mkdir -p $CERT_DIR
fi

zmicro acme \
  --install-cert \
  -d $MAIN_DOMAIN \
  --key-file $CERT_DIR/privkey.pem \
  --fullchain-file $CERT_DIR/fullchain.pem

sleep infinity