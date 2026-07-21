#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

spec="${1:-}"
tasks="${2:-}"
checks="${3:-}"
changed="${4:-}"
[ -n "$spec" ] && [ -n "$tasks" ] && [ -n "$checks" ] || fail "Usage: scripts/check-ac-coverage.sh SPEC.json TASKS.json CHECKS.json [CHANGED_AC]"

python3 - "$spec" "$tasks" "$checks" "$changed" <<'PY'
from __future__ import annotations
import json, pathlib, sys

spec = json.loads(pathlib.Path(sys.argv[1]).read_text())
tasks = json.loads(pathlib.Path(sys.argv[2]).read_text())
checks = json.loads(pathlib.Path(sys.argv[3]).read_text())
changed = sys.argv[4]
criteria = {row["id"]: row for row in spec.get("acceptance_criteria", []) if isinstance(row, dict) and row.get("id")}
task_rows = tasks if isinstance(tasks, list) else tasks.get("tasks", [])
check_rows = checks if isinstance(checks, list) else checks.get("checks", [])
errors: list[str] = []
task_by_id = {row.get("id"): row for row in task_rows if row.get("id")}
covered: dict[str, list[str]] = {ac: [] for ac in criteria}
for task in task_rows:
    for ac in task.get("acceptance_criteria", []):
        if ac not in criteria:
            errors.append(f"task {task.get('id')} references unknown AC {ac}")
        else:
            covered[ac].append(task["id"])
for ac, owners in covered.items():
    if not owners:
        errors.append(f"AC {ac} has no task mapping")
checked: dict[str, int] = {ac: 0 for ac in criteria}
for check in check_rows:
    ac_ids = check.get("ac_ids", check.get("covers", []))
    if not ac_ids:
        errors.append(f"check {check.get('id')} covers no AC")
    for ac in ac_ids:
        if ac not in criteria:
            errors.append(f"check {check.get('id')} references unknown AC {ac}")
        if check.get("result") != "PASSED":
            errors.append(f"check {check.get('id')} has unresolved result for {ac}")
        if not check.get("evidence_hash"):
            errors.append(f"check {check.get('id')} lacks evidence hash")
        elif check.get("result") == "PASSED" and ac in checked:
            checked[ac] += 1
for ac, count in checked.items():
    if count == 0 and criteria[ac].get("blocking", True):
        errors.append(f"blocking AC {ac} has no passing evidence")

affected: set[str] = set()
invalidates_all = False
if changed:
    if changed not in criteria or any(not row.get("acceptance_criteria") for row in task_rows):
        invalidates_all = True
    else:
        affected = {tid for tid, row in task_by_id.items() if changed in row.get("acceptance_criteria", [])}
        grew = True
        while grew:
            grew = False
            for tid, row in task_by_id.items():
                if tid not in affected and any(dep in affected for dep in row.get("depends_on", [])):
                    affected.add(tid)
                    grew = True
if errors:
    invalidates_all = True
result = {
    "traceability_version": 1,
    "valid": not errors,
    "errors": errors,
    "invalidates_all": invalidates_all,
    "affected_tasks": sorted(task_by_id) if invalidates_all else sorted(affected),
    "invalidated_artifacts": sorted({artifact for tid in (task_by_id if invalidates_all else affected) for artifact in task_by_id[tid].get("verification_artifacts", [])}),
}
print(json.dumps(result, sort_keys=True))
raise SystemExit(0 if result["valid"] else 1)
PY
