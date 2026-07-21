#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage: scripts/recover-finalization.sh --journal PATH --plan PATH \
  --task-store PATH --recovery-dir PATH --successor-task ID --successor-title TITLE
EOF
}

journal=""
plan=""
task_store=""
recovery_dir=""
successor_task=""
successor_title=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --journal) journal="${2:-}"; shift 2 ;;
    --plan) plan="${2:-}"; shift 2 ;;
    --task-store) task_store="${2:-}"; shift 2 ;;
    --recovery-dir) recovery_dir="${2:-}"; shift 2 ;;
    --successor-task) successor_task="${2:-}"; shift 2 ;;
    --successor-title) successor_title="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

[ -n "$journal" ] && [ -n "$plan" ] && [ -n "$task_store" ] && [ -n "$recovery_dir" ] && [ -n "$successor_task" ] && [ -n "$successor_title" ] || { usage >&2; exit 2; }
[[ "$successor_task" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "invalid successor task id"

python3 - "$journal" "$plan" "$task_store" "$recovery_dir" "$successor_task" "$successor_title" <<'PY'
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import pathlib
import sys
import tempfile

journal_path, plan_path, task_store_path, recovery_dir = map(pathlib.Path, sys.argv[1:5])
successor_id, successor_title = sys.argv[5:7]

def write_json(path: pathlib.Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=path.name + ".", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)

def sha_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()

if not journal_path.exists() or not plan_path.exists() or not task_store_path.exists():
    raise SystemExit("recovery requires existing journal, active plan, and task store")
journal = json.loads(journal_path.read_text())
if journal.get("journal_schema_version") != 1 or journal.get("status") != "FINALIZED":
    raise SystemExit("recovery requires an immutable FINALIZED journal")
plan_bytes = plan_path.read_bytes()
plan_text = plan_bytes.decode()
plan_task = next((line.split(":", 1)[1].strip() for line in plan_text.splitlines() if line.startswith("task_id:")), "")
if plan_task != journal.get("task_id"):
    raise SystemExit("journal and active plan task identity mismatch")
expected = ""
for step in journal.get("steps", []):
    if step.get("name") == "move_plan":
        expected = step.get("expected_after_hash", "")
        break
if not expected:
    for step in journal.get("steps", []):
        if step.get("name") == "mark_terminal":
            expected = step.get("expected_after_hash", "")
            break
observed = sha_bytes(plan_bytes)
if observed == expected:
    raise SystemExit("active plan matches finalized journal; recovery is not required")

records = [json.loads(line) for line in task_store_path.read_text().splitlines() if line.strip()]
old = next((row for row in records if row.get("id") == plan_task), None)
if old is None:
    raise SystemExit("finalized task is missing from task projection")
if any(row.get("id") == successor_id for row in records):
    raise SystemExit("successor task id already exists")

recovery_journal_path = journal_path.with_name("recovery-journal.json")
if recovery_journal_path.exists():
    prior = json.loads(recovery_journal_path.read_text())
    if prior.get("status") == "RECOVERED" and prior.get("successor_task_id") == successor_id:
        print(json.dumps(prior, sort_keys=True))
        raise SystemExit(0)
    raise SystemExit("conflicting recovery journal already exists")

stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
recovery_dir.mkdir(parents=True, exist_ok=True)
archive = recovery_dir / f"{stamp}_{plan_task}.md"
recovery = {
    "schema_version": 1,
    "status": "PREPARED",
    "source_task_id": plan_task,
    "successor_task_id": successor_id,
    "source_journal_hash": sha_bytes(journal_path.read_bytes()),
    "expected_plan_hash": expected,
    "observed_plan_hash": observed,
    "archive_path": str(archive),
    "created_at": dt.datetime.now(dt.timezone.utc).isoformat(),
}
write_json(recovery_journal_path, recovery)

os.replace(plan_path, archive)
archive_hash = sha_bytes(archive.read_bytes())
before_hash = sha_bytes(task_store_path.read_bytes())
successor = dict(old)
successor.update({
    "id": successor_id,
    "title": successor_title,
    "status": "READY",
    "supersedes_task_id": plan_task,
    "supersedes_run_id": None,
    "recovery_source_journal_hash": recovery["source_journal_hash"],
    "recovery_source_plan_hash": observed,
    "recovery_status": "SUCCESSOR_REQUIRED_NEW_RUN",
})
old["status"] = "DONE"
new_records = [old if row.get("id") == plan_task else row for row in records]
new_records.append(successor)
fd, tmp = tempfile.mkstemp(prefix=task_store_path.name + ".", dir=task_store_path.parent)
try:
    with os.fdopen(fd, "w") as handle:
        for row in new_records:
            handle.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(tmp, task_store_path)
finally:
    if os.path.exists(tmp):
        os.unlink(tmp)

recovery.update({
    "status": "RECOVERED",
    "archive_hash": archive_hash,
    "task_store_before_hash": before_hash,
    "task_store_after_hash": sha_bytes(task_store_path.read_bytes()),
    "completed_at": dt.datetime.now(dt.timezone.utc).isoformat(),
})
write_json(recovery_journal_path, recovery)
print(json.dumps(recovery, sort_keys=True))
PY
