#!/bin/bash
source config

./docker/compile.sh "$@"

# DOCKER_IMG_PREFIX
DOCKER_TARGET="runner"
DOCKER_FULL_IMG_NAME="${DOCKER_IMG_PREFIX}${DOCKER_TARGET}"



# BUILD #
clear; # all things before (like compile.sh) - no need for allowing to run after errors, there is nothing to clear
docker build --target "$DOCKER_TARGET" -t "$DOCKER_FULL_IMG_NAME" .
docker image prune -f

# RUN #
clear; # clearing docker build logs
clear_dir "$DIR_OUTPUT"; mkdir -p "$(dirname "$LOG_run")"; set +euo pipefail # allowing script to run after errors
docker run --rm -it \
  "$DOCKER_FULL_IMG_NAME" \
  bash -lc 'exec /app/build/*.exe' &> "$LOG_run"



run_status="$?"
docker container prune -f


clear #
cat $LOG_run && echo -e "\n"
if [ $run_status -eq 0 ]; then
  echo "✅ SUCCESS"
else
  echo "❌ FAILED"
fi
