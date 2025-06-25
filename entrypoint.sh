#!/usr/bin/env bash

set -eo pipefail

# 1) Find the real binary (moved aside by the action)
DOCKER_PATH=$(command -v docker)
DOCKER_REAL="${DOCKER_PATH}-original"

# 2) Fail if it’s not where we expect
if [[ ! -x "$DOCKER_REAL" ]]; then
  echo "[entrypoint] ERROR: real docker not found at $DOCKER_REAL" >&2
  exit 1
fi

# 3) Collect all GITHUB_* envs into --label args
LABEL_ARGS=()
while IFS='=' read -r var val; do
  if [[ "$var" =~ ^GITHUB_ ]]; then
    LABEL_ARGS+=(--label "${var}=${val}")
  fi
done < <(printenv)

# 4) Log and hand off
echo "[entrypoint] injecting labels: ${LABEL_ARGS[*]}" >&2
exec "$DOCKER_REAL" "$@" "${LABEL_ARGS[@]}"
