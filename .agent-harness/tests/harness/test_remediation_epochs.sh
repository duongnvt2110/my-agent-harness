#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hash='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
cat > "$tmp/request.json" <<EOF
{"task_id":"task-epoch","run_id":"run-epoch","risk":"normal","reason":"BUDGET_EXHAUSTED","budget_exhausted":true,"failure_history_hash":"$hash"}
EOF
first="$($root/scripts/remediation-epoch.sh "$tmp/request.json" "$tmp/epochs.jsonl")"
echo "$first" | grep -q '"decision": "CONTINUE"'
echo "$first" | grep -q '"requires_human_review": false'
second="$($root/scripts/remediation-epoch.sh "$tmp/request.json" "$tmp/epochs.jsonl")"
echo "$second" | grep -q '"epoch_number": 2'
$root/scripts/check-remediation-epochs.sh "$tmp/epochs.jsonl" | grep -q 'remediation_epochs_valid: true'
if sed 's/"failure_history_preserved":true/"failure_history_preserved":false/' "$tmp/epochs.jsonl" > "$tmp/bad.jsonl" && $root/scripts/check-remediation-epochs.sh "$tmp/bad.jsonl" >/dev/null 2>&1; then
  echo 'epoch that resets failure history was accepted' >&2
  exit 1
fi
echo "Automatic remediation epoch regression passed."
