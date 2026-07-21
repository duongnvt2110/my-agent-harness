#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

[ "$#" -eq 1 ] || fail "Usage: scripts/check-task-schema.sh TASK_JSON"
task_path="${1:-}"
[ -n "$task_path" ] || fail "Usage: scripts/check-task-schema.sh TASK_JSON"
mode="v3"

python3 - "$task_path" "$mode" "$HARNESS_ROOT/policies/task-schema-v1.json" <<'PY'
from __future__ import annotations
import hashlib
import json
import pathlib
import re
import sys

task_path = pathlib.Path(sys.argv[1])
mode = sys.argv[2]
schema_path = pathlib.Path(sys.argv[3])
if not task_path.exists():
    raise SystemExit("task artifact is missing")
schema = json.loads(schema_path.read_text())
if schema.get("schema_version") != 1 or schema.get("canonicalization_version") != 1:
    raise SystemExit("unsupported task schema contract")

raw = task_path.read_text()
rows = [json.loads(line) for line in raw.splitlines() if line.strip()] if task_path.suffix == ".jsonl" else [json.loads(raw)]
required = schema["workflow_versions"][mode]["required"]
for index, row in enumerate(rows, start=1):
    missing = [key for key in required if key not in row]
    if missing:
        raise SystemExit(f"task {index} missing required fields: {', '.join(missing)}")
    if not isinstance(row["depends_on"], list):
        raise SystemExit(f"task {index} depends_on must be an array")
    if row["schema_version"] != 1 or row["canonicalization_version"] != 1:
        raise SystemExit(f"task {index} has unsupported schema or canonicalization version")
    if not re.fullmatch(r"[0-9a-f]{64}", str(row["source_spec_hash"])):
        raise SystemExit(f"task {index} source_spec_hash must be a SHA-256 hex digest")
    for key in ("approved_scopes", "approved_files", "approved_deletions", "verification_checks", "acceptance_criteria"):
        if not isinstance(row[key], list):
            raise SystemExit(f"task {index} {key} must be an array")
    for criterion in row["acceptance_criteria"]:
        if not isinstance(criterion, dict):
            raise SystemExit(f"task {index} acceptance criteria must be structured objects")
        required_ac = ("id", "given", "when", "then", "evidence_class", "producer", "evaluator", "aggregation_rule", "freshness", "pass_conditions")
        missing_ac = [key for key in required_ac if key not in criterion]
        if missing_ac:
            raise SystemExit(f"task {index} acceptance criterion missing: {', '.join(missing_ac)}")
    for check in row["verification_checks"]:
        if not isinstance(check, dict) or not check.get("id") or not check.get("command") or not isinstance(check.get("covers"), list):
            raise SystemExit(f"task {index} verification_checks must bind id, command, and covers")
print(f"task_schema: v1\nworkflow_version: {mode}\nrecords: {len(rows)}\nvalid: true")
PY
