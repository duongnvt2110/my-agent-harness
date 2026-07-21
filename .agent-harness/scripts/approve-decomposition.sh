#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

TASK_STORE="${TASK_STORE:-docs/tasks/tasks.jsonl}"
EPIC_ROOT="${EPIC_ROOT:-docs/epics}"
REPORT="${REPORT:-docs/reports/plan-decomposition-approval.md}"

[ -f "$TASK_STORE" ] || fail "Missing task store: $TASK_STORE"

python3 - "$TASK_STORE" "$EPIC_ROOT" "$REPORT" <<'PY'
from __future__ import annotations

import json
import pathlib
import sys
from collections import defaultdict

store = pathlib.Path(sys.argv[1])
epic_root = pathlib.Path(sys.argv[2])
report = pathlib.Path(sys.argv[3])
records = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
if not records:
    raise SystemExit("Task store is empty; run scripts/decompose-plan.sh first")

errors: list[str] = []
ids = [row.get("id", "") for row in records]
if len(ids) != len(set(ids)):
    errors.append("duplicate task ids found")

by_id = {row.get("id"): row for row in records}
for row in records:
    tid = row.get("id", "")
    if not tid:
        errors.append("task missing id")
        continue
    if row.get("status") not in {"BACKLOG", "READY", "ACTIVE", "IN_PROGRESS", "VERIFYING", "DONE", "FAILED", "BLOCKED"}:
        errors.append(f"{tid}: invalid status {row.get('status')}")
    for field in ["title", "epic_id", "story_id", "implementation_plan_path"]:
        if not row.get(field):
            errors.append(f"{tid}: missing {field}")
    if not row.get("acceptance_criteria"):
        errors.append(f"{tid}: missing acceptance_criteria")
    if not row.get("approved_scopes") and not row.get("approved_files"):
        errors.append(f"{tid}: missing approved_scopes/approved_files")
    if not row.get("required_checks"):
        errors.append(f"{tid}: missing required_checks")
    for dep in row.get("depends_on", []):
        if dep not in by_id:
            errors.append(f"{tid}: unknown dependency {dep}")
    impl_path = pathlib.Path(row.get("implementation_plan_path", ""))
    if row.get("implementation_plan_path") and not impl_path.exists():
        errors.append(f"{tid}: missing implementation plan {impl_path}")
    epic_id = row.get("epic_id")
    story_id = row.get("story_id")
    if epic_id:
        story_file = epic_root / epic_id / "stories.jsonl"
        if not story_file.exists():
            errors.append(f"{tid}: missing story registry {story_file}")
        else:
            story_rows = [json.loads(line) for line in story_file.read_text().splitlines() if line.strip()]
            story = next((item for item in story_rows if item.get("id") == story_id), None)
            if story is None:
                errors.append(f"{tid}: story not found {story_id}")
            elif not story.get("acceptance"):
                errors.append(f"{tid}: story missing acceptance {story_id}")

# Dependency cycle check.
visiting: set[str] = set()
visited: set[str] = set()

def visit(tid: str, stack: list[str]) -> None:
    if tid in visited:
        return
    if tid in visiting:
        errors.append("dependency cycle: " + " -> ".join(stack + [tid]))
        return
    visiting.add(tid)
    for dep in by_id.get(tid, {}).get("depends_on", []):
        visit(dep, stack + [tid])
    visiting.remove(tid)
    visited.add(tid)

for tid in list(by_id):
    visit(tid, [])

report.parent.mkdir(parents=True, exist_ok=True)
status = "APPROVED" if not errors else "FAILED"
by_epic: dict[str, int] = defaultdict(int)
for row in records:
    by_epic[row.get("epic_id", "none")] += 1
report.write_text("# Plan Decomposition Approval\n\n" +
                  f"status: {status}\n" +
                  f"tasks: {len(records)}\n" +
                  "\n## Tasks by Epic\n\n" +
                  "\n".join(f"- {epic}: {count}" for epic, count in sorted(by_epic.items())) +
                  "\n\n## Errors\n\n" +
                  ("\n".join(f"- {err}" for err in errors) if errors else "- None") + "\n")
if errors:
    raise SystemExit("Decomposition approval failed:\n" + "\n".join(f"- {err}" for err in errors))
PY

echo "Approved decomposition: $TASK_STORE"
echo "Report: $REPORT"
