#!/usr/bin/env bash

set -eo pipefail

CMD_NAME=$(basename "$0")                     # "docker" or "docker-buildx"
REAL_PATH="$(command -v "$CMD_NAME")-original"

if [[ ! -x "$REAL_PATH" ]]; then
  echo "[entrypoint] ERROR: real $CMD_NAME not found at $REAL_PATH" >&2
  exit 1
fi

INJECT=false
if [[ "$CMD_NAME" == "docker-buildx" ]]; then
  INJECT=true
elif [[ "$CMD_NAME" == "docker" && "$1" == "build" ]]; then
  INJECT=true
fi

if [[ "$INJECT" != true ]]; then
  # Not a build command → just run Docker as normal
  exec "$REAL_PATH" "$@"
fi

# It’s a build/buildx command → collect labels
LABEL_ARGS=()
while IFS='=' read -r var val; do
  if [[ "$var" =~ ^GITHUB_ ]]; then
    LABEL_ARGS+=(--label "${var}=${val}")
  fi
done < <(printenv)

echo "[entrypoint] injecting labels: ${LABEL_ARGS[*]}" >&2
exec "$REAL_PATH" "$@" "${LABEL_ARGS[@]}"
