#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
failure_packet="$dir/failure-packet.md"

if [ ! -f "$failure_packet" ]; then
  echo "No failure packet present; remediation trace not required."
  exit 0
fi

required=(
  "$dir/failure-diagnosis.md"
  "$dir/repair-plan.md"
  "$dir/targeted-retest.md"
  "$dir/decision-ledger.jsonl"
  "$dir/decision-trace.md"
  "$dir/test-report.md"
)

for file in "${required[@]}"; do
  [ -f "$file" ] || fail "Missing remediation trace artifact after failure: $file"
done

task_id="$(fm_value "$PLAN_PATH" "task_id")"
python3 - "$task_id" "$failure_packet" "$dir" <<'PY'
import json, pathlib, sys
task_id, failure_packet, directory = sys.argv[1:]
paths = [pathlib.Path(failure_packet), pathlib.Path(directory) / "failure-diagnosis.md",
         pathlib.Path(directory) / "repair-plan.md", pathlib.Path(directory) / "targeted-retest.md",
         pathlib.Path(directory) / "test-report.md", pathlib.Path(directory) / "decision-trace.md"]
for path in paths:
    text = path.read_text()
    if f"task_id: {task_id}" not in text:
        raise SystemExit(f"remediation artifact is not bound to task {task_id}: {path}")
ledger = pathlib.Path(directory) / "decision-ledger.jsonl"
rows = []
for line_number, line in enumerate(ledger.read_text().splitlines(), 1):
    if not line.strip():
        raise SystemExit(f"blank decision ledger line: {line_number}")
    try:
        row = json.loads(line)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"malformed decision ledger line {line_number}: {exc}")
    required_fields = ("task_id", "recorded_at", "phase", "decision_type", "trigger", "action", "result", "requires_human_review", "evidence", "files_affected")
    missing = [field for field in required_fields if field not in row]
    if missing:
        raise SystemExit(f"decision ledger line {line_number} missing: {','.join(missing)}")
    if row["task_id"] != task_id or not row["evidence"] or not isinstance(row["files_affected"], list):
        raise SystemExit(f"decision ledger line {line_number} is not bound to the remediation task")
    if not isinstance(row["requires_human_review"], bool):
        raise SystemExit(f"decision ledger line {line_number} has invalid review flag")
    rows.append(line)
trace = (pathlib.Path(directory) / "decision-trace.md").read_text()
for line in rows:
    if line not in trace:
        raise SystemExit("decision trace does not contain the complete ledger entry")
PY

echo "Remediation trace checks passed."
