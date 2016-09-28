#!/bin/bash
usage () 
{
  echo usage: $0 -p public_key -f file \[-o outfile\]
  echo options include
  echo -e '   -p, --publickey: path to public key file in pkcs8 format'
  echo -e '   -f, --file: path to file to encrypt'
  echo -e '   -o, --out: path to output tar file with encrypted file. Default is filename_enc.tgz'
}
help () 
{
  echo Utility to ecrypt a file with the given public key and store it in a tar file along with generated secret, also encrypted.
  echo Suggested to use with a private-public key pair that is passphrase protected.
  usage
}

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
  -p|--publickey)
    PUBFILE="$2"
    shift # past argument
    ;;
  -f|--file)
    FILE="$2"
    shift # past argument
    ;;
  -o|--out)
    OUTFILE="$2"
    shift # pass argument
    ;;
  *)
    # unknown option
    ;;
esac
shift
done

if [ "$1" = -h ] || [ "$1" = --help ]; then
  help
  exit 0;
fi;

if [ -z "${PUBFILE// }" ]; then
  echo Public key file path not provided;
  usage
  exit 1;
fi;
if [ -z "${FILE// }" ]; then
  echo File path to encrypt not provided;
  exit 1;
fi;
if [ -z "${OUTFILE// }" ]; then
  OUTFILE=${FILE}_enc
  echo Output file = "${OUTFILE}.tgz"
fi;

SECRET=${FILE}.key
openssl rand 192 -out ${FILE}.key
openssl aes-256-cbc -in ${FILE} -out ${FILE}.enc -pass file:${SECRET}
openssl rsautl -encrypt -pubin -inkey ${PUBFILE} -in ${SECRET} -out ${SECRET}.enc
tar -zcvf ${OUTFILE}.tgz *.enc
rm ${SECRET}
rm *.enc
