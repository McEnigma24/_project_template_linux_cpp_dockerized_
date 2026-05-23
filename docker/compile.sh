#!/bin/bash
source config



# DOCKER_IMG_PREFIX
DOCKER_TARGET="dev-env"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"



# BUILD #
clear
docker build --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" .
docker image prune -f

# RUN #
clear; clear_dir "$DIR_LOG"
docker run --rm -it \
  -v "$(pwd):/workspace" \
  -w /workspace \
  "$DOCKER_FULL_IMG_NAME" \
  bash "./docker/start.sh" "$@"

compilation_status=$?
docker container prune -f
clear

cat $LOG_start && echo -e "\n"
if [ $compilation_status -eq 0 ]; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
fi
