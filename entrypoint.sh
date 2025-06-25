#!/usr/bin/env bash
set -eo pipefail

# Locate the real docker binary (moved aside by the action)
DOCKER_PATH=$(command -v docker)
DOCKER_REAL="${DOCKER_PATH}-original"

# Fail if the real binary isn't present
if [[ ! -x "$DOCKER_REAL" ]]; then
  echo "[entrypoint] ERROR: real docker not found at $DOCKER_REAL" >&2
  exit 1
fi

# Collect all GITHUB_* environment variables into Docker --label args
LABEL_ARGS=()
for var in $(printenv | grep '^GITHUB_' | awk -F= '{print $1}'); do
  val=${!var}
  [[ -z "$val" ]] && continue
  LABEL_ARGS+=(--label "${var}=${val}")
done

# Handle optional "extra-labels" input (comma-separated key=val pairs)
if [[ -n "${INPUT_EXTRA_LABELS}" ]]; then
  IFS=',' read -r -a extras <<< "${INPUT_EXTRA_LABELS}"
  for kv in "${extras[@]}"; do
    LABEL_ARGS+=(--label "$kv")
  done
fi

# Log the labels being injected, then delegate to the real Docker
echo "[entrypoint] injecting labels: ${LABEL_ARGS[*]}" >&2
exec "$DOCKER_REAL" "$@" "${LABEL_ARGS[@]}"
