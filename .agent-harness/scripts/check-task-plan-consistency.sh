#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

python3 - "$HARNESS_DOCS_DIR/tasks/tasks.jsonl" "$HARNESS_DOCS_DIR/tasks" <<'PY'
from __future__ import annotations
import json
import pathlib
import re
import sys

store = pathlib.Path(sys.argv[1])
tasks_root = pathlib.Path(sys.argv[2])
exceptions_path = tasks_root.parent.parent / "policies" / "task-plan-exceptions.json"
terminal = {"DONE": "COMPLETED", "CANCELLED": "CANCELLED"}
records = {}
errors = []
for line_no, line in enumerate(store.read_text(encoding="utf-8").splitlines(), 1):
    if not line.strip():
        continue
    try:
        row = json.loads(line)
    except json.JSONDecodeError as exc:
        errors.append(f"tasks.jsonl:{line_no}: invalid JSON: {exc.msg}")
        continue
    task_id = row.get("id")
    if not isinstance(task_id, str) or not task_id:
        errors.append(f"tasks.jsonl:{line_no}: missing task id")
        continue
    if task_id in records:
        errors.append(f"tasks.jsonl:{line_no}: duplicate task id: {task_id}")
    records[task_id] = row

seen = set()
exceptions = {}
if exceptions_path.is_file():
    try:
        raw_exceptions = json.loads(exceptions_path.read_text(encoding="utf-8"))
        for entry in raw_exceptions.get("entries", []):
            task_id = entry.get("task_id")
            snapshot_path = entry.get("snapshot_path")
            digest = entry.get("snapshot_sha256")
            reason = entry.get("reason")
            plan = tasks_root / task_id / "implementation-plan.md"
            snapshot = tasks_root.parent.parent / snapshot_path if isinstance(snapshot_path, str) else None
            if not task_id or not digest or not reason or not snapshot or not snapshot.is_file():
                errors.append(f"invalid task-plan exception: {entry}")
            elif __import__("hashlib").sha256(snapshot.read_bytes()).hexdigest() != digest:
                errors.append(f"task-plan exception snapshot hash mismatch: {task_id}")
            else:
                exceptions[task_id] = entry
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"invalid task-plan exceptions: {exc}")

for plan in sorted(tasks_root.glob("*/implementation-plan.md")):
    seen.add(plan.parent.name)
    text = plan.read_text(encoding="utf-8")
    match = re.search(r"^---\n(.*?)\n---\n", text, re.M | re.S)
    if not match:
        errors.append(f"{plan}: missing front matter")
        continue
    front = match.group(1)
    task_match = re.search(r"^task_id:\s*['\"]?([^'\"\s]+)", front, re.M)
    status_match = re.search(r"^status:\s*['\"]?([^'\"\s]+)", front, re.M)
    phase_match = re.search(r"^lifecycle_phase:\s*['\"]?([^'\"\s]+)", front, re.M)
    task_id = task_match.group(1) if task_match else plan.parent.name
    plan_status = status_match.group(1) if status_match else ""
    phase = phase_match.group(1) if phase_match else ""
    row = records.get(task_id)
    if row is None:
        if task_id in exceptions:
            continue
        errors.append(f"{plan}: no authoritative ledger record for {task_id}")
        continue
    ledger_status = row.get("status", "")
    if ledger_status in terminal:
        expected = terminal[ledger_status]
        if plan_status != expected or phase != expected:
            errors.append(
                f"{plan}: ledger {ledger_status} requires plan status/lifecycle_phase {expected}, "
                f"got {plan_status}/{phase}"
            )

for task_id, row in sorted(records.items()):
    plan = tasks_root / task_id / "implementation-plan.md"
    if not plan.is_file():
        errors.append(f"ledger task {task_id}: missing implementation plan: {plan}")

if errors:
    for error in errors:
        print(f"error: {error}")
    raise SystemExit(1)

print(f"task_plan_consistency: valid ({len(records)} ledger tasks, {len(seen)} plans)")
PY
