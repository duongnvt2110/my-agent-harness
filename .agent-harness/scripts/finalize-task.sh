#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

[ -f "$PLAN_PATH" ] || fail "Missing active plan: $PLAN_PATH"

if [ "$(fm_value "$PLAN_PATH" "v4_verification_required")" = "true" ]; then
  v4_proposal="${HARNESS_V4_PROPOSAL_PATH:-}"
  v4_verdict="${HARNESS_V4_VERDICT_PATH:-$(evidence_dir)/v4-verification.json}"
  [ -n "$v4_proposal" ] && [ -f "$v4_proposal" ] || fail "v4 verification requires HARNESS_V4_PROPOSAL_PATH"
  mkdir -p "$(dirname "$v4_verdict")"
  if ! PLAN_PATH="$PLAN_PATH" "$script_dir/verify-proposal.sh" "$v4_proposal" "$PLAN_PATH" "${HARNESS_V4_RUN_ID:-v4-finalization}" >"$v4_verdict"; then
    fail "v4 independent verification failed"
  fi
  PLAN_PATH="$PLAN_PATH" "$script_dir/check-v4-verification.sh" "$v4_verdict" "$PLAN_PATH"
fi

./scripts/verify.sh

if [ -x ./scripts/check-v3-contract-coverage.sh ]; then
  ./scripts/check-v3-contract-coverage.sh
fi

if [ -n "${HARNESS_READINESS_PATH:-}" ]; then
  [ -x ./scripts/readiness-control.sh ] || fail "Missing readiness validator"
  readiness_result="$(./scripts/readiness-control.sh verify "$HARNESS_READINESS_PATH")" || fail "Implementation readiness verification failed"
  printf '%s' "$readiness_result" | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("ready") else 1)' || fail "Implementation readiness is not ready"
fi

pass_file="$(evidence_dir)/verification-pass.md"
[ -f "$pass_file" ] || fail "Missing verification pass file after verify: $pass_file"
test_report="$(evidence_dir)/test-report.md"
[ -f "$test_report" ] || fail "Missing test report after verify: $test_report"

status="$(fm_value "$PLAN_PATH" "status")"
[ "$status" = "VERIFIED" ] || fail "Finalization requires status=VERIFIED, got '$status'"

maybe_close_related_epic_story() {
  local epic_id story_id task_store epic_root closed_anything
  epic_id="$(fm_value "$PLAN_PATH" "parent_epic_id")"
  story_id="$(fm_value "$PLAN_PATH" "parent_story_id")"
  closed_anything="false"

  case "$epic_id" in
    ""|"null")
      return 0
      ;;
  esac
  case "$story_id" in
    ""|"null")
      return 0
      ;;
  esac

  task_store="${TASK_STORE:-docs/tasks/tasks.jsonl}"
  epic_root="${EPIC_ROOT:-docs/epics}"

  if python3 - "$task_store" "$epic_id" "$story_id" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
epic_id = sys.argv[2]
story_id = sys.argv[3]
rows = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]
for row in rows:
    if row.get("epic_id") == epic_id and row.get("story_id") == story_id and row.get("status") != "DONE":
        raise SystemExit(1)
raise SystemExit(0)
PY
  then
    EPIC_ROOT="$epic_root" TASK_STORE="$task_store" ./scripts/story.sh complete "$epic_id" "$story_id" >/dev/null
    closed_anything="true"
  fi

  if python3 - "$epic_root" "$epic_id" <<'PY'
import json
import pathlib
import sys

epic_root = pathlib.Path(sys.argv[1])
epic_id = sys.argv[2]
story_registry = epic_root / epic_id / "stories.jsonl"
rows = [json.loads(line) for line in story_registry.read_text().splitlines() if line.strip()]
if rows and all(row.get("status") == "DONE" for row in rows):
    raise SystemExit(0)
raise SystemExit(1)
PY
  then
    EPIC_ROOT="$epic_root" TASK_STORE="$task_store" ./scripts/epic.sh complete "$epic_id" >/dev/null
    closed_anything="true"
  fi

  if [ "$closed_anything" = "false" ] && [ -x ./scripts/update-epic-progress.sh ]; then
    EPIC_ROOT="$epic_root" TASK_STORE="$task_store" ./scripts/update-epic-progress.sh
  fi
}

task_id="$(fm_value "$PLAN_PATH" "task_id")"
task_title="$(fm_value "$PLAN_PATH" "title")"

restore_finalizing_plan_on_failure() {
  local exit_code="$?"
  if [ "$exit_code" -ne 0 ] && [ -f "$PLAN_PATH" ] && [ "$(fm_value "$PLAN_PATH" "lifecycle_phase")" = "COMPLETED" ]; then
    set_fm_value "$PLAN_PATH" "status" "VERIFIED"
    set_fm_value "$PLAN_PATH" "lifecycle_phase" "FINALIZE"
    echo "Finalization interrupted; active plan restored to FINALIZE for retry." >&2
  fi
  exit "$exit_code"
}
trap restore_finalizing_plan_on_failure EXIT

journal_file="$(evidence_dir)/finalization-journal.json"
plan_hash() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$PLAN_PATH" | awk '{print $1}'
  else
    shasum -a 256 "$PLAN_PATH" | awk '{print $1}'
  fi
}
write_journal() {
  local status="$1" step="$2" before_hash="$3" after_hash="$4"
  python3 - "$journal_file" "$task_id" "$status" "$step" "$before_hash" "$after_hash" <<'PY'
import json
import os
import pathlib
import sys
import tempfile
from datetime import datetime, timezone

path = pathlib.Path(sys.argv[1])
task_id, status, step, before_hash, after_hash = sys.argv[2:]
if path.exists():
    data = json.loads(path.read_text())
else:
    data = {
        "journal_schema_version": 1,
        "task_id": task_id,
        "status": "FINALIZING",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "steps": [
            {"name": name, "status": "PENDING"}
            for name in ("verify", "review", "mark_terminal", "task_projection", "reports", "move_plan")
        ],
    }
if data.get("task_id") != task_id:
    raise SystemExit("finalization journal task mismatch")
if step:
    found = False
    for item in data["steps"]:
        if item["name"] == step:
            found = True
            if before_hash:
                item["expected_before_hash"] = before_hash
            if after_hash:
                item["expected_after_hash"] = after_hash
            item["status"] = "DONE"
            item["completed_at"] = datetime.now(timezone.utc).isoformat()
    if not found:
        raise SystemExit(f"unknown finalization journal step: {step}")
data["status"] = status
data["updated_at"] = datetime.now(timezone.utc).isoformat()
if status == "FINALIZED":
    data["finalized_at"] = data["updated_at"]
path.parent.mkdir(parents=True, exist_ok=True)
fd, tmp = tempfile.mkstemp(prefix=path.name + ".", dir=path.parent)
try:
    with os.fdopen(fd, "w") as handle:
        json.dump(data, handle, indent=2, sort_keys=True)
        handle.write("\n")
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(tmp, path)
finally:
    if os.path.exists(tmp):
        os.unlink(tmp)
PY
}

if [ -f "$journal_file" ]; then
  journal_status="$(python3 - "$journal_file" "$task_id" <<'PY'
import json, pathlib, sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text())
if data.get("task_id") != sys.argv[2] or data.get("journal_schema_version") != 1:
    raise SystemExit("invalid finalization journal")
print(data.get("status", ""))
PY
)"
  [ "$journal_status" != "FINALIZED" ] || fail "Finalization journal is already FINALIZED: $journal_file"
fi

batch_approval_path="${HARNESS_BATCH_APPROVAL_PATH:-$HARNESS_ROOT/runtime/v3-approved-batch.json}"
batch_finalization="false"
if [ -f "$batch_approval_path" ]; then
  ./scripts/check-batch-approval.sh "$batch_approval_path" "$PLAN_PATH"
  batch_finalization="true"
fi

if [ "$(fm_value "$PLAN_PATH" "review_required")" = "true" ] && [ "$batch_finalization" != "true" ]; then
  ./scripts/check-reviews.sh
  review_file="$(find docs/reviews -type f -name "*.md" ! -name "TEMPLATE.md" -print0 2>/dev/null | xargs -0 grep -l "^task_id:[[:space:]]*$(fm_value "$PLAN_PATH" "task_id")$" 2>/dev/null | head -n 1 || true)"
  [ -n "$review_file" ] || fail "Final review artifact disappeared after review validation"
  ./scripts/check-finalization-authority.sh review "$PLAN_PATH" "$review_file" "$pass_file"
fi

write_journal "FINALIZING" "" "" ""
write_journal "FINALIZING" "verify" "" ""
if [ "$(fm_value "$PLAN_PATH" "review_required")" = "true" ] && [ "$batch_finalization" != "true" ]; then
  write_journal "FINALIZING" "review" "" ""
else
  write_journal "FINALIZING" "review" "" ""
fi

completed_dir="$(dirname "$(dirname "$PLAN_PATH")")/completed"
active_gitkeep="$(dirname "$(dirname "$PLAN_PATH")")/active/.gitkeep"
completed_at="$(date '+%Y-%m-%d %H:%M')"
completed_stamp="$(date '+%Y_%m_%d_%H%M%S')"
completed_file="$completed_dir/${completed_stamp}_${task_id}.md"

mkdir -p "$completed_dir"
if [ -e "$completed_file" ]; then
  suffix=1
  while [ -e "$completed_dir/${completed_stamp}_${task_id}_${suffix}.md" ]; do
    suffix=$((suffix + 1))
  done
  completed_file="$completed_dir/${completed_stamp}_${task_id}_${suffix}.md"
fi
[ ! -e "$completed_file" ] || fail "Completed plan already exists: $completed_file"

before_terminal_hash="$(plan_hash)"
set_fm_value "$PLAN_PATH" "status" "COMPLETED"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "COMPLETED"
set_fm_value "$PLAN_PATH" "completed_at" "\"$completed_at\""

terminal_hash="$(plan_hash)"
write_journal "FINALIZING" "mark_terminal" "$before_terminal_hash" "$terminal_hash"

HARNESS_INTERNAL_FINALIZATION=1 HARNESS_FINALIZATION_JOURNAL="$journal_file" ./scripts/task.sh mark-done "$task_id" "$task_title"
write_journal "FINALIZING" "task_projection" "" ""

./scripts/consume-plan.sh

if [ "$(fm_value "$PLAN_PATH" "adr_check_required")" = "true" ] && [ -x ./scripts/check-adr-impact.sh ]; then
  ./scripts/check-adr-impact.sh
fi

if [ -x ./scripts/generate-autonomous-run-report.sh ]; then
  ./scripts/generate-autonomous-run-report.sh
fi

run_report="$(evidence_dir)/autonomous-run-report.md"
[ -f "$run_report" ] || fail "Missing autonomous run report: $run_report"
if [ -x ./scripts/check-final-report.sh ]; then
  ./scripts/check-final-report.sh "$run_report" "$PLAN_PATH"
fi

maybe_close_related_epic_story

if [ -x ./scripts/update-epic-progress.sh ]; then
  epic_root="${EPIC_ROOT:-docs/epics}"
  task_store="${TASK_STORE:-docs/tasks/tasks.jsonl}"
  EPIC_ROOT="$epic_root" TASK_STORE="$task_store" ./scripts/update-epic-progress.sh
  if [ -x ./scripts/check-rollup-projection.sh ] && [ -n "$(fm_value "$PLAN_PATH" "parent_epic_id")" ] && [ "$(fm_value "$PLAN_PATH" "parent_epic_id")" != "null" ]; then
    epic_dir="$epic_root/$(fm_value "$PLAN_PATH" "parent_epic_id")"
    EPIC_ROOT="$epic_root" ./scripts/check-rollup-projection.sh "$epic_dir/progress.md" "$task_store" "$epic_dir/stories.jsonl"
  fi
fi

mv "$PLAN_PATH" "$completed_file"
mkdir -p "$(dirname "$active_gitkeep")"
touch "$active_gitkeep"

write_journal "FINALIZING" "reports" "" ""
write_journal "FINALIZED" "move_plan" "$terminal_hash" "$terminal_hash"

echo "Task finalized: $completed_file"
