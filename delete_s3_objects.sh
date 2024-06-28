#!/bin/bash

BUCKET_NAME=$(cat bucket_name.txt)

if [ -z "$BUCKET_NAME" ]; then
  echo "Bucket name not found in bucket_name.txt"
  exit 1
fi

aws s3 rm s3://$BUCKET_NAME --recursive