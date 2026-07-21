#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

plan="$tmp/implementation-plan.md"
cat > "$plan" <<'PLAN'
# v3 Benchmark System Enhancement

This is the authoritative v3 source plan.

We need to improve the harness benchmark system.

1. Fix deterministic test runner with timeout.
2. Add harness.sh benchmark.
3. Add project-build benchmark suite.
4. Add benchmark result schema.
5. Add install fixture benchmark.
6. Add agent-task evaluator.
7. Add context/control evaluator.
8. Add repair-loop metrics.
9. Add benchmark history comparison.

Verification should include unit test, integration test, benchmark run, and package integrity checks.
The work touches scripts/benchmark.sh, scripts/harness.sh, tests/harness/run_all.sh, benchmarks/result-schema.json, and docs/reports/benchmark/latest.md.
PLAN

classification="$tmp/classification.json"
./scripts/classify-plan-size.sh "$plan" > "$classification"
python3 - "$classification" <<'PY'
import json
import pathlib
import sys
row = json.loads(pathlib.Path(sys.argv[1]).read_text())
if row.get("classification") != "long_plan":
    raise SystemExit(f"expected long_plan, got {row}")
PY

intake_root="$tmp/intake"
epic_root="$tmp/epics"
task_root="$tmp/tasks"
task_store="$tmp/tasks/tasks.jsonl"
report_root="$tmp/reports"
PLAN_INTAKE_ROOT="$intake_root" EPIC_ROOT="$epic_root" TASK_ROOT="$task_root" TASK_STORE="$task_store" REPORT_ROOT="$report_root" \
  ./scripts/decompose-plan.sh "$plan" --epic benchmark_system --title "Benchmark System Enhancement" >/dev/null

TASK_STORE="$task_store" EPIC_ROOT="$epic_root" REPORT="$tmp/approval.md" ./scripts/approve-decomposition.sh >/dev/null

task_count="$(python3 - "$task_store" <<'PY'
import pathlib, sys
print(sum(1 for line in pathlib.Path(sys.argv[1]).read_text().splitlines() if line.strip()))
PY
)"
[ "$task_count" -ge 9 ] || { echo "expected at least 9 tasks, got $task_count" >&2; exit 1; }

first_task="$(python3 - "$task_store" <<'PY'
import json, pathlib, sys
rows=[json.loads(line) for line in pathlib.Path(sys.argv[1]).read_text().splitlines() if line.strip()]
print(rows[0]["id"])
PY
)"
active_dir="$tmp/active"
mkdir -p "$active_dir"
HARNESS_SKIP_BASELINE_DETECT=1 PLAN_PATH="$active_dir/current.md" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh activate "$first_task" >/dev/null

[ -f "$active_dir/current.md" ] || { echo "missing active current.md" >&2; exit 1; }
if grep -q 'Epic / Story / Task Breakdown' "$active_dir/current.md"; then
  echo "current.md must not contain the long decomposition tree" >&2
  exit 1
fi
if grep -q '^### Epic' "$active_dir/current.md"; then
  echo "current.md must not contain epic sections" >&2
  exit 1
fi

PLAN_PATH="$active_dir/current.md" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/approve-active-task.sh >/dev/null
python3 - "$task_store" "$first_task" <<'PY'
import json, pathlib, sys
rows=[json.loads(line) for line in pathlib.Path(sys.argv[1]).read_text().splitlines() if line.strip()]
row=next(item for item in rows if item["id"] == sys.argv[2])
if row.get("status") != "IN_PROGRESS":
    raise SystemExit(f"task should be IN_PROGRESS, got {row}")
PY

echo "Long plan workflow regression passed."
