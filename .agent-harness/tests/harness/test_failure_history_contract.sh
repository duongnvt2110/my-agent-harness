#!/usr/bin/env bash
set -euo pipefail
harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '%s\n' '{"run_id":"run-1","task_id":"task-1","risk":"tiny","kind":"test","message":"/tmp/build/123 failed","spec_hash":"s","policy_hash":"p","command_hash":"c","environment_hash":"e","patch_hash":"x","rerun_confirmed":true}' >"$tmp/failure.json"
first="$($harness_root/scripts/record-failure.sh "$tmp/history.jsonl" "$tmp/failure.json")"
echo "$first" | grep -q '"resolution": "REMEDIATING"'
sed 's/123/456/' "$tmp/failure.json" >"$tmp/failure2.json"
second="$($harness_root/scripts/record-failure.sh "$tmp/history.jsonl" "$tmp/failure2.json")"
echo "$second" | grep -q '"resolution": "RETHINK_REQUIRED"'
"$harness_root/scripts/check-failure-history.sh" "$tmp/history.jsonl" | grep -q '^failure_history_valid: true$'
printf '%s\n' '{"run_id":"run-2","task_id":"task-1","risk":"normal","kind":"unknown_side_effect","message":"uncertain","spec_hash":"s","policy_hash":"p","command_hash":"c","environment_hash":"e","patch_hash":"x"}' >"$tmp/uncertain.json"
uncertain="$($harness_root/scripts/record-failure.sh "$tmp/history.jsonl" "$tmp/uncertain.json")"
echo "$uncertain" | grep -q '"resolution": "RECOVERY_REQUIRED"'
if sed 's/"threshold":3/"threshold":2/' "$tmp/history.jsonl" >"$tmp/bad-history.jsonl" && "$harness_root/scripts/check-failure-history.sh" "$tmp/bad-history.jsonl" >/dev/null 2>&1; then
  echo "inconsistent failure threshold was accepted" >&2
  exit 1
fi
echo "Failure history regression passed."
