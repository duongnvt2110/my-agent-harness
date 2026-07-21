#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

run_with_timeout() {
  local timeout_seconds="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_seconds" "$@"
    return
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$timeout_seconds" "$@"
    return
  fi
  perl -e 'alarm shift; exec @ARGV' "$timeout_seconds" "$@"
}

verification_mode="$(fm_value "$PLAN_PATH" "verification_mode")"
rows="$(required_check_rows "$PLAN_PATH")"

if [ "$verification_mode" = "none" ]; then
  [ -z "$rows" ] || fail "verification_mode=none requires no required checks"
  echo "No required checks declared."
  exit 0
fi

[ -n "$rows" ] || fail "No required checks found"

while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
  [ -n "$id" ] || continue
  type="${type:-automated}"

  [ -n "$command" ] || fail "Required check '$id' missing command"
  [ -n "$timeout_seconds" ] || fail "Required check '$id' missing timeout_seconds"

  mkdir -p "$(dirname "$evidence")"
  tmp="$(mktemp)"
  started_at="$(date '+%Y-%m-%d %H:%M:%S %z')"
  set +e
  if [ -x ./scripts/run-in-env.sh ]; then
    run_with_timeout "$timeout_seconds" ./scripts/run-in-env.sh bash -lc "$command" > "$tmp" 2>&1
  else
    run_with_timeout "$timeout_seconds" bash -lc "$command" > "$tmp" 2>&1
  fi
  exit_code=$?
  set -e
  finished_at="$(date '+%Y-%m-%d %H:%M:%S %z')"

  result="pass"
  if [ "$exit_code" -ne 0 ]; then
    if [ "$blocking" = "true" ]; then
      result="fail"
    else
      result="warning"
    fi
  fi

  {
    echo "# Required Check Evidence: $id"
    echo
    echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
    echo "check_id: $id"
    echo "type: ${type:-automated}"
    echo "blocking: $blocking"
    echo "timeout_seconds: $timeout_seconds"
    echo "result: $result"
    if [ -n "$reason" ]; then
      echo "reason: $reason"
    fi
    echo "exit_code: $exit_code"
    echo "started_at: $started_at"
    echo "finished_at: $finished_at"
    echo
    echo "## Command"
    echo
    echo '```text'
    echo "$command"
    echo '```'
    echo
    echo "## Output"
    echo
    echo '```text'
    cat "$tmp"
    echo '```'
  } > "$evidence"

  if [ "$exit_code" -ne 0 ] && [ "$blocking" = "true" ]; then
    write_failure_packet "$id" "$command" "$exit_code" "$tmp"
    rm -f "$tmp"
    exit "$exit_code"
  fi

  rm -f "$tmp"
done <<< "$rows"

echo "Required checks completed."
