#!/bin/bash

echo House-keeping - delete old files

rm GUID.txt
rm  -Rf /etc/secureboot/


echo Generate GUID.txt file
echo ""
uuidgen --random > GUID.txt

echo  Make keys dir
export KEYDIRROOT=/etc/secureboot/keys

mkdir -p $KEYDIRROOT/{db,dbx,KEK,PK}

uuidgen --random >  GUID.txt
echo Generating Platform Key 
echo ""


openssl req -newkey rsa:4096 -noenc -keyout $KEYDIRROOT/PK/PK.key -new -x509 -sha256 -days 4000 -subj "/CN=My Computer PK key/" -out $KEYDIRROOT/PK/PK.crt
openssl x509 -outform DER  -in $KEYDIRROOT/PK/PK.crt -out $KEYDIRROOT/PK/PK.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" $KEYDIRROOT/PK/PK.crt $KEYDIRROOT/PK/PK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k $KEYDIRROOT/PK/PK.key -c $KEYDIRROOT/PK/PK.crt PK $KEYDIRROOT/PK/PK.esl $KEYDIRROOT/PK/PK.auth

echo Generating Fail-safe empty file for removing Platform Key in User Mode
sign-efi-sig-list -g "$(< GUID.txt)" -c $KEYDIRROOT/PK/PK.crt -k $KEYDIRROOT/PK/PK.key PK /dev/null $KEYDIRROOT/PK/noPK.auth

echo Generating Exhange Key
openssl req -newkey rsa:4098 -noenc -keyout $KEYDIRROOT/KEK/KEK.key -new -x509 -sha256 -days 4000 -subj "/CN=My Computer KEK key/" -out $KEYDIRROOT/KEK/KEK.crt
openssl x509 -outform DER -in $KEYDIRROOT/KEK/KEK.crt -out $KEYDIRROOT/KEK/KEK.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" $KEYDIRROOT/KEK/KEK.crt $KEYDIRROOT/KEK/KEK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k $KEYDIRROOT/PK/PK.key -c $KEYDIRROOT/PK/PK.crt KEK $KEYDIRROOT/KEK/KEK.esl $KEYDIRROOT/KEK/KEK.auth

echo Generating Signure Database Key 

openssl req -newkey rsa:4098 -noenc -keyout $KEYDIRROOT/db/db.key -new -x509 -sha256 -days 4000 -subj "/CN=My Computer Database key/" -out $KEYDIRROOT/db/db.crt
openssl x509 -outform DER -in $KEYDIRROOT/db/db.crt -out $KEYDIRROOT/db/db.cer
cert-to-efi-sig-list -g "$(< GUID.txt)" $KEYDIRROOT/db/db.crt $KEYDIRROOT/db/db.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k $KEYDIRROOT/KEK/KEK.key -c $KEYDIRROOT/KEK/KEK.crt db $KEYDIRROOT/db/db.esl $KEYDIRROOT/db/db.auth


