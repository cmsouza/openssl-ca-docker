Docker image to manage OpenSSL Certificate Authority based on
https://openssl-ca.readthedocs.io/en/latest/

# global

```bash
docker compose --profile init up -d
docker compose --profile sign up -d
docker compose exec sign bash
```

# server

```bash
openssl genrsa -out intermediate/private/examplehost.key.pem 2048
chmod 400 intermediate/private/examplehost.key.pem

openssl req -config intermediate/openssl.cnf \
    -key intermediate/private/examplehost.key.pem \
    -new -sha256 -out intermediate/csr/examplehost.csr.pem \
    -subj "/C=US/ST=CA/L=Example/O=Example/OU=Devices/CN=examplehost.contoso.com" \
    -addext "subjectAltName = DNS:examplehost.contoso.com"

openssl ca -passin pass:$CAPASS -config intermediate/openssl.cnf -extensions server_cert \
    -days 375 -notext -md sha256 -in intermediate/csr/examplehost.csr.pem \
    -out intermediate/certs/examplehost.cert.pem

cat intermediate/private/examplehost.key.pem \
    intermediate/certs/examplehost.cert.pem \
    intermediate/certs/intermediate.cert.pem > intermediate/certs/examplehost-chain.cert.pem
```

# user

```bash
openssl genrsa -out intermediate/private/exampleuser.key.pem 2048
chmod 400 intermediate/private/exampleuser.key.pem

openssl req -config intermediate/openssl.cnf \
    -key intermediate/private/exampleuser.key.pem \
    -new -sha256 -out intermediate/csr/exampleuser.csr.pem \
    -subj "/C=US/ST=CA/L=Example/O=Example/OU=users/CN=exampleuser@contoso.com"

openssl ca -passin pass:$CAPASS -config intermediate/openssl.cnf -extensions usr_cert \
    -days 375 -notext -md sha256 -in intermediate/csr/exampleuser.csr.pem \
    -out intermediate/certs/exampleuser.cert.pem

cat intermediate/private/exampleuser.key.pem \
    intermediate/certs/exampleuser.cert.pem \
    intermediate/certs/intermediate.cert.pem > intermediate/certs/exampleuser-chain.cert.pem
```
