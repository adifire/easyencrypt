#!/bin/bash
usage () 
{
  echo usage: $0 -k privatekey -t tarfile
  echo options include
  echo -e '   -k, --key: path to private key file'
  echo -e '   -t, --tarfile: path to tar file to untar and decrypt'
}
help () 
{
  echo Utility to untar and decrypt a tar file that contains the encrypted file and its secret.
  echo Will prompt if private key is passphrase protected.
  usage
}

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
  -k|--key)
    KEYFILE="$2"
    shift # past argument
    ;;
  -t|--tarfile)
    TARFILE="$2"
    shift # past argument
    ;;
  --default)
    DEFAULT=YES
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

if [ -z "${KEYFILE// }" ]; then
  echo Private key file path not provided;
  usage
  exit 1;
fi;
if [ -z "${TARFILE// }" ]; then
  echo Compressed tar path not provided;
  usage
  exit 1;
fi;

KEYFILE=$(realpath ${KEYFILE})
TARFILE=$(realpath ${TARFILE})

mkdir tmp_dir
tar -zxvf ${TARFILE} -C tmp_dir
cd tmp_dir

ENCSECRET=$(find . -type f -name "*key*" -exec realpath {} \;)
SECRET=${ENCSECRET%.*}
ENCFILE=$(find . -type f -not -name "*key*" -exec realpath {} \;)
OUTFILE=${ENCFILE%.*}

echo ${ENCSECRET}
echo ${ENCFILE}
echo ${SECRET}
echo ${OUTFILE}

openssl rsautl -decrypt -ssl -inkey ${KEYFILE} -in ${ENCSECRET} -out ${SECRET}
openssl aes-256-cbc -d -in ${ENCFILE} -out ${OUTFILE} -pass file:${SECRET}
cp ${OUTFILE} ../
cd ../
rm -rf tmp_dir
