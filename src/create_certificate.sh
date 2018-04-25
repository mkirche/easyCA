#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca/intermediate
TYPE=usr
CERT_NAME=client1
OPTS=

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
    -s|--server)
    TYPE=server
    CERT_NAME=server1
    shift # past argument
    ;;
    -p|--protected)
    OPTS=-aes256
    shift # past argument
    ;;
    -n|--name)
    CERT_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)
    echo Unknown option was passed.
    exit 1
    ;;
esac
done

if [ -d "$ROOTDIR/certs/$CERT_NAME" ]; then
    echo "Error: Folder with given cert name already exists."
    exit 1
fi

# create folder for certs and keys
echo "Step 1/5: Creating folder for certificates and keys"
cd "$ROOTDIR"
mkdir "certs/$CERT_NAME"

# generate private key
echo -e "\nStep 2/5: Generating private key"
openssl genrsa $OPTS -out certs/$CERT_NAME/$CERT_NAME.private.key.pem 2048
chmod 400 certs/$CERT_NAME/$CERT_NAME.private.key.pem

# create certificate and sign it
echo -e "\nStep 3/5: Generating certificate signing request (CSR)"
openssl req -config openssl.cnf -key certs/$CERT_NAME/$CERT_NAME.private.key.pem -new -sha256 -out certs/$CERT_NAME/$CERT_NAME.csr.pem

echo -e "\nStep 4/5: Signing certificate"
openssl ca -config openssl.cnf -extensions ${TYPE}_cert -days 375 -notext -md sha256 -in certs/$CERT_NAME/$CERT_NAME.csr.pem -out certs/$CERT_NAME/$CERT_NAME.cert.pem
chmod 444 certs/$CERT_NAME/$CERT_NAME.cert.pem

# verify certificate
echo -e "\nStep 5/5: Verifying certificate"
openssl x509 -noout -text -in certs/$CERT_NAME/$CERT_NAME.cert.pem
openssl verify -verbose -CAfile certs/ca-chain.cert.pem certs/$CERT_NAME/$CERT_NAME.cert.pem