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
clear
docker run --rm -it \
  -v "$(pwd):/workspace" \
  -w /workspace \
  "$DOCKER_FULL_IMG_NAME"

docker container prune -f
clear
