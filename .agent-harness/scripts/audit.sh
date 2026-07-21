#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

json_mode=false
if [ "${1:-}" = "--json" ]; then json_mode=true; shift; fi
[ "$#" -eq 0 ] || fail "Usage: scripts/audit.sh [--json]"

python3 - "$HARNESS_ROOT" "${TASK_STORE:-docs/tasks/tasks.jsonl}" "$PLAN_PATH" "$json_mode" <<'PY'
from __future__ import annotations
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]).resolve()
task_store = pathlib.Path(sys.argv[2])
if not task_store.is_absolute(): task_store = root / task_store
plan_path = pathlib.Path(sys.argv[3])
if not plan_path.is_absolute(): plan_path = root / plan_path
json_mode = sys.argv[4] == "true"
result = {"schema_version": 1, "audit": "v4-core", "repository_root": str(root), "checks": [], "errors": [], "warnings": []}

def check(name, passed, detail):
    result["checks"].append({"name": name, "passed": passed, "detail": detail})
    if not passed: result["errors"].append({"check": name, "detail": detail})

rows = []
if not task_store.is_file():
    check("task_store", False, f"missing task store: {task_store}")
else:
    parse_errors = []
    for line_no, line in enumerate(task_store.read_text().splitlines(), 1):
        if not line.strip(): continue
        try: rows.append(json.loads(line))
        except json.JSONDecodeError as exc: parse_errors.append(f"line {line_no}: {exc.msg}")
    check("task_store_schema", not parse_errors, "; ".join(parse_errors) or f"{len(rows)} task records parsed")

ids = [row.get("id") for row in rows]
duplicates = sorted({item for item in ids if item and ids.count(item) > 1})
check("task_ids", not duplicates, f"duplicate task ids: {duplicates}" if duplicates else "task ids are unique")
allowed = {"READY", "ACTIVE", "IN_PROGRESS", "BLOCKED", "DONE"}
bad_statuses = [f"{row.get('id')}: {row.get('status')}" for row in rows if row.get("status") not in allowed]
check("task_statuses", not bad_statuses, "; ".join(bad_statuses) if bad_statuses else "task statuses are valid")
task_by_id = {row.get("id"): row for row in rows if row.get("id")}
active_rows = [row for row in rows if row.get("status") in {"ACTIVE", "IN_PROGRESS"}]

def fm(path, key):
    if not path.is_file(): return ""
    text = path.read_text()
    if not text.startswith("---"): return ""
    front = text.split("---", 2)[1]
    match = re.search(rf"^{re.escape(key)}:\s*(.+?)\s*$", front, re.M)
    return match.group(1).strip().strip('"') if match else ""

if plan_path.is_file():
    plan_task = fm(plan_path, "task_id")
    matching = task_by_id.get(plan_task)
    check("active_plan_binding", bool(plan_task and matching), f"active plan task {plan_task!r} is bound" if matching else f"active plan task {plan_task!r} has no task record")
    if matching and matching.get("status") == "DONE": check("active_plan_status", False, f"active plan task is already DONE: {plan_task}")
    if len(active_rows) > 1: check("single_active_task", False, f"multiple active task records: {[row.get('id') for row in active_rows]}")
else:
    check("no_active_plan_state", not active_rows, f"active task records without current.md: {[row.get('id') for row in active_rows]}" if active_rows else "no active task without a plan")

missing_sources = []
for row in rows:
    source = row.get("source_plan_path")
    if not source: continue
    path = pathlib.Path(source)
    if not path.is_absolute(): path = root / path
    if not path.is_file(): missing_sources.append(f"{row.get('id')}: {source}")
check("intake_references", not missing_sources, "; ".join(missing_sources) if missing_sources else "all task source plans exist")

journal_errors = []
orphans = []
evidence_root = root / "docs" / "evidence"
for journal in sorted(evidence_root.glob("*/finalization-journal.json")) if evidence_root.is_dir() else []:
    try: data = json.loads(journal.read_text())
    except json.JSONDecodeError as exc:
        journal_errors.append(f"{journal}: invalid JSON: {exc.msg}"); continue
    if data.get("status") != "FINALIZED": continue
    incomplete = [step.get("name") for step in data.get("steps", []) if step.get("status") != "DONE"]
    if incomplete: journal_errors.append(f"{journal}: incomplete finalized steps: {incomplete}")
    if data.get("task_id") and data["task_id"] not in task_by_id: orphans.append(f"{data['task_id']}: {journal.relative_to(root)}")
check("finalization_journals", not journal_errors, "; ".join(journal_errors) if journal_errors else "finalization journals are valid")
if orphans: result["warnings"].append({"check": "historical_task_projection", "detail": "finalized journals without canonical task rows: " + "; ".join(orphans)})

result["passed"] = not result["errors"]
if json_mode:
    print(json.dumps(result, indent=2, sort_keys=True))
else:
    print(f"v4-core audit: {'PASS' if result['passed'] else 'FAIL'}")
    for item in result["checks"]: print(f"- {'PASS' if item['passed'] else 'FAIL'} {item['name']}: {item['detail']}")
    for item in result["warnings"]: print(f"- WARN {item['check']}: {item['detail']}")
if not result["passed"]: raise SystemExit(1)
PY
