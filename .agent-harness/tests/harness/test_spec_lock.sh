#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '{"task_id":"task-1","run_id":"run-1","spec_version":"v3.1","risk_decision_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","purpose":"v3 intake","acceptance":["lock exact hash"]}\n' > "$tmp/spec.json"
printf '{"action":"LOCK_SPECIFICATION","approved":true,"candidate_hash":"PLACEHOLDER","human_id":"human-1","task_id":"task-1","run_id":"run-1","risk_decision_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","approved_at":"2026-07-11T00:00:00Z","expires_at":"2099-07-12T00:00:00Z"}\n' > "$tmp/approval.json"
if scripts/spec-lock.sh create "$tmp/spec.json" "$tmp/direct.json" >/dev/null 2>&1; then
  echo "direct spec-lock authority creation was accepted" >&2
  exit 1
fi
if scripts/spec-lock.sh approve "$tmp/spec.json" "$tmp/approval.json" "$tmp/direct-locked.json" >/dev/null 2>&1; then
  echo "direct spec-lock authority approval was accepted" >&2
  exit 1
fi
echo "Specification lock regression passed."
