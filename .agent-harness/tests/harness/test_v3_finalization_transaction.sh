#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/run" "$tmp/docs/tasks"
spec_hash="$(printf spec | shasum -a 256 | awk '{print $1}')"
policy_hash="$(printf policy | shasum -a 256 | awk '{print $1}')"
artifact_hash="$(printf artifact | shasum -a 256 | awk '{print $1}')"
snapshot_hash="$(printf snapshot | shasum -a 256 | awk '{print $1}')"
cat > "$tmp/spec.json" <<EOF
{"acceptance_criteria":[{"id":"AC-1","blocking":true}]}
EOF
cat > "$tmp/evidence.json" <<EOF
[{"ac_id":"AC-1","status":"PASSED","evidence_class":"deterministic_test","producer_actor":"agent","verification_function":"harness_verification","verification_id":"v-1","retention_class":"RUN_AUDIT","artifact_hash":"$artifact_hash","freshness":{"spec_hash":"$spec_hash","policy_hash":"$policy_hash","run_id":"run-1"},"trusted":true,"conclusive":true,"expiry_epoch":4102444800,"sanitized_summary":"passed"}]
EOF
cat > "$tmp/verifier.json" <<EOF
{"verdict":"PASSED","accepted_for_finalization":true,"task_id":"task-1","verification_function":"harness_verification","verification_id":"v-1","agent_session_id":"p-1","artifact_hash":"$artifact_hash","freshness":{"spec_hash":"$spec_hash","policy_hash":"$policy_hash","run_id":"run-1","snapshot_hash":"$snapshot_hash"}}
EOF
printf '%s\n' '{"unresolved":0,"audit_chain_valid":true}' > "$tmp/failures.json"
printf '%s' '01234567890123456789012345678901' > "$tmp/provenance.key"
python3 - "$tmp/evidence.json" "$tmp/approval.json" "$tmp/provenance.key" "$spec_hash" "$policy_hash" "$snapshot_hash" <<'PY'
import datetime
import hashlib
import hmac
import json
import pathlib
import sys

evidence_path, approval_path, key_path = map(pathlib.Path, sys.argv[1:4])
spec_hash, policy_hash, snapshot_hash = sys.argv[4:]
key = key_path.read_bytes()
evidence = json.loads(evidence_path.read_text())
for row in evidence:
    row["issuer_mac"] = hmac.new(key, json.dumps({k: v for k, v in row.items() if k != "issuer_mac"}, sort_keys=True, separators=(",", ":")).encode(), hashlib.sha256).hexdigest()
evidence_path.write_text(json.dumps(evidence) + "\n")
approval = {
    "approved": True,
    "human_id": "human-1",
    "approved_at": "2026-07-11T00:00:00+00:00",
    "reason": "human final review approved",
    "single_use": True,
    "task_id": "task-1",
    "run_id": "run-1",
    "spec_hash": spec_hash,
    "policy_hash": policy_hash,
    "snapshot_hash": snapshot_hash,
    "evidence_hash": hashlib.sha256(evidence_path.read_bytes()).hexdigest(),
    "authority_status": "PROTECTED",
}
approval["issuer_mac"] = hmac.new(key, json.dumps(approval, sort_keys=True, separators=(",", ":")).encode(), hashlib.sha256).hexdigest()
approval_path.write_text(json.dumps(approval) + "\n")
PY
cat > "$tmp/run/state.json" <<EOF
{"schema_version":1,"canonicalization_version":1,"run_id":"run-1","task_id":"task-1","state":"HUMAN_FINAL_REVIEW","active_function":"finalization","updated_at":"2026-07-11T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000","spec_hash":"$spec_hash","policy_hash":"$policy_hash","snapshot_hash":"$snapshot_hash"}
EOF
: > "$tmp/run/events.jsonl"
cat > "$tmp/run/current.md" <<'EOF'
---
generated: true
projection_source: state.json
run_id: run-1
task_id: task-1
state: HUMAN_FINAL_REVIEW
event_sequence: 0
---
EOF
printf '%s\n' '{"id":"task-1","status":"READY"}' > "$tmp/docs/tasks/tasks.jsonl"

if ! HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key" "$harness_root/scripts/finalize-v3-run" --state "$tmp/run/state.json" --spec "$tmp/spec.json" --evidence "$tmp/evidence.json" --verifier "$tmp/verifier.json" --failures "$tmp/failures.json" --approval "$tmp/approval.json" --task-store "$tmp/docs/tasks/tasks.jsonl" >"$tmp/first.out"; then cat "$tmp/first.out" >&2; exit 1; fi
[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["state"])' "$tmp/run/state.json")" = FINALIZED ]
[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["status"])' "$tmp/run/v3-finalization-journal.json")" = FINALIZED ]

printf '%s\n' '{"id":"task-1","status":"TAMPERED"}' > "$tmp/docs/tasks/tasks.jsonl"
if HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key" "$harness_root/scripts/finalize-v3-run" --state "$tmp/run/state.json" --spec "$tmp/spec.json" --evidence "$tmp/evidence.json" --verifier "$tmp/verifier.json" --failures "$tmp/failures.json" --approval "$tmp/approval.json" --task-store "$tmp/docs/tasks/tasks.jsonl" >/dev/null 2>&1; then
  echo 'tampered projection was accepted' >&2
  exit 1
fi
grep -q RECOVERY_REQUIRED "$tmp/run/v3-finalization-journal.json"
echo 'v3 finalization transaction regression passed'
