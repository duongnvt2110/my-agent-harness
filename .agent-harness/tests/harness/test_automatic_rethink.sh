#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hash='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
for index in 1 2 3; do
  cat > "$tmp/failure.json" <<EOF
{"run_id":"run-rethink","task_id":"task-rethink","risk":"normal","kind":"test","message":"same failing strategy","spec_hash":"$hash","policy_hash":"$hash","command_hash":"$hash","environment_hash":"$hash","patch_hash":"$hash","session_id":"session-$index","rerun_index":$index,"rerun_confirmed":true}
EOF
  "$root/scripts/record-failure.sh" "$tmp/history.jsonl" "$tmp/failure.json" >/dev/null
done
"$root/scripts/check-failure-history.sh" "$tmp/history.jsonl" >/dev/null
result="$($root/scripts/rethink.sh "$tmp/history.jsonl" "$tmp/rethink.json")"
echo "$result" | grep -q '"decision": "CONTINUE"'
echo "$result" | grep -q '"requires_human_review": false'
grep -q '"action": "CONTINUE_WITH_NEW_STRATEGY"' "$tmp/rethink.json"
grep -q '"next_state": "REMEDIATING"' "$tmp/rethink.json"
echo "Automatic rethink regression passed."
