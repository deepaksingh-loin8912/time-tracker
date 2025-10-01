#!/bin/bash
set -euo pipefail

ACTION="$1"
JSON_FILE="${2:-scripts/docker-images.json}"

AWS_REGION="${AWS_REGION:-ap-southeast-2}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-266980971030}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

if [[ "$ACTION" != "pull_save" && "$ACTION" != "load_push" ]]; then
  echo "Usage: $0 pull_save|load_push [json_file]"
  exit 1
fi

jq -c '.[]' "$JSON_FILE" | while read -r item; do
  SOURCE=$(echo "$item" | jq -r '.source')
  TAG=$(echo "$item" | jq -r '.tag')
  TARGET_REPO=$(echo "$item" | jq -r '.target_repo')
  IMAGE_NAME="${SOURCE}:${TAG}"
  TAR_NAME="$(basename "$SOURCE")-${TAG}.tar"
  TAR_PATH="./mybackstage/docker_images/$TAR_NAME"
  ECR_IMAGE="$ECR_REGISTRY/$TARGET_REPO:$TAG"

  if [[ "$ACTION" == "pull_save" ]]; then
    echo "Pulling $IMAGE_NAME"
    docker pull "$IMAGE_NAME"
    mkdir -p ./mybackstage/docker_images
    echo "Saving $IMAGE_NAME to $TAR_PATH"
    docker save "$IMAGE_NAME" -o "$TAR_PATH"

  elif [[ "$ACTION" == "load_push" ]]; then
    echo "Loading $TAR_PATH"
    docker load -i "$TAR_PATH"

    echo "Tagging $IMAGE_NAME as $ECR_IMAGE"
    docker tag "$IMAGE_NAME" "$ECR_IMAGE"

    echo "Pushing $ECR_IMAGE"
    docker push "$ECR_IMAGE"
  fi
done
