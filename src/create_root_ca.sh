#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca
ROOTCONFIGTEMPLATE=templates/openssl_root.tpl

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
    -C|--rootconfig)
    ROOTCONFIGTEMPLATE="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

# create folder structure
cd $ROOTDIR
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
# edit config template and copy to working directory
sed 's|%rootdir%|'$ROOTDIR'|' $ROOTCONFIGTEMPLATE > openssl.cnf

# generate private key
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# generate signed certificate and verify
openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
openssl x509 -noout -text -in certs/ca.cert.pem