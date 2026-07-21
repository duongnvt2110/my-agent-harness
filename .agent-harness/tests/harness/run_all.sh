#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$test_dir/../.." && pwd)"

cd "$harness_root"

TEST_ROOT="$test_dir"
DEFAULT_TIMEOUT=120
FILTER=""
LIST_ONLY=false
FAIL_FAST=false
PROVENANCE_KEY_FILE="$(mktemp)"
trap 'rm -f "$PROVENANCE_KEY_FILE"' EXIT
openssl rand -hex 32 > "$PROVENANCE_KEY_FILE"
chmod 600 "$PROVENANCE_KEY_FILE"

usage() {
  cat <<'USAGE'
Usage: tests/harness/run_all.sh [--test-dir DIR] [--timeout SECONDS] [--filter GLOB] [--list] [--fail-fast]

Runs every harness regression test in deterministic filename order. Each test is
wrapped in a per-test timeout so a single hung test cannot block the full suite.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --test-dir)
      TEST_ROOT="${2:-}"
      [ -n "$TEST_ROOT" ] || { echo "--test-dir requires a directory" >&2; exit 2; }
      shift 2
      ;;
    --timeout)
      DEFAULT_TIMEOUT="${2:-}"
      [ -n "$DEFAULT_TIMEOUT" ] || { echo "--timeout requires seconds" >&2; exit 2; }
      shift 2
      ;;
    --filter)
      FILTER="${2:-}"
      [ -n "$FILTER" ] || { echo "--filter requires a shell glob or filename" >&2; exit 2; }
      shift 2
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --fail-fast)
      FAIL_FAST=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$DEFAULT_TIMEOUT" in
  ''|*[!0-9]*) echo "Timeout must be a positive integer: $DEFAULT_TIMEOUT" >&2; exit 2 ;;
esac
[ "$DEFAULT_TIMEOUT" -gt 0 ] || { echo "Timeout must be > 0" >&2; exit 2; }

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

should_skip_test() {
  local base="$1"
  if [ -n "$FILTER" ] && [[ "$base" != $FILTER ]]; then
    return 0
  fi
  return 1
}

tests=()
while IFS= read -r test; do
  [ -n "$test" ] || continue
  tests+=("$test")
done < <(find "$TEST_ROOT" -maxdepth 1 -type f -name 'test_*.sh' | sort)

selected=()
for test in "${tests[@]}"; do
  base="$(basename "$test")"
  [ "$base" = "run_all.sh" ] && continue
  if should_skip_test "$base"; then
    continue
  fi
  selected+=("$test")
done

if [ "$LIST_ONLY" = true ]; then
  for test in "${selected[@]}"; do
    basename "$test"
  done
  exit 0
fi

if [ "${#selected[@]}" -eq 0 ]; then
  echo "No harness tests selected."
  exit 1
fi

passed=()
failed=()
timed_out=()
started_at="$(date '+%Y-%m-%d %H:%M:%S %z')"

for test in "${selected[@]}"; do
  base="$(basename "$test")"
  echo "Running $base (timeout: ${DEFAULT_TIMEOUT}s)"
  tmp="$(mktemp)"
  set +e
  run_with_timeout "$DEFAULT_TIMEOUT" \
    env -i \
      PATH="$PATH" \
      HOME="${HOME:-$harness_root}" \
      TMPDIR="${TMPDIR:-/tmp}" \
      LANG=C \
      LC_ALL=C \
      AGENT_HARNESS_BOOTSTRAPPED="${AGENT_HARNESS_BOOTSTRAPPED:-0}" \
      AGENT_HARNESS_BOOTSTRAPPED_ROOT="${AGENT_HARNESS_BOOTSTRAPPED_ROOT:-}" \
      HARNESS_PROVENANCE_KEY_FILE="$PROVENANCE_KEY_FILE" \
      HARNESS_AUTHORITY_MODE=ENFORCED \
      bash "$test" >"$tmp" 2>&1
  exit_code=$?
  set -e
  cat "$tmp"
  rm -f "$tmp"

  if [ "$exit_code" -eq 0 ]; then
    passed+=("$base")
  elif [ "$exit_code" -eq 124 ] || [ "$exit_code" -eq 137 ] || [ "$exit_code" -eq 142 ] || [ "$exit_code" -eq 143 ]; then
    timed_out+=("$base")
    failed+=("$base")
    echo "TIMEOUT: $base exceeded ${DEFAULT_TIMEOUT}s" >&2
  else
    failed+=("$base")
    echo "FAILED: $base exited with $exit_code" >&2
  fi

  if [ "$FAIL_FAST" = true ] && [ "${#failed[@]}" -gt 0 ]; then
    break
  fi
done

finished_at="$(date '+%Y-%m-%d %H:%M:%S %z')"

echo
echo "Harness test summary"
echo "started_at: $started_at"
echo "finished_at: $finished_at"
echo "selected: ${#selected[@]}"
echo "passed: ${#passed[@]}"
echo "failed: ${#failed[@]}"
echo "timed_out: ${#timed_out[@]}"

if [ "${#failed[@]}" -gt 0 ]; then
  echo
  echo "Failed tests:"
  printf -- '- %s\n' "${failed[@]}"
  exit 1
fi

echo "Harness test suite passed."
