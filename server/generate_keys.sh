#!/bin/bash

mkdir -p /etc/pki/tls/private /etc/pki/tls/certs

hostname=$(hostname -I)
if [ ! -f /etc/pki/tls/private/localhost.key ]; then
    echo "Generating self-signed certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt \
    -subj "/C=LT/ST=Vilnius/L=Vilnius/O=NextCloud/CN=$hostname" \
    -addext "subjectAltName=IP:$hostname" -extensions v3_ca \
    -config <(echo "[req]"; echo "distinguished_name=req"; echo "[v3_ca]"; echo "basicConstraints=CA:FALSE")
fi

rm $0
