#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$harness_root"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/remote-request.json" <<'JSON'
{
  "task_id": "task-integrity-1",
  "run_id": "run-integrity-1",
  "spec_version": "v3.1",
  "risk_decision_hash": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "goal": "Verify a captured remote source",
  "business_context": "The harness must preserve source evidence.",
  "current_behavior": "Remote evidence is supplied without a frozen capture contract.",
  "target_behavior": "Remote evidence is frozen and verified.",
  "business_rules": [{"id":"BR-001","requirement_ids":["REQ-001"],"rule":"Use frozen evidence."}],
  "architecture_boundary": "Harness-local control plane.",
  "data_ownership": "Harness owns package evidence.",
  "integration_boundaries": ["Generic URL capture"],
  "permissions": ["Agent proposes; harness validates."],
  "acceptance_criteria": [{"id":"AC-001","business_rule_ids":["BR-001"],"behavior":"Evidence is verified."}],
  "testable_examples": [{"given":"captured response","when":"verify runs","then":"hash matches"}],
  "out_of_scope": ["Adapters"],
  "blocking_unknowns": [],
  "assumptions": [],
  "risks": [],
  "verification_expectations": ["Run integrity tests."],
  "requirements": [{"id":"REQ-001","statement":"Preserve evidence."}],
  "traceability": {"source_to_requirements":{"src-remote":["REQ-001"]},"requirement_to_rules":{"REQ-001":["BR-001"]},"rule_to_acceptance":{"BR-001":["AC-001"]},"acceptance_to_evidence":{"AC-001":["TEST-001"]}},
  "sources": [{"id":"src-remote","type":"url","location":"https://example.test/spec","authority":"authoritative","request":"GET /spec","retrieved_at":"2026-07-15T00:00:00Z","response":"frozen response"}]
}
JSON
scripts/intake-control.sh create "$tmp/remote-request.json" "$tmp/remote-package.json" >/dev/null
scripts/intake-control.sh verify "$tmp/remote-package.json" >/dev/null
python3 - "$tmp/remote-request.json" "$tmp/duplicate-request.json" <<'PY'
import json, pathlib, sys
value = json.loads(pathlib.Path(sys.argv[1]).read_text())
value["requirements"].append(dict(value["requirements"][0]))
pathlib.Path(sys.argv[2]).write_text(json.dumps(value) + "\n")
PY
if scripts/intake-control.sh create "$tmp/duplicate-request.json" "$tmp/duplicate-package.json" >/dev/null 2>&1; then
  echo "duplicate contract IDs were accepted" >&2
  exit 1
fi
snapshot="$tmp/remote-package.json.sources/0001-src-remote.bin"
printf 'tampered response' >"$snapshot"
if scripts/intake-control.sh verify "$tmp/remote-package.json" >/dev/null 2>&1; then
  echo "tampered source snapshot was accepted" >&2
  exit 1
fi

cat >"$tmp/incomplete-request.json" <<'JSON'
{"task_id":"task-integrity-2","run_id":"run-integrity-2","spec_version":"v3.1","risk_decision_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","goal":"x","business_context":"x","current_behavior":"x","target_behavior":"x","business_rules":[{"id":"BR-001"}],"architecture_boundary":"x","data_ownership":"x","integration_boundaries":[],"permissions":[],"acceptance_criteria":[{"id":"AC-001"}],"testable_examples":[],"out_of_scope":[],"blocking_unknowns":[],"assumptions":[],"risks":[],"verification_expectations":[],"requirements":[{"id":"REQ-001"}],"traceability":{"source_to_requirements":{"src-1":["REQ-001"]},"requirement_to_rules":{"REQ-001":["BR-001"]},"rule_to_acceptance":{"BR-001":["AC-001"]},"acceptance_to_evidence":{}},"sources":[{"id":"src-1","type":"text","location":"inline","authority":"authoritative","content":"x"}]}
JSON
if scripts/intake-control.sh create "$tmp/incomplete-request.json" "$tmp/incomplete-package.json" >/dev/null 2>&1; then
  echo "incomplete normative traceability was accepted" >&2
  exit 1
fi

cat >"$tmp/partial-request.json" <<'JSON'
{"task_id":"task-integrity-3","run_id":"run-integrity-3","spec_version":"v3.1","risk_decision_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","goal":"x","business_context":"x","current_behavior":"x","target_behavior":"x","business_rules":[{"id":"BR-001"}],"architecture_boundary":"x","data_ownership":"x","integration_boundaries":[],"permissions":[],"acceptance_criteria":[{"id":"AC-001"}],"testable_examples":[],"out_of_scope":[],"blocking_unknowns":[],"assumptions":[],"risks":[],"verification_expectations":[],"requirements":[{"id":"REQ-001"}],"traceability":{"source_to_requirements":{"src-1":["REQ-001"],"src-2":["REQ-001"]},"requirement_to_rules":{"REQ-001":["BR-001"]},"rule_to_acceptance":{"BR-001":["AC-001"]},"acceptance_to_evidence":{"AC-001":["TEST-001"]}},"sources":[{"id":"src-1","type":"text","location":"inline","authority":"authoritative","content":"x"},{"id":"src-2","type":"text","location":"missing"}]}
JSON
if scripts/intake-control.sh create "$tmp/partial-request.json" "$tmp/partial-package.json" >/dev/null 2>&1; then
  echo "partial source package was accepted" >&2
  exit 1
fi
if compgen -G "$tmp/.partial-package.json.sources.*.tmp" >/dev/null; then
  echo "partial source staging directory was left behind" >&2
  exit 1
fi

printf 'frozen response' >"$snapshot"
mkdir -p "$tmp/outside"
printf 'outside evidence' >"$tmp/outside/evidence.bin"
python3 - "$tmp/remote-package.json" "$tmp/path-package.json" <<'PY'
import hashlib, json, pathlib, sys
value = json.loads(pathlib.Path(sys.argv[1]).read_text())
value["sources"][0]["snapshot_path"] = "../outside/evidence.bin"
value["package_hash"] = hashlib.sha256((json.dumps({k:v for k,v in value.items() if k != "package_hash"}, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()).hexdigest()
pathlib.Path(sys.argv[2]).write_text(json.dumps(value) + "\n")
PY
if scripts/intake-control.sh verify "$tmp/path-package.json" >/dev/null 2>&1; then
  echo "snapshot path traversal was accepted" >&2
  exit 1
fi
printf 'provenance-test-key-012345678901234567890123456789\n' >"$tmp/provenance.key"
export HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key"
python3 - "$tmp/remote-package.json" "$tmp/approval.json" <<'PY'
import hashlib, hmac, json, pathlib, sys
package = json.loads(pathlib.Path(sys.argv[1]).read_text())
approval = {"action":"LOCK_SPECIFICATION","approved":True,"human_id":"human-1","approved_at":"2026-07-15T00:00:00Z","expires_at":"2099-07-15T00:00:00Z","candidate_hash":package["package_hash"],"task_id":package["task_id"],"run_id":package["run_id"],"risk_decision_hash":package["risk_decision_hash"],"authority_status":"PROTECTED"}
key = pathlib.Path(__import__("os").environ["HARNESS_PROVENANCE_KEY_FILE"]).read_bytes()
approval["issuer_mac"] = hmac.new(key, json.dumps(approval, sort_keys=True, separators=(",", ":")).encode(), hashlib.sha256).hexdigest()
approval["approval_hash"] = hashlib.sha256(json.dumps(approval, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
pathlib.Path(sys.argv[2]).write_text(json.dumps(approval) + "\n")
PY
scripts/intake-control.sh approve "$tmp/remote-package.json" "$tmp/approval.json" "$tmp/locked-package.json" >/dev/null
python3 - "$tmp/locked-package.json" "$tmp/state.json" <<'PY'
import json, pathlib, sys
package = json.loads(pathlib.Path(sys.argv[1]).read_text())
readiness_path = pathlib.Path(sys.argv[2]).with_name("readiness.json")
source_path = readiness_path.with_name("readiness-source.txt")
source_path.write_text("frozen requirement source\n")
import hashlib
source_hash = hashlib.sha256(source_path.read_bytes()).hexdigest()
readiness = {
    "schema_version": 1, "canonicalization_version": 1,
    "artifact": "v3-implementation-readiness", "readiness_id": "readiness-integrity",
    "task_id": package["task_id"], "run_id": package["run_id"], "version": 1,
    "status": "READY", "input_manifest_hash": source_hash,
    "created_at": "2026-07-15T00:00:00Z", "updated_at": "2026-07-15T00:00:00Z",
    "sources": [{"id":"src-ready","kind":"file","location":str(source_path),"content_hash":source_hash,"authority":"normative","classification":"used"}],
    "input_units": [{"id":"src-ready:unit-1","source_id":"src-ready","classification":"used"}],
    "requirements": [{"id":"REQ-READY","authority":"normative","source_unit_ids":["src-ready:unit-1"],"evidence":"frozen requirement source","acceptance_ids":["AC-READY"],"positive_test":"valid implementation","negative_test":"invalid implementation","interpretation_evidence":[{"source_unit_id":"src-ready:unit-1","locator":"line 1","excerpt":"frozen requirement source","interpretation":"The implementation must preserve the frozen source contract.","confidence":"high","uncertainty":"none","authority":"normative","contradictions":[],"assumptions":[]}]}],
    "traceability": {"source_to_requirements":{"src-ready:unit-1":["REQ-READY"]},"requirement_to_plan":{"REQ-READY":["PLAN-READY"]},"plan_to_code":{"PLAN-READY":["scripts/intake-control.sh"]},"code_to_tests":{"scripts/intake-control.sh":["tests/harness/test_authority_integrity_followup.sh"]}},
    "blocking_issues": [], "remediation_epochs": [],
    "understanding_review": {"restatement":"The harness must preserve the frozen source contract before implementation begins.","alternatives":["Allow implementation without a frozen source contract."],"edge_cases":["The source snapshot is tampered."],"positive_examples":["A verified source snapshot is present."],"negative_examples":["The source snapshot is missing."],"requirement_reviews":[{"requirement_id":"REQ-READY","source_unit_ids":["src-ready:unit-1"],"restatement":"The harness must preserve the frozen source contract before implementation begins.","alternative_interpretations":["Implementation can proceed without frozen evidence."],"edge_cases":["The source snapshot is tampered."],"scope":["Implementation readiness."],"non_scope":["Operating-system isolation."],"assumptions":["The source file is available."],"positive_example":{"input":"Verified source snapshot","expected":"Readiness passes."},"negative_example":{"input":"Missing source snapshot","expected":"Readiness fails."},"unresolved_conflicts":[]}]}
}
readiness_path.write_text(json.dumps(readiness) + "\n")
state = {"schema_version":1,"canonicalization_version":1,"run_id":package["run_id"],"task_id":package["task_id"],"state":"SPEC_LOCKED","active_function":"intake","updated_at":"2026-07-15T00:00:00Z","event_sequence":0,"event_hash":"0"*64,"spec_hash":package["package_hash"],"spec_lock_status":"VERIFIED","readiness_path":str(readiness_path)}
pathlib.Path(sys.argv[2]).write_text(json.dumps(state) + "\n")
PY
scripts/transition-state --state "$tmp/state.json" --to IMPLEMENTING --package "$tmp/locked-package.json" --check >/dev/null
if scripts/transition-state --state "$tmp/state.json" --to IMPLEMENTING --package "$tmp/remote-package.json" --check >/dev/null 2>&1; then
  echo "mismatched implementation package was accepted" >&2
  exit 1
fi
if scripts/transition-state --state "$tmp/state.json" --to IMPLEMENTING --check >/dev/null 2>&1; then
  echo "implementation without package proof was accepted" >&2
  exit 1
fi

cat >"$tmp/recovery-state.json" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-recovery","task_id":"task-recovery","state":"VERIFYING","active_function":"verification","updated_at":"2026-07-15T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
JSON
scripts/transition-state --state "$tmp/recovery-state.json" --to REMEDIATING --check >/dev/null

cat >"$tmp/audit-failure.json" <<'JSON'
{"run_id":"run-recovery","task_id":"task-recovery","risk":"normal","kind":"audit_integrity","message":"source snapshot hash mismatch","spec_hash":"s","policy_hash":"p","command_hash":"c","environment_hash":"e","patch_hash":"x"}
JSON
resolution="$(scripts/record-failure.sh "$tmp/failure-history.jsonl" "$tmp/audit-failure.json")"
echo "$resolution" | grep -q '"resolution": "RECOVERY_REQUIRED"'
scripts/check-failure-history.sh "$tmp/failure-history.jsonl" | grep -q '^failure_history_valid: true$'

echo "Authority integrity follow-up regression passed."
