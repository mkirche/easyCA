easyCA
========
Streamlined creation of root CA and intermediate CA


Introduction
------------
Created to assemble the instructions from the very comprehensive guide on OpenSSL CAs by Jamie Nguyen<sup>[1](#myfootnote1)</sup> into an easy-to-use CLI application.
This repository provides shell scripts for creating root and intermediate CAs as well as config templates. They can be called from the command line and configured by adjusting the config files. 


Setup
-----
Clone this repository on your local machine.


Operation
---------
To use, call one of the scripts under `src`, having made adjustments to the config templates under `templates`.
There are a couple of command line options, depending on which script you use:
- -d|--rootdir: the root directory of the root CA; this is the root directory of the CA used to sign this certificate/intermediate CA; defaults to `\root\ca` for CAs/`\root\ca\intermediate` for end user certificates
- -C|--rootconfig: the path to the template used for the CA; only for root CA; defaults to the provided template
- -c|--config: the path to the temlate used for the CA; only for intermediate CA; defaults to the provided template
- -l|--pathlen: the maximum path length of an intermediate CA signed by this CA; defaults to zero (CA signed by this CA can only sign end user certificates)
- -n|--name: the name for the new intermediate CA or an end user certificate; defaults to 'intermediate' for CAs or to 'client1' for end user certificates
- -s|--server: flag that, if used, will register the end user certificate as server cert, otherwise it will default to a user cert
- -p|--protected: flag that, if used, will cause the certificate to be password protected; per default it will be unprotected

Footnotes
---------
<a name="myfootnote1">1</a>:https://jamielinux.com/docs/openssl-certificate-authority/
