#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
source_file="$tmp/request.txt"
printf 'human requirement source\n' > "$source_file"
hash="$(shasum -a 256 "$source_file" | awk '{print $1}')"
cat > "$tmp/ready.json" <<EOF
{
  "schema_version": 1, "canonicalization_version": 1,
  "artifact": "v3-implementation-readiness", "readiness_id": "r-1",
  "task_id": "task-1", "run_id": "run-1", "version": 1,
  "status": "READY", "input_manifest_hash": "$hash",
  "created_at": "2026-07-16T00:00:00Z", "updated_at": "2026-07-16T00:00:00Z",
  "sources": [{"id":"src-1","kind":"file","location":"$source_file","content_hash":"$hash","authority":"normative","classification":"used"}],
  "input_units": [{"id":"src-1:unit-1","source_id":"src-1","classification":"used"}],
  "requirements": [{"id":"REQ-1","authority":"normative","source_unit_ids":["src-1:unit-1"],"evidence":"human requirement source","acceptance_ids":["AC-1"],"positive_test":"valid case","negative_test":"invalid case","interpretation_evidence":[{"source_unit_id":"src-1:unit-1","locator":"line 1","excerpt":"human requirement source","interpretation":"The requirement must be implemented as written.","confidence":"high","uncertainty":"none","authority":"normative","contradictions":[],"assumptions":[]}]}],
  "traceability": {"source_to_requirements":{"src-1:unit-1":["REQ-1"]},"requirement_to_plan":{"REQ-1":["PLAN-1"]},"plan_to_code":{"PLAN-1":["src/control.py"]},"code_to_tests":{"src/control.py":["tests/test_control.sh"]}},
  "blocking_issues": [], "remediation_epochs": [],
  "understanding_review": {"restatement":"reject incomplete readiness","alternatives":["accept partial input"],"edge_cases":["blocked image"],"positive_examples":["complete package passes"],"negative_examples":["missing unit fails"],"requirement_reviews":[{"requirement_id":"REQ-1","source_unit_ids":["src-1:unit-1"],"restatement":"The system must reject an incomplete human requirement package.","alternative_interpretations":["The system may accept partial input."],"edge_cases":["The source contains an unsupported image."],"scope":["Readiness validation of this task."],"non_scope":["Operating-system sandboxing."],"assumptions":["The source unit is available."],"positive_example":{"input":"Complete source package","expected":"Readiness passes."},"negative_example":{"input":"Missing source unit","expected":"Readiness is rejected."},"unresolved_conflicts":[]}]}
}
EOF
"$root/scripts/readiness-control.sh" verify "$tmp/ready.json"
"$root/scripts/readiness-control.sh" lock "$tmp/ready.json" "$tmp/locked.json"
if "$root/scripts/readiness-control.sh" lock "$tmp/ready.json" "$tmp/locked.json" >/dev/null 2>&1; then
  echo "expected immutable lock rejection" >&2; exit 1
fi
python3 - "$tmp/ready.json" <<'PY'
import json, pathlib
p=pathlib.Path(__import__('sys').argv[1]); data=json.loads(p.read_text()); data["input_units"][0]["classification"]="blocked"; data["input_units"][0]["reason"]="parser failure"; p.write_text(json.dumps(data))
PY
if "$root/scripts/readiness-control.sh" verify "$tmp/ready.json" >/dev/null 2>&1; then
  echo "expected blocked input rejection" >&2; exit 1
fi
python3 - "$tmp/ready.json" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text())
data["input_units"][0]["classification"] = "used"
data["input_units"][0].pop("reason", None)
item = data["requirements"][0]["interpretation_evidence"][0]
item["confidence"] = "low"
p.write_text(json.dumps(data))
PY
if "$root/scripts/readiness-control.sh" verify "$tmp/ready.json" >/dev/null 2>&1; then
  echo "expected low-confidence interpretation rejection" >&2; exit 1
fi
python3 - "$tmp/ready.json" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text())
data["requirements"][0]["interpretation_evidence"][0]["confidence"] = "high"
data["understanding_review"]["requirement_reviews"][0]["restatement"] = "too short"
p.write_text(json.dumps(data))
PY
if "$root/scripts/readiness-control.sh" verify "$tmp/ready.json" >/dev/null 2>&1; then
  echo "expected shallow understanding review rejection" >&2; exit 1
fi
echo "Readiness control tests passed."
