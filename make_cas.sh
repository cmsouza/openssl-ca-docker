#!/bin/bash

if [ -f "/root/ca/index.txt" ]; then
    echo "root CA already exists."
    exit 0
fi

mkdir -p /root/ca/{private,certs,newcerts,crl,csr}
mkdir -p /root/ca/intermediate/{private,certs,newcerts,crl,csr}

cd /root/ca/
chmod 700 private
touch index.txt
echo 1000 > serial

cd /root/ca/intermediate/
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

cd /root/ca/
openssl genrsa -aes256 -passout pass:$CAPASS -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem -passin pass:$CAPASS -subj "$ROOT_CA_SUBJECT"
chmod 444 certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem

openssl genrsa -aes256 -passout pass:$CAPASS -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

openssl req -config intermediate/openssl.cnf -passin pass:$CAPASS -new -sha256 -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem -subj "$INT_CA_SUBJECT"

openssl ca -batch -config openssl.cnf -passin pass:$CAPASS -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem

cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem
