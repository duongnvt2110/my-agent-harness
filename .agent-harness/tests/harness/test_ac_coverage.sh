#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '%s\n' '{"acceptance_criteria":[{"id":"AC-001","blocking":true},{"id":"AC-002","blocking":true}]}' >"$tmp/spec.json"
printf '%s\n' '{"tasks":[{"id":"task-a","acceptance_criteria":["AC-001"],"verification_artifacts":["ev-a"]},{"id":"task-b","acceptance_criteria":["AC-002"],"depends_on":["task-a"],"verification_artifacts":["ev-b"]}]}' >"$tmp/tasks.json"
printf '%s\n' '{"checks":[{"id":"check-a","ac_ids":["AC-001"],"result":"PASSED","evidence_hash":"hash-a"},{"id":"check-b","ac_ids":["AC-002"],"result":"PASSED","evidence_hash":"hash-b"}]}' >"$tmp/checks.json"

output="$($harness_root/scripts/check-ac-coverage.sh "$tmp/spec.json" "$tmp/tasks.json" "$tmp/checks.json")"
echo "$output" | grep -q '"valid": true'
impact="$($harness_root/scripts/check-ac-coverage.sh "$tmp/spec.json" "$tmp/tasks.json" "$tmp/checks.json" AC-001)"
echo "$impact" | grep -q '"affected_tasks": \["task-a", "task-b"\]'
echo "$impact" | grep -q '"invalidated_artifacts": \["ev-a", "ev-b"\]'

printf '%s\n' '{"checks":[{"id":"check-a","ac_ids":["AC-001"],"result":"PASSED","evidence_hash":"hash-a"}]}' >"$tmp/incomplete.json"
if "$harness_root/scripts/check-ac-coverage.sh" "$tmp/spec.json" "$tmp/tasks.json" "$tmp/incomplete.json" >/dev/null 2>&1; then
  echo "incomplete AC evidence was accepted" >&2
  exit 1
fi
incomplete_impact="$($harness_root/scripts/check-ac-coverage.sh "$tmp/spec.json" "$tmp/tasks.json" "$tmp/incomplete.json" AC-001 || true)"
echo "$incomplete_impact" | grep -q '"invalidates_all": true'
echo "$incomplete_impact" | grep -q '"affected_tasks": \["task-a", "task-b"\]'

echo "AC coverage regression passed."
