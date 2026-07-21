#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

active_dir="$(dirname "$PLAN_PATH")"
template_path="docs/exec-plans/TEMPLATE.md"
task_id="${1:-}"
title="${2:-Draft task}"
TASK_STORE="${TASK_STORE:-docs/tasks/tasks.jsonl}"

[ -n "$task_id" ] || fail "Usage: $0 <task_id> [title]"
[[ "$task_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "task_id must be lowercase snake_case: $task_id"
[ -f "$template_path" ] || fail "Missing plan template: $template_path"

if [ -f "$PLAN_PATH" ]; then
  fail "Active plan already exists at $PLAN_PATH. Continue, verify, or finalize that task before creating another active plan."
fi

plan_count="$(find "$active_dir" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d " ")"
[ "$plan_count" = "0" ] || fail "Active plan directory already contains $plan_count markdown plan(s). Resolve the existing active plan before creating another."

mkdir -p "$active_dir"

rendered_from_task_store="false"
if [ -f "$TASK_STORE" ]; then
  if python3 - "$TASK_STORE" "$task_id" >/dev/null <<'PY'
import json, pathlib, sys
store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
for line in store.read_text().splitlines():
    if not line.strip():
        continue
    row = json.loads(line)
    if row.get("id") == task_id and row.get("implementation_plan_path"):
        raise SystemExit(0)
raise SystemExit(1)
PY
  then
    python3 - "$TASK_STORE" "$task_id" "$title" > "$PLAN_PATH" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
fallback_title = sys.argv[3]
records = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    raise SystemExit(f"Unknown task id: {task_id}")

def scalar(value):
    if value is None or value == "":
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace('"', '\\"')
    if text in {"true", "false", "null"} or any(ch in text for ch in [":", "#", "[", "]", "{", "}"]):
        return f'"{text}"'
    return text

def list_yaml(items):
    items = items or []
    if not items:
        return "[]"
    return "\n" + "\n".join(f"  - {scalar(item)}" for item in items)

def checks_yaml(checks):
    normalized = []
    for idx, check in enumerate(checks or [], start=1):
        if isinstance(check, str):
            normalized.append({
                "id": f"check-{idx:03d}",
                "type": "automated",
                "command": check,
                "blocking": True,
                "timeout_seconds": 180,
                "covers": ["AC-001"],
                "evidence": f"docs/evidence/{task_id}/check-{idx:03d}.md",
            })
        else:
            normalized.append(check)
    if not normalized:
        normalized.append({
            "id": "task-check",
            "type": "automated",
            "command": "rtk ./scripts/harness.sh next",
            "blocking": True,
            "timeout_seconds": 180,
            "covers": ["AC-001"],
            "evidence": f"docs/evidence/{task_id}/task-check.md",
        })
    lines = []
    for check in normalized:
        lines.append(f"  - id: {scalar(check.get('id', 'task-check'))}")
        lines.append(f"    type: {scalar(check.get('type', 'automated'))}")
        lines.append(f"    command: {scalar(check.get('command', 'rtk ./scripts/harness.sh next'))}")
        lines.append(f"    blocking: {scalar(bool(check.get('blocking', True)))}")
        lines.append(f"    timeout_seconds: {scalar(int(check.get('timeout_seconds', 180)))}")
        covers = check.get("covers") or ["AC-001"]
        lines.append("    covers:")
        for cover in covers:
            lines.append(f"      - {scalar(cover)}")
        lines.append(f"    evidence: {scalar(check.get('evidence', f'docs/evidence/{task_id}/task-check.md'))}")
    return "\n".join(lines)

title = record.get("title") or fallback_title or task_id
parent_epic_id = record.get("epic_id") or None
parent_story_id = record.get("story_id") or None
lane = record.get("lane", "normal")
approved_scopes = record.get("approved_scopes") or ["harness_core", "harness_docs", "app_tests"]
approved_files = record.get("approved_files") or []
approved_deletions = record.get("approved_deletions") or []
acceptance = record.get("acceptance_criteria") or [f"Complete {title}"]
required_checks = record.get("required_checks") or []
epic_path = f"docs/epics/{parent_epic_id}/epic.md" if parent_epic_id else None
story_registry = f"docs/epics/{parent_epic_id}/stories.jsonl" if parent_epic_id else None
epic_memory = f"docs/epics/{parent_epic_id}/epic-memory.md" if parent_epic_id else None
epic_progress = f"docs/epics/{parent_epic_id}/progress.md" if parent_epic_id else None
integration_contract = f"docs/epics/{parent_epic_id}/integration-contract.md" if parent_epic_id else None
epic_clarifications = f"docs/epics/{parent_epic_id}/clarifications.md" if parent_epic_id else None
now = dt.datetime.now().strftime("%Y-%m-%d %H:%M")

print("---")
frontmatter = {
    "task_id": task_id,
    "title": f'"{title.replace(chr(34), "")}"',
    "status": "DRAFT",
    "lifecycle_phase": "PLAN",
    "lane": lane,
    "change_type": "harness_improvement",
    "implementation_target": "scratch_harness",
    "workflow_version": 3,
    "implementation_allowed": False,
    "clarification_status": "CLEAR",
    "blocking_questions": [],
    "approved_by": None,
    "approved_at": None,
    "baseline_ref": None,
    "file_map_approved": False,
    "review_required": lane in {"normal", "high_risk"},
    "evidence_required": True,
    "requires_rollback_plan": lane == "high_risk",
    "requires_human_approval": lane == "high_risk",
    "repo_mode": "brownfield",
    "task_change_type": "extend_existing",
    "task_touches_existing_behavior": True,
    "task_backward_compatibility_required": True,
}
for key, value in frontmatter.items():
    if isinstance(value, list):
        print(f"{key}: []")
    elif isinstance(value, str) and value.startswith('"') and value.endswith('"'):
        print(f"{key}: {value}")
    else:
        print(f"{key}: {scalar(value)}")
print(f"approved_scopes: {list_yaml(approved_scopes)}")
print(f"approved_files: {list_yaml(approved_files)}")
print(f"approved_deletions: {list_yaml(approved_deletions)}")
more = {
    "environment_mode": "local",
    "environment_setup_required": False,
    "environment_run_prefix": "",
    "environment_compose_file": None,
    "environment_service": None,
    "environment_reason": None,
    "verification_mode": "required_checks",
    "testing_required": True,
    "testing_skip_reason": "",
    "parent_epic_id": parent_epic_id,
    "parent_story_id": parent_story_id,
    "epic_path": epic_path,
    "story_registry": story_registry,
    "epic_memory": epic_memory,
    "epic_progress": epic_progress,
    "integration_contract": integration_contract,
    "epic_clarifications": epic_clarifications,
    "epic_context_required": bool(parent_epic_id),
    "spec_clarification_required": False,
    "spec_clarification_evidence": f"docs/evidence/{task_id}/spec-clarification.md",
    "work_alignment_required": False,
    "work_alignment_evidence": f"docs/evidence/{task_id}/work-alignment.md",
    "adr_check_required": True,
    "adr_index": "docs/decisions/adr-index.json",
    "adr_review_evidence": f"docs/evidence/{task_id}/adr-review.md",
    "context_pack_required": True,
    "context_pack_path": f"docs/evidence/{task_id}/context-pack.md",
    "working_memory_path": f"docs/evidence/{task_id}/working-memory.md",
    "max_context_tokens": 5000,
    "max_memory_items": 12,
    "include_full_adr_text": False,
    "include_full_epic_text": False,
    "source_plan_path": record.get("source_plan_path"),
    "implementation_plan_path": record.get("implementation_plan_path"),
}
for key, value in more.items():
    print(f"{key}: {scalar(value)}")
print(f"acceptance_criteria: {list_yaml(acceptance)}")
policy = {
    "decision_policy_allow_safe_revert": True,
    "decision_policy_allow_test_fix": True,
    "decision_policy_allow_source_fix": True,
    "decision_policy_allow_scope_expansion": False,
    "decision_policy_allow_dependency_change": False,
    "decision_policy_allow_environment_change": False,
    "decision_policy_allow_test_skip": False,
    "decision_policy_allow_timeout_increase": False,
}
for key, value in policy.items():
    print(f"{key}: {scalar(value)}")
print("required_checks:")
print(checks_yaml(required_checks))
print("---")
print()
print(f"# Active Task: {title}")
print()
print("## Goal")
print()
print(title)
print()
print("## Parent References")
print()
print(f"- epic_id: `{parent_epic_id or 'none'}`")
print(f"- story_id: `{parent_story_id or 'none'}`")
print(f"- source_plan_path: `{record.get('source_plan_path') or 'none'}`")
print(f"- implementation_plan_path: `{record.get('implementation_plan_path') or 'none'}`")
print()
print("## Scope")
print()
print("### Approved Scopes")
print()
for item in approved_scopes:
    print(f"- {item}")
print()
print("### Approved Files")
print()
if approved_files:
    for item in approved_files:
        print(f"- {item}")
else:
    print("- None")
print()
print("## Acceptance Criteria")
print()
for item in acceptance:
    print(f"- {item}")
print()
print("## Required Checks")
print()
for idx, check in enumerate(required_checks or [], start=1):
    command = check if isinstance(check, str) else check.get("command")
    print(f"- `{command}`")
if not required_checks:
    print("- `rtk ./scripts/harness.sh next`")
print()
print("## Out of Scope")
print()
print("- Do not place the full epic/story/task tree in this active plan.")
print("- Do not modify files outside approved scopes/files.")
print()
print("## Verification")
print()
print("Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.")
PY
    rendered_from_task_store="true"
  fi
fi

if [ "$rendered_from_task_store" != "true" ]; then
  cp "$template_path" "$PLAN_PATH"
  safe_title="${title//\"/}"
  current_date="$(date '+%Y-%m-%d %H:%M')"
  perl -0pi -e "s/__TASK_ID__/$task_id/g; s/__TITLE__/$safe_title/g; s/YYYY-MM-DD HH:MM/$current_date/g" "$PLAN_PATH"
  set_fm_value "$PLAN_PATH" "task_id" "$task_id"
  set_fm_value "$PLAN_PATH" "title" "\"$safe_title\""
fi

# All newly created task contracts are v3-only, including legacy template paths.
set_fm_value "$PLAN_PATH" "workflow_version" "3"

if [ "${HARNESS_SKIP_BASELINE_DETECT:-}" != "1" ]; then
  ./scripts/detect-change-baseline.sh \
    --task "$task_id" \
    --root "$HARNESS_REPO_ROOT" >/dev/null
  ./scripts/detect-behavior-baseline.sh --task "$task_id" >/dev/null

  baseline_decision="$(evidence_dir)/baseline-decision.md"
  change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$baseline_decision")"
  case "$change_tracking" in
    git)
      baseline_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$baseline_decision")"
      [ -n "$baseline_ref" ] && [ "$baseline_ref" != "null" ] || fail "Git baseline decision missing git_ref"
      set_fm_value "$PLAN_PATH" "baseline_ref" "$baseline_ref"
      ;;
    snapshot)
      set_fm_value "$PLAN_PATH" "baseline_ref" "null"
      ;;
    *)
      fail "Invalid change_tracking in baseline decision: $change_tracking"
      ;;
  esac
else
  set_fm_value "$PLAN_PATH" "baseline_ref" "task-registry-baseline"
fi

echo "Created active plan: $PLAN_PATH"
if [ "$rendered_from_task_store" = "true" ]; then
  echo "Next: approve this single-task contract with rtk .agent-harness/scripts/approve-active-task.sh"
else
  echo "Next: edit this plan in place until it is approved for implementation."
fi
