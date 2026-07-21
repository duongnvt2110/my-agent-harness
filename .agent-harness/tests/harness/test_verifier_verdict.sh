#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hash='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
cat >"$tmp/verdict.json" <<EOF
{"task_id":"task-1","verdict":"PASSED","verification_function":"harness_verification","verification_id":"verification-1","agent_session_id":"agent-1","artifact_hash":"$hash","freshness":{"spec_hash":"spec-1","policy_hash":"policy-1","run_id":"run-1"},"requires_isolation":false,"enforcement_mode":"AUDIT_ONLY"}
EOF
result="$($harness_root/scripts/check-verifier-verdict.sh "$tmp/verdict.json" spec-1 policy-1 run-1 high_risk)"
echo "$result" | grep -q '"accepted_for_finalization": true'
echo "$result" | grep -q '"model_independent": false'

if "$harness_root/scripts/check-verifier-verdict.sh" "$tmp/verdict.json" spec-1 policy-1 run-1 normal snapshot-1 >/dev/null 2>&1; then
  echo "missing snapshot freshness was accepted" >&2
  exit 1
fi
python3 - "$tmp/verdict.json" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text())
data["freshness"]["snapshot_hash"] = "snapshot-1"
p.write_text(json.dumps(data))
PY
snapshot_result="$($harness_root/scripts/check-verifier-verdict.sh "$tmp/verdict.json" spec-1 policy-1 run-1 normal snapshot-1)"
echo "$snapshot_result" | grep -q '"valid": true'

python3 - "$tmp/verdict.json" "$tmp/bad.json" <<'PY'
import json, pathlib, sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text())
data["agent_session_id"] = "verification-1"
pathlib.Path(sys.argv[2]).write_text(json.dumps(data))
PY
if "$harness_root/scripts/check-verifier-verdict.sh" "$tmp/bad.json" spec-1 policy-1 run-1 normal >/dev/null 2>&1; then
  echo "same-session verifier was accepted" >&2
  exit 1
fi

echo "Verifier verdict regression passed."
