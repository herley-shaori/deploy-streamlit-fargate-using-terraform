#!/bin/bash

# Bucket name
BUCKET_NAME="codepipeline-artifacts-bucket-3833434kjsadaksd"  # Replace with your actual bucket name

# Check if bucket name is provided
if [ -z "$BUCKET_NAME" ]; then
  echo "Bucket name is required."
  exit 1
fi

# Delete all objects in the bucket
aws s3 rm s3://$BUCKET_NAME --recursive

# Check if the command succeeded
if [ $? -eq 0 ]; then
  echo "All objects in the bucket '$BUCKET_NAME' have been deleted successfully."
else
  echo "Failed to delete objects in the bucket '$BUCKET_NAME'."
  exit 1
fi