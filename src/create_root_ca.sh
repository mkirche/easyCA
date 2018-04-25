#!/bin/bash

# get dir path in which script is executed 
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# default arguments
ROOTDIR=/root/ca
ROOTCONFIGTEMPLATE=templates/openssl_root.tpl
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
    -C|--rootconfig)
    ROOTCONFIGTEMPLATE="$2"
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

# create folder structure
echo "Step 1/4: Creating folder structure and custom config file"
cd $ROOTDIR
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
# edit config template and copy to working directory
sed -e 's|%rootdir%|'$ROOTDIR'|' -e 's|%pathlen%|'$PATH_LEN'|' $ROOTCONFIGTEMPLATE > openssl.cnf

# generate private key
echo -e "\nStep 2/4: Generating private key"
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# generate signed certificate and verify
echo -e "\nStep 3/4: Generating self-signed certificate"
openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
echo -e "\nStep 4/4: Verifying certificate"
openssl x509 -noout -text -in certs/ca.cert.pem