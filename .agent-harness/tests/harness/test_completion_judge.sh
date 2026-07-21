#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hash='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
printf '%s\n' '{"acceptance_criteria":[{"id":"AC-001","blocking":true}]}' >"$tmp/spec.json"
printf '%s\n' "{\"evidence\":[{\"ac_id\":\"AC-001\",\"status\":\"PASSED\",\"trusted\":true,\"conclusive\":true,\"evidence_class\":\"deterministic_test\",\"producer_actor\":\"agent\",\"verification_function\":\"harness_verification\",\"verification_id\":\"verification-1\",\"retention_class\":\"RUN_AUDIT\",\"artifact_hash\":\"$hash\"}]}" >"$tmp/evidence.json"
printf '%s\n' '{"accepted_for_finalization":true,"verification_function":"harness_verification"}' >"$tmp/verifier.json"
printf '%s\n' '{"unresolved":0,"audit_chain_valid":true}' >"$tmp/failures.json"
result="$($harness_root/scripts/check-completion-judge.sh "$tmp/spec.json" "$tmp/evidence.json" "$tmp/verifier.json" "$tmp/failures.json")"
echo "$result" | grep -q '"finalization_allowed": true'

printf '%s\n' '{"unresolved":1,"audit_chain_valid":true}' >"$tmp/bad-failures.json"
if "$harness_root/scripts/check-completion-judge.sh" "$tmp/spec.json" "$tmp/evidence.json" "$tmp/verifier.json" "$tmp/bad-failures.json" >/dev/null 2>&1; then
  echo "completion judge ignored unresolved failures" >&2
  exit 1
fi

python3 - "$tmp/evidence.json" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text())
data["evidence"][0].pop("producer_actor")
p.write_text(json.dumps(data))
PY
if "$harness_root/scripts/check-completion-judge.sh" "$tmp/spec.json" "$tmp/evidence.json" "$tmp/verifier.json" "$tmp/failures.json" >/dev/null 2>&1; then
  echo "incomplete AC evidence provenance was accepted" >&2
  exit 1
fi

echo "Completion judge regression passed."
