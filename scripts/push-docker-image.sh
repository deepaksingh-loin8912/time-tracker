jq -c '.[]' "$JSON_FILE" | while read -r item; do
  SOURCE=$(echo "$item" | jq -r '.source')
  TAG=$(echo "$item" | jq -r '.tag')
  TARGET_REPO=$(echo "$item" | jq -r '.target_repo')
  ...
  TAR_NAME="$(basename "$SOURCE")-${TAG}.tar"
  TAR_PATH="./mybackstage/docker_images/$TAR_NAME"
