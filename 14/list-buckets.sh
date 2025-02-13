#!/bin/bash

# Example: ./list-buckets.sh example.url.com:9000 username password

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

# User Minio Vars
URL=$1
USERNAME=$2
PASSWORD=$3
MINIO_PATH="/"

# Static Vars
DATE=$(date -R --utc)
CONTENT_TYPE='application/zstd'
SIG_STRING="GET\n\n${CONTENT_TYPE}\n${DATE}\n${MINIO_PATH}"
SIGNATURE=`echo -en ${SIG_STRING} | openssl sha1 -hmac ${PASSWORD} -binary | base64`
PROTOCOL="http"

curl -k -H "Host: $URL" \
    -H "Date: ${DATE}" \
    -H "Content-Type: ${CONTENT_TYPE}" \
    -H "Authorization: AWS ${USERNAME}:${SIGNATURE}" \
    ${PROTOCOL}://$URL${MINIO_PATH}

