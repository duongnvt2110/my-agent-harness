#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/evidence" "$tmp/recovery"
plan="$tmp/current.md"
journal="$tmp/evidence/finalization-journal.json"
store="$tmp/tasks.jsonl"
cat > "$plan" <<'EOF'
---
task_id: old_task
status: VERIFIED
lifecycle_phase: REVIEW
---
EOF
cat > "$journal" <<'EOF'
{"journal_schema_version":1,"task_id":"old_task","status":"FINALIZED","steps":[{"name":"move_plan","status":"DONE","expected_after_hash":"0000000000000000000000000000000000000000000000000000000000000000"}]}
EOF
printf '%s\n' '{"id":"old_task","title":"Old task","status":"IN_PROGRESS","depends_on":[]}' > "$store"

out="$(./scripts/recover-finalization.sh --journal "$journal" --plan "$plan" --task-store "$store" --recovery-dir "$tmp/recovery" --successor-task old_task_successor --successor-title 'Old task successor')"
echo "$out" | grep -q '"status": "RECOVERED"'
[ ! -e "$plan" ]
archive="$(echo "$out" | python3 -c 'import json,sys; print(json.load(sys.stdin)["archive_path"])')"
[ -f "$archive" ]
grep -q '"status":"DONE"' "$store"
grep -q '"status":"READY"' "$store"
grep -q '"supersedes_task_id":"old_task"' "$store"

if ./scripts/recover-finalization.sh --journal "$journal" --plan "$archive" --task-store "$store" --recovery-dir "$tmp/recovery" --successor-task old_task_successor --successor-title 'Old task successor' >/dev/null 2>&1; then
  echo 'recovery unexpectedly accepted an archived plan' >&2
  exit 1
fi

echo 'Finalization recovery and successor projection regression passed.'
