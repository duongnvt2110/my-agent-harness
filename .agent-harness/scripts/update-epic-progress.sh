#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

EPIC_ROOT="${EPIC_ROOT:-docs/epics}"

epic_id="${1:-$(fm_value "$PLAN_PATH" "parent_epic_id")}"
[ -n "$epic_id" ] && [ "$epic_id" != "null" ] || exit 0

epic_dir="$EPIC_ROOT/$epic_id"
progress_file="$epic_dir/progress.md"
memory_file="$epic_dir/epic-memory.md"
story_id="$(fm_value "$PLAN_PATH" "parent_story_id")"
task_id="$(fm_value "$PLAN_PATH" "task_id")"
task_status="$(fm_value "$PLAN_PATH" "status")"
task_title="$(fm_value "$PLAN_PATH" "title")"
story_registry="$epic_dir/stories.jsonl"
task_store="${TASK_STORE:-docs/tasks/tasks.jsonl}"
verification_result="missing"
if [ -f "$(evidence_dir)/verification-pass.md" ]; then
  verification_result="$(awk -F: '/^result:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$(evidence_dir)/verification-pass.md")"
fi
completed_files="none"
completed_files="$(./scripts/list-baseline-changes.sh --format name-only | paste -sd ', ' -)"
[ -n "$completed_files" ] || completed_files="none"
task_store_hash="$(shasum -a 256 "$task_store" | awk '{print $1}')"
story_registry_hash="$(shasum -a 256 "$story_registry" | awk '{print $1}')"

[ -f "$progress_file" ] || fail "Missing epic progress file: $progress_file"
[ -f "$memory_file" ] || fail "Missing epic memory file: $memory_file"
[ -f "$story_registry" ] || fail "Missing story registry: $story_registry"

epic_status="$(
  python3 - "$story_registry" <<'PY'
import json
import pathlib
import sys

rows = [json.loads(line) for line in pathlib.Path(sys.argv[1]).read_text().splitlines() if line.strip()]
statuses = [row.get("status", "") for row in rows]
if not rows:
    print("DRAFT")
elif any(status == "BLOCKED" for status in statuses):
    print("BLOCKED")
elif all(status == "DONE" for status in statuses):
    print("DONE")
elif any(status == "ACTIVE" for status in statuses):
    print("ACTIVE")
else:
    print("READY")
PY
)"

append_update() {
  local target="$1"
  # The projection must record aggregate status changes.  A repeated update
  # is idempotent only when the same task already has the same epic status.
  if grep -Fq -- "- task_id: $task_id" "$target" && grep -Fq -- "- epic_status: $epic_status" "$target"; then
    return 0
  fi
  {
  echo
  echo "## Update"
  echo
  echo "- task_id: $task_id"
  echo "- projection_schema_version: 1"
  echo "- task_title: $task_title"
  echo "- story_id: $story_id"
  echo "- status: $task_status"
  echo "- epic_status: $epic_status"
  echo "- verification_result: $verification_result"
  echo "- task_store_hash: $task_store_hash"
  echo "- story_registry_hash: $story_registry_hash"
  echo "- completed_files: ${completed_files:-none}"
  echo "- summary: Completed harness review hardening and re-verification."
  echo "- recorded_at: $(date '+%Y-%m-%d %H:%M')"
  } >> "$target"
}

append_update "$progress_file"

if [ -n "$story_id" ] && [ "$story_id" != "null" ]; then
  append_update "$memory_file"
fi

echo "Updated epic progress: $epic_id"
