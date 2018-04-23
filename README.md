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
- -d|--rootdir: the root directory of the root CA; for creating an intermediate CA this is the directory of the root CA used to sign it; defaults to `\root\ca`
- -C|--rootconfig: the path to the template used for the CA; only for root CA; defaults to the provided template
- -c|--config: the path to the temlate used for the CA; only for intermediate CA; defaults to the provided template
- -n|--name: the name for the new intermediate CA; only for intermediate CA; defaults to 'intermediate'


Footnotes
---------
<a name="myfootnote1">1</a>:https://jamielinux.com/docs/openssl-certificate-authority/
