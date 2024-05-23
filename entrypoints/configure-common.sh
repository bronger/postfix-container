#!/bin/sh
set -e

echo "Container configuration: Setting TZ"
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone

: "${LOG_OUTPUT:=sigh postfix}"
export LOG_OUTPUT

index=2
for name in $POSTFIX_EXTRA_DNS_NAMES
do
    printf "DNS.%d = %s\n" $index "$name" >> /opt/csr.conf
    index=$((index+1))
done

openssl req -x509 -days 3650 -key /etc/ssl/private/ssl-cert-snakeoil.key \
        -out /etc/ssl/certs/ssl-cert-snakeoil-postfix.pem -config /opt/csr.conf -extensions v3_req
openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil-postfix.pem -text
