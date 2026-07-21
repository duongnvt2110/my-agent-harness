#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$harness_root"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/request.json" <<'JSON'
{
  "goal": "Add a controlled report command",
  "task_id": "task-intake-1",
  "run_id": "run-intake-1",
  "spec_version": "v3.1",
  "risk_decision_hash": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "business_context": "Operators need a deterministic report.",
  "current_behavior": "No report command exists.",
  "target_behavior": "The harness generates a report from verified state.",
  "requirements": [{"id":"REQ-001","statement":"Report only verified state."}],
  "business_rules": [{"id":"BR-001","requirement_ids":["REQ-001"],"rule":"Only verified state may be reported."}],
  "architecture_boundary": "Repository-local harness scripts only.",
  "data_ownership": "Harness owns lifecycle state.",
  "integration_boundaries": ["Local filesystem"],
  "permissions": ["Agent proposes; harness validates."],
  "acceptance_criteria": [{"id":"AC-001","business_rule_ids":["BR-001"],"behavior":"Report is generated from state"}],
  "traceability": {"source_to_requirements":{"src-1":["REQ-001"]},"requirement_to_rules":{"REQ-001":["BR-001"]},"rule_to_acceptance":{"BR-001":["AC-001"]},"acceptance_to_evidence":{"AC-001":["TEST-001"]}},
  "testable_examples": [{"given":"valid state","when":"report runs","then":"report is written"}],
  "out_of_scope": ["Network controls", "External identity"],
  "blocking_unknowns": [],
  "assumptions": ["State is present"],
  "risks": ["Stale state"],
  "verification_expectations": ["Run deterministic report test"],
  "sources": [{"id":"src-1","type":"text","location":"request.json","authority":"authoritative","content":"The supplied request is the captured source."}]
}
JSON

scripts/harness.sh intake create "$tmp/request.json" "$tmp/package.json"
test -f "$tmp/package.json.sources/0001-src-1.bin"
scripts/harness.sh understand "$tmp/package.json" | grep -q '"ready": true'
scripts/intake-control.sh verify "$tmp/package.json" >/dev/null

cat >"$tmp/questions.json" <<'JSON'
{"questions":[{"id":"Q-001","question":"Which output format is required?"}]}
JSON
scripts/harness.sh clarify "$tmp/package.json" "$tmp/questions.json" "$tmp/clarified.json"
if scripts/harness.sh understand "$tmp/clarified.json" >/dev/null 2>&1; then
  echo "clarification package must not be ready" >&2
  exit 1
fi
cat >"$tmp/answers.json" <<'JSON'
{"answers":[{"question_id":"Q-001","answer":"JSON"}]}
JSON
scripts/harness.sh answer "$tmp/clarified.json" "$tmp/answers.json" "$tmp/answered.json"
scripts/harness.sh understand "$tmp/answered.json" | grep -q '"ready": true'

printf 'provenance-test-key-012345678901234567890123456789\n' >"$tmp/provenance.key"
export HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key"
python3 - "$tmp/answered.json" "$tmp/approval.json" <<'PY'
import hashlib, hmac, json, pathlib, sys
package = json.loads(pathlib.Path(sys.argv[1]).read_text())
approval = {
    "action": "LOCK_SPECIFICATION",
    "approved": True,
    "human_id": "human-1",
    "approved_at": "2026-07-15T00:00:00Z",
    "expires_at": "2099-07-15T00:00:00Z",
    "candidate_hash": package["package_hash"],
    "task_id": package["task_id"],
    "run_id": package["run_id"],
    "risk_decision_hash": package["risk_decision_hash"],
    "authority_status": "PROTECTED",
}
canonical = json.dumps(approval, sort_keys=True, separators=(",", ":")).encode()
key = pathlib.Path(__import__("os").environ["HARNESS_PROVENANCE_KEY_FILE"]).read_bytes()
approval["issuer_mac"] = hmac.new(key, canonical, hashlib.sha256).hexdigest()
approval["approval_hash"] = hashlib.sha256(json.dumps(approval, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
pathlib.Path(sys.argv[2]).write_text(json.dumps(approval, sort_keys=True, indent=2) + "\n")
PY
scripts/harness.sh intake approve "$tmp/answered.json" "$tmp/approval.json" "$tmp/locked.json"
scripts/harness.sh intake verify "$tmp/locked.json" | grep -q '"status": "SPEC_LOCKED"'

cat >"$tmp/state.json" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-intake-1","task_id":"task-intake-1","state":"UNDER_REVIEW","active_function":"intake","updated_at":"2026-07-15T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
JSON
scripts/harness.sh intake bind "$tmp/locked.json" "$tmp/state.json" | grep -q '"status": "SPEC_LOCKED"'
scripts/harness.sh validate-state --state "$tmp/state.json" --json >/dev/null
test "$(wc -l < "$tmp/events.jsonl" | tr -d ' ')" = "1"
scripts/harness.sh intake bind "$tmp/locked.json" "$tmp/state.json" | grep -q '"idempotent": true'
test "$(wc -l < "$tmp/events.jsonl" | tr -d ' ')" = "1"

if scripts/harness.sh intake approve "$tmp/answered.json" "$tmp/approval.json" "$tmp/locked.json" >/dev/null 2>&1; then
  echo "locked package must remain immutable" >&2
  exit 1
fi

echo "one-file intake control-plane regression passed"
