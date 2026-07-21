#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

mode="$(fm_value "$PLAN_PATH" "environment_mode")"
setup_required="$(fm_value "$PLAN_PATH" "environment_setup_required")"

if [ "$setup_required" != "true" ]; then
  echo "Environment setup not required."
  exit 0
fi

case "$mode" in
  docker_compose)
    compose_file="$(fm_value "$PLAN_PATH" "environment_compose_file")"
    service="$(fm_value "$PLAN_PATH" "environment_service")"

    [ -n "$compose_file" ] && [ "$compose_file" != "null" ] || fail "docker_compose mode requires environment_compose_file"
    [ -n "$service" ] && [ "$service" != "null" ] || fail "docker_compose mode requires environment_service"

    compose_args=(-f "$compose_file")
    container_id="$(docker compose "${compose_args[@]}" ps -q "$service" 2>/dev/null || true)"

    if [ -n "$container_id" ]; then
      if docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null | grep -q '^true$'; then
        echo "docker-compose service '$service' is already running; reusing container $container_id."
        exit 0
      fi

      echo "Starting existing docker-compose service '$service' without rebuilding."
      docker compose "${compose_args[@]}" start "$service"
      exit 0
    fi

    echo "Starting docker-compose service '$service' with initial build."
    docker compose "${compose_args[@]}" up -d --build "$service"
    ;;
  local)
    if [ "$setup_required" = "true" ]; then
      fail "environment_setup_required=true requires docker_compose mode"
    fi
    echo "Environment setup not required for local mode."
    ;;
  *)
    fail "Invalid environment_mode '$mode' (expected local|docker_compose)"
    ;;
esac
