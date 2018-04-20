#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca
CONFIGTEMPLATE=templates/openssl_intermediate.tpl

# evaluate cli arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--rootdir)
    ROOTDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--config)
    CONFIGTEMPLATE="$2"
    shift # past argument
    shift # past value
esac
done

# create folder structure
mkdir "$ROOTDIR/intermediate"
cd "$ROOTDIR/intermediate"
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
# edit config template and copy to working directory
sed 's|%rootdir%|'$ROOTDIR'|' "$MY_PATH/../$CONFIGTEMPLATE" > openssl.cnf
cd ..

# generate private key
openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

# generate certificate signing request
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem

# generate signed certificate and verify
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem

# generate ca chain
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem