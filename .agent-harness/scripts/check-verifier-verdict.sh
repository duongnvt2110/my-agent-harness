#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

verdict="${1:-}"
spec_hash="${2:-}"
policy_hash="${3:-}"
run_id="${4:-}"
risk="${5:-normal}"
snapshot_hash="${6:-}"
[ -n "$verdict" ] && [ -n "$spec_hash" ] && [ -n "$policy_hash" ] && [ -n "$run_id" ] || fail "Usage: scripts/check-verifier-verdict.sh VERDICT.json SPEC_HASH POLICY_HASH RUN_ID [RISK] [SNAPSHOT_HASH]"

python3 - "$verdict" "$spec_hash" "$policy_hash" "$run_id" "$risk" "$snapshot_hash" <<'PY'
from __future__ import annotations
import json, pathlib, re, sys
sys.path.insert(0, "scripts")
from provenance import verify as verify_provenance

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
spec_hash, policy_hash, run_id, risk, expected_snapshot_hash = sys.argv[2:]
errors: list[str] = []
if data.get("verdict") not in {"PASSED", "FAILED"}:
    errors.append("verdict must be PASSED or FAILED")
for key in ("task_id", "verification_function", "verification_id", "agent_session_id", "artifact_hash"):
    if not data.get(key):
        errors.append(f"missing {key}")
if data.get("verification_function") != "harness_verification":
    errors.append("verification_function must be harness_verification")
if data.get("agent_session_id") == data.get("verification_id"):
    errors.append("agent and harness verification identities must differ")
if not re.fullmatch(r"[0-9a-fA-F]{64}", str(data.get("artifact_hash", ""))):
    errors.append("artifact_hash is not sha256")
freshness = data.get("freshness", {})
if freshness.get("spec_hash") != spec_hash:
    errors.append("spec freshness mismatch")
if freshness.get("policy_hash") != policy_hash:
    errors.append("policy freshness mismatch")
if freshness.get("run_id") != run_id:
    errors.append("run freshness mismatch")
if expected_snapshot_hash and freshness.get("snapshot_hash") != expected_snapshot_hash:
    errors.append("snapshot freshness mismatch")
if risk == "high_risk" and data.get("model_independent") is True:
    errors.append("model_independent is not a repository-local harness guarantee")
if data.get("requires_isolation") is True and data.get("enforcement_mode") == "AUDIT_ONLY":
    errors.append("AUDIT_ONLY cannot satisfy isolation-dependent verification")
if data.get("enforcement_mode") == "ENFORCED" and not verify_provenance(data):
    errors.append("verifier verdict lacks protected issuer provenance")
result = {
    "verifier_validation_version": 1,
    "valid": not errors,
    "accepted_for_finalization": not errors and data.get("verdict") == "PASSED",
    "model_independent": bool(data.get("model_independent")),
    "errors": errors,
}
print(json.dumps(result, sort_keys=True))
raise SystemExit(0 if result["valid"] else 1)
PY
