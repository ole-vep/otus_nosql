#!/bin/bash

# Example: ./upload_to_minio.sh example.url.com username password bucket-name minio/path/to/file.txt /upload/path/from/file.txt

if [ -z $1 ]; then
  echo "You have NOT specified a MINIO URL!"
  exit 1
fi

if [ -z $2 ]; then
  echo "You have NOT specified a USERNAME!"
  exit 1
fi

if [ -z $3 ]; then
  echo "You have NOT specified a PASSWORD!"
  exit 1
fi

if [ -z $4 ]; then
  echo "You have NOT specified a BUCKET!"
  exit 1
fi

if [ -z $5 ]; then
  echo "You have NOT specified a MINIO FILE PATH!"
  exit 1
fi

if [ -z $6 ]; then
  echo "You have NOT specified a UPLOAD FILE PATH!"
  exit 1
fi


# User Minio Vars
URL=$1
USERNAME=$2
PASSWORD=$3
BUCKET=$4
MINIO_PATH="/${BUCKET}/$5"
UPLOAD_FILE=$6

# Static Vars
DATE=$(date -R --utc)
CONTENT_TYPE='any/example'
SIG_STRING="PUT\n\n${CONTENT_TYPE}\n${DATE}\n${MINIO_PATH}"
SIGNATURE=`echo -en ${SIG_STRING} | openssl sha1 -hmac ${PASSWORD} -binary | base64`


curl -v -X PUT -T "${UPLOAD_FILE}" \
    -H "Host: $URL" \
    -H "Date: ${DATE}" \
    -H "Content-Type: ${CONTENT_TYPE}" \
    -H "Authorization: AWS ${USERNAME}:${SIGNATURE}" \
    http://$URL${MINIO_PATH}
