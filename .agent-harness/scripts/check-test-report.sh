#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

report="${1:-$(evidence_dir)/test-report.md}"
plan="${2:-$PLAN_PATH}"
[ -f "$report" ] || fail "Missing test report: $report"
[ -f "$plan" ] || fail "Missing active plan: $plan"

python3 - "$report" "$plan" <<'PY'
from __future__ import annotations
import pathlib
import re
import sys

report = pathlib.Path(sys.argv[1])
plan = pathlib.Path(sys.argv[2])
text = report.read_text()
expected_task = next((line.split(":", 1)[1].strip() for line in plan.read_text().splitlines() if line.startswith("task_id:")), "")
def field(name: str) -> str:
    match = re.search(rf"^{re.escape(name)}:\s*(.+)$", text, re.MULTILINE)
    return match.group(1).strip() if match else ""

if field("report_schema_version") != "1" or field("canonicalization_version") != "1":
    raise SystemExit("unsupported test report schema")
if field("task_id") != expected_task:
    raise SystemExit("test report task binding mismatch")
if field("result") != "pass":
    raise SystemExit("test report is not passing")
try:
    required_count = int(field("required_checks_count"))
    blocking_passed = int(field("blocking_checks_passed"))
except ValueError:
    raise SystemExit("test report counts are invalid")
rows = re.findall(r"^- id: (.+?)\n  type: .*?\n  blocking: (true|false)\n  timeout_seconds: .*?\n  result: (.+?)\n  evidence: (.+?)$", text, re.MULTILINE)
if len(rows) != required_count:
    raise SystemExit(f"test report row count mismatch: expected {required_count}, found {len(rows)}")
blocking_rows = 0
for check_id, blocking, result, evidence in rows:
    if blocking != "true":
        continue
    blocking_rows += 1
    if result != "pass":
        raise SystemExit(f"blocking report row did not pass: {check_id}")
    evidence_path = pathlib.Path(evidence)
    if not evidence_path.exists():
        raise SystemExit(f"reported evidence is missing: {evidence}")
if blocking_rows != blocking_passed:
    raise SystemExit("blocking pass count mismatch")
print("Test report checks passed.")
PY
