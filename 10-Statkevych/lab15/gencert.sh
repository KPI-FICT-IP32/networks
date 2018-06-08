#!/bin/sh
set -x
mkdir -p cert

export CERT_PASSWORD="my_awesome_certificate_password"
export ROOT_CERT_SUBJECT="/C=UA/ST=Kyiv/L=Kyiv city/O=icedNecro/CN=zone10.org.ua."
export CSR_EARTH_SUBJECT="/C=UA/ST=Kyiv/L=Kyiv city/O=icedNecro/CN=earth.zone10.org.ua."
export CSR_SRV_10_SUBJECT="/C=UA/ST=Kyiv/L=Kyiv city/O=icedNecro/CN=srv-10.zone10.org.ua."

# Generate key for CA
openssl genrsa -passout env:CERT_PASSWORD -des3 -out cert/icedNecroCA.key 4096

# Generate root certificate
openssl req -x509 -new -nodes \
    -key cert/icedNecroCA.key -passin env:CERT_PASSWORD \
    -sha256 \
    -days 365 \
    -subj "$ROOT_CERT_SUBJECT" \
    -out cert/icedNecroCA.pem

# Generate private key for site certificate
openssl genrsa -out cert/earth.zone10.org.ua.key 4096
openssl genrsa -out cert/srv-10.zone10.org.ua.key 4096

# Create a CSR (certificate signing request)
openssl req -new \
    -key cert/earth.zone10.org.ua.key \
    -subj "$CSR_EARTH_SUBJECT" \
    -out cert/earth.zone10.org.ua.csr

# Create a CSR (certificate signing request)
openssl req -new \
    -key cert/srv-10.zone10.org.ua.key \
    -subj "$CSR_SRV_10_SUBJECT" \
    -out cert/srv-10.zone10.org.ua.csr

# Create a CSR config
cat >cert/earth.zone10.org.ua.csr.conf << 'EOF'
[req]
default_bits = 4096
prompt = no
default_md = sha512
distinguished_name = dn

[dn]
C=UA
ST=Kyiv
L=Kyiv city
O=icedNecro
CN=earth.zone10.org.ua.
emailAddress=roman.statkevych@gmail.com
EOF

# CSR config extension
cat >cert/earth.zone10.org.ua.csr.ext << 'EOF'
authorityKeyIdentifier = keyid, issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = earth.zone10.org.ua.
EOF

cat >cert/srv-10.zone10.org.ua.csr.conf << 'EOF'
[req]
default_bits = 4096
prompt = no
default_md = sha512
distinguished_name = dn

[dn]
C=UA
ST=Kyiv
L=Kyiv city
O=icedNecro
CN=srv-10.zone10.org.ua.
emailAddress=roman.statkevych@gmail.com
EOF

# CSR config extension
cat >cert/srv-10.zone10.org.ua.csr.ext << 'EOF'
authorityKeyIdentifier = keyid, issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = srv-10.zone10.org.ua.
EOF

# Sign certificate
openssl x509 -req -in cert/earth.zone10.org.ua.csr \
    -CA cert/icedNecroCA.pem \
    -CAkey cert/icedNecroCA.key -passin env:CERT_PASSWORD \
    -CAcreateserial \
    -out cert/earth.zone10.org.ua.crt \
    -days 30 \
    -sha512 \
    -extfile cert/earth.zone10.org.ua.csr.ext

# Sign certificate
openssl x509 -req -in cert/srv-10.zone10.org.ua.csr \
    -CA cert/icedNecroCA.pem \
    -CAkey cert/icedNecroCA.key -passin env:CERT_PASSWORD \
    -CAcreateserial \
    -out cert/srv-10.zone10.org.ua.crt \
    -days 30 \
    -sha512 \
    -extfile cert/srv-10.zone10.org.ua.csr.ext

unset CERT_PASSWORD
unset ROOT_CERT_SUBJECT
unset CSR_EARTH_SUBJECT
unset CSR_SRV_10_SUBJECT
