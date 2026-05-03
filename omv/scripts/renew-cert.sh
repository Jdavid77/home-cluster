#!/usr/bin/env bash

echo "$PATH"

CERT_FILE=""
for cert in /etc/ssl/certs/*.crt /etc/ssl/certs/*.pem; do
  if openssl x509 -in "$cert" -noout -text 2>/dev/null | grep -q "DNS:*.jnobrega.com"; then
    CERT_FILE="${cert%.*}"  # Remove any extension
    echo "Found in: $CERT_FILE"
    break
  fi
done

akeyless get-secret-value --name /cert-manager/certificate --json | jq -r '."/cert-manager/certificate"."tls.crt"' | base64 -d > "${CERT_FILE}".crt
akeyless get-secret-value --name /cert-manager/certificate --json | jq -r '."/cert-manager/certificate"."tls.key"' | base64 -d > "${CERT_FILE}".key