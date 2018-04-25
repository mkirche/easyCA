#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca
CONFIGTEMPLATE=templates/openssl_intermediate.tpl
CA_NAME=intermediate
PATH_LEN=0

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
    -l|--pathlen)
    PATH_LEN="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

if [ -d "$ROOTDIR/$CA_NAME" ]; then
    echo "Error: A folder for the chosen intermediate CA name already exists in the given root directory."
    exit 1
fi

# create folder structure
echo "Step 1/5: Creating folder structure and custom config file"
mkdir "$ROOTDIR/$CA_NAME"
cd "$ROOTDIR/$CA_NAME"
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
# edit config template and copy to working directory
sed -e 's|%rootdir%|'$ROOTDIR'|' -e 's|%name%|'$CA_NAME'|' -e 's|%pathlen%|'$PATH_LEN'|' $CONFIGTEMPLATE > openssl.cnf
cd ..

# generate private key
echo -e "\nStep 2/5: Generating private key"
openssl genrsa -aes256 -out $CA_NAME/private/$CA_NAME.key.pem 4096
chmod 400 $CA_NAME/private/$CA_NAME.key.pem

# generate certificate signing request
echo -e "\nStep 3/5: Generating certificate signing request (CSR)"
openssl req -config $CA_NAME/openssl.cnf -new -sha256 -key $CA_NAME/private/$CA_NAME.key.pem -out $CA_NAME/csr/$CA_NAME.csr.pem

# generate signed certificate
echo -e "\nStep 4/5: Signing certificate"
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in $CA_NAME/csr/$CA_NAME.csr.pem -out $CA_NAME/certs/$CA_NAME.cert.pem
openssl x509 -noout -text -in $CA_NAME/certs/$CA_NAME.cert.pem

# verify certificate and generate ca chain
echo -e "\nStep 5/5: Verifying certificate and generating ca chain"
if [ ! -f certs/ca-chain.cert.pem ]; then
    openssl verify -CAfile certs/ca.cert.pem $CA_NAME/certs/$CA_NAME.cert.pem
    cat $CA_NAME/certs/$CA_NAME.cert.pem certs/ca.cert.pem > $CA_NAME/certs/ca-chain.cert.pem
else
    openssl verify -CAfile certs/ca-chain.cert.pem $CA_NAME/certs/$CA_NAME.cert.pem
    cat $CA_NAME/certs/$CA_NAME.cert.pem certs/ca-chain.cert.pem > $CA_NAME/certs/ca-chain.cert.pem
fi

chmod 444 $CA_NAME/certs/ca-chain.cert.pem