#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

report="${1:-$(evidence_dir)/autonomous-run-report.md}"
plan="${2:-$PLAN_PATH}"
[ -f "$report" ] || fail "Missing autonomous run report: $report"
[ -f "$plan" ] || fail "Missing active plan: $plan"

python3 - "$report" "$plan" <<'PY'
import pathlib
import re
import sys

report = pathlib.Path(sys.argv[1]).read_text()
plan = pathlib.Path(sys.argv[2]).read_text()
def value(text, key):
    match = re.search(rf"^(?:-\s+)?{re.escape(key)}:\s*(.+)$", text, re.MULTILINE)
    return match.group(1).strip() if match else ""

if value(report, "task_id") != value(plan, "task_id"):
    raise SystemExit("final report task binding mismatch")
if value(report, "result") != "pass":
    raise SystemExit("final report is not passing")
if value(report, "status") != "COMPLETED" or value(report, "lifecycle_phase") != "COMPLETED":
    raise SystemExit("final report does not describe terminal completion")
for heading in ("## Required Checks", "## Verification", "## Review", "## Unresolved Items"):
    if heading not in report:
        raise SystemExit(f"final report missing section: {heading}")
required = report.split("## Required Checks", 1)[1].split("## ", 1)[0]
if re.search(r"- [^:]+: missing \(", required):
    raise SystemExit("final report contains missing required-check evidence")
if "- Verification pass:" not in report or "- Test report:" not in report:
    raise SystemExit("final report missing verification evidence references")
print("Final report checks passed.")
PY
