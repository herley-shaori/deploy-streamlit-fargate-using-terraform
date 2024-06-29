#!/bin/bash

# Check if ecr_name.txt file exists
if [ ! -f ecr_name.txt ]; then
  echo "File ecr_name.txt not found!"
  exit 1
fi

# Read each repository name from ecr_name.txt
while IFS= read -r repo_name; do
  echo "Processing repository: $repo_name"

  # Get a list of all image digests in the repository
  image_digests=$(aws ecr list-images --repository-name "$repo_name" --query 'imageIds[*].imageDigest' --output text)

  # Check if there are images to delete
  if [ -z "$image_digests" ]; then
    echo "No images found in repository $repo_name."
    continue
  fi

  # Delete all images in the repository
  for digest in $image_digests; do
    aws ecr batch-delete-image --repository-name "$repo_name" --image-ids imageDigest="$digest"
    echo "Deleted image with digest: $digest"
  done

done < ecr_name.txt

echo "Script execution completed."