#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/state.json" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-gate","task_id":"task-gate","state":"HUMAN_FINAL_REVIEW","active_function":"final_review","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
JSON

if "$root/scripts/transition-state" --state "$tmp/state.json" --to IMPLEMENTING --check >/dev/null 2>&1; then
  echo "low-level transition bypassed missing readiness" >&2
  exit 1
fi
if "$root/scripts/harness.sh" transition-state --state "$tmp/state.json" --to IMPLEMENTING --check >/dev/null 2>&1; then
  echo "public transition bypassed missing readiness" >&2
  exit 1
fi

cat > "$tmp/not-ready.json" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"artifact":"v3-implementation-readiness","readiness_id":"r-gate","task_id":"task-gate","run_id":"run-gate","version":1,"status":"ANALYZING","input_manifest_hash":"0000000000000000000000000000000000000000000000000000000000000000","created_at":"2026-07-16T00:00:00Z","updated_at":"2026-07-16T00:00:00Z","sources":[{"id":"src-1","classification":"used"}],"input_units":[{"id":"unit-1","source_id":"src-1","classification":"used"}],"requirements":[{"id":"REQ-1","source_unit_ids":["unit-1"],"acceptance_ids":["AC-1"],"evidence":"source","positive_test":"positive","negative_test":"negative","interpretation_evidence":[{"source_unit_id":"unit-1","locator":"line 1","excerpt":"source","interpretation":"meaning","confidence":"high","uncertainty":"none"}]}],"traceability":{"source_to_requirements":{},"requirement_to_plan":{"REQ-1":["PLAN-1"]},"plan_to_code":{"PLAN-1":["code"]},"code_to_tests":{"code":["test"]}},"blocking_issues":["incomplete"],"understanding_review":{}}
JSON
python3 - "$tmp/state.json" "$tmp/not-ready.json" <<'PY'
import json, pathlib, sys
state = json.loads(pathlib.Path(sys.argv[1]).read_text())
state["readiness_path"] = sys.argv[2]
pathlib.Path(sys.argv[1]).write_text(json.dumps(state) + "\n")
PY
if "$root/scripts/transition-state" --state "$tmp/state.json" --to IMPLEMENTING --check >/dev/null 2>&1; then
  echo "low-level transition accepted not-ready evidence" >&2
  exit 1
fi

echo "Implementation readiness gate parity regression passed."
