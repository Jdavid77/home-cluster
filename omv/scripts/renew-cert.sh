#!/usr/bin/env bash

set -euo pipefail

UTILITIES_DIR="$(find /srv -type d -name "*utilities" 2>/dev/null)"
export PATH="$UTILITIES_DIR:$PATH"

CERT_FILE=""
for cert in /etc/ssl/certs/*.crt /etc/ssl/certs/*.pem; do
    if openssl x509 -in "$cert" -noout -text 2>/dev/null | grep -q "DNS:\*.jnobrega.com"; then
        CERT_FILE="${cert%.*}"
        break
    fi
done

if [[ -z "$CERT_FILE" ]]; then
    echo "Error: no certificate for *.jnobrega.com found" >&2
    exit 1
fi

akeyless get-account-settings

if ! SECRET="$(akeyless get-secret-value --name /cert-manager/certificate --json)"; then
  echo "Error: failed to retrieve certificate secret from Akeyless" >&2
  exit 1
fi

jq -r '."/cert-manager/certificate"."tls.crt"' <<< "$SECRET" | base64 -d > "${CERT_FILE}.crt"
jq -r '."/cert-manager/certificate"."tls.key"' <<< "$SECRET" | base64 -d > "${CERT_FILE}.key"