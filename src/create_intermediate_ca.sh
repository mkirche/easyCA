#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca
CONFIGTEMPLATE=templates/openssl_intermediate.tpl
CA_NAME=intermediate

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
    ;;
	-n|--name)
    CA_NAME="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

# create folder structure
mkdir "$ROOTDIR/$CA_NAME"
cd "$ROOTDIR/$CA_NAME"
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
# edit config template and copy to working directory
sed -e 's|%rootdir%|'$ROOTDIR'|' -e 's|%name%|'$CA_NAME'|' $CONFIGTEMPLATE > openssl.cnf
cd ..

# generate private key
openssl genrsa -aes256 -out $CA_NAME/private/$CA_NAME.key.pem 4096
chmod 400 $CA_NAME/private/$CA_NAME.key.pem

# generate certificate signing request
openssl req -config $CA_NAME/openssl.cnf -new -sha256 -key $CA_NAME/private/$CA_NAME.key.pem -out $CA_NAME/csr/$CA_NAME.csr.pem

# generate signed certificate and verify
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in $CA_NAME/csr/$CA_NAME.csr.pem -out $CA_NAME/certs/$CA_NAME.cert.pem
openssl x509 -noout -text -in $CA_NAME/certs/$CA_NAME.cert.pem
openssl verify -CAfile certs/ca.cert.pem $CA_NAME/certs/$CA_NAME.cert.pem

# generate ca chain
cat $CA_NAME/certs/$CA_NAME.cert.pem certs/ca.cert.pem > $CA_NAME/certs/ca-chain.cert.pem
chmod 444 $CA_NAME/certs/ca-chain.cert.pem