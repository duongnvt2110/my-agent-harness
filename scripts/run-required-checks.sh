#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

rows="$(required_check_rows "$PLAN_PATH")"
[ -n "$rows" ] || fail "No required checks found"

while IFS=$'\t' read -r id type command blocking evidence allow_raw reason; do
  [ -n "$id" ] || continue
  mkdir -p "$(dirname "$evidence")"
  tmp="$(mktemp)"
  started_at="$(date '+%Y-%m-%d %H:%M:%S %z')"
  set +e
  bash -lc "$command" > "$tmp" 2>&1
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
    echo "result: $result"
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

