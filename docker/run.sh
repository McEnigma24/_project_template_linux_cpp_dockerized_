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
clear_dir "$DIR_OUTPUT"; mkdir -p "$(dirname "$LOG_run")"; : > "$LOG_run"
set +euo pipefail # allowing script to run after errors

container_id="$(docker run -d --rm \
  "$DOCKER_FULL_IMG_NAME" \
  bash -lc 'exec /app/build/*.exe')"

docker logs -f "$container_id" &> "$LOG_run" &
logs_pid=$!

run_status="$(docker wait "$container_id")"
wait "$logs_pid" 2>/dev/null || true

docker container prune -f


clear #
echo -en "\n\n"
if [ "$run_status" -eq 0 ]; then
  echo "✅ SUCCESS" | tee -a "$LOG_run"
else
  echo "❌ FAILED" | tee -a "$LOG_run"
fi
