#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

evidence="${1:-}"
spec_hash="${2:-}"
policy_hash="${3:-}"
run_id="${4:-}"
risk="${5:-normal}"
[ -n "$evidence" ] && [ -n "$spec_hash" ] && [ -n "$policy_hash" ] && [ -n "$run_id" ] || fail "Usage: scripts/check-ac-evidence.sh EVIDENCE.json SPEC_HASH POLICY_HASH RUN_ID [RISK]"

python3 - "$evidence" "$spec_hash" "$policy_hash" "$run_id" "$risk" <<'PY'
from __future__ import annotations
import json, pathlib, re, sys, time
sys.path.insert(0, "scripts")
from provenance import verify as verify_provenance

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
spec_hash, policy_hash, run_id, risk = sys.argv[2:]
rows = data if isinstance(data, list) else [data]
retention = {"EPHEMERAL", "DEBUG_SHORT", "RUN_AUDIT", "PROJECT_RECORD", "COMPLIANCE_RECORD", "PROTECTED_EXTERNAL", "LEGAL_HOLD"}
errors: list[str] = []
for row in rows:
    ac = row.get("ac_id", "")
    prefix = f"{ac or 'evidence'}: "
    if row.get("status") != "PASSED":
        errors.append(prefix + "status is not PASSED")
    for key in ("evidence_class", "producer_actor", "verification_function", "verification_id", "retention_class", "artifact_hash"):
        if not row.get(key):
            errors.append(prefix + f"missing {key}")
    if row.get("retention_class") not in retention:
        errors.append(prefix + "unknown retention class")
    if not re.fullmatch(r"[0-9a-fA-F]{64}", str(row.get("artifact_hash", ""))):
        errors.append(prefix + "artifact_hash is not sha256")
    freshness = row.get("freshness", {})
    if freshness.get("spec_hash") != spec_hash:
        errors.append(prefix + "spec freshness mismatch")
    if freshness.get("policy_hash") != policy_hash:
        errors.append(prefix + "policy freshness mismatch")
    if freshness.get("run_id") != run_id:
        errors.append(prefix + "run freshness mismatch")
    if row.get("trusted") is not True or row.get("conclusive") is not True:
        errors.append(prefix + "evidence is untrusted or inconclusive")
    if __import__("os").environ.get("HARNESS_WORKFLOW_VERSION") == "v3" and not verify_provenance(row):
        errors.append(prefix + "evidence lacks protected producer provenance")
    if not isinstance(row.get("expiry_epoch"), (int, float)) or row.get("expiry_epoch") <= time.time():
        errors.append(prefix + "evidence expiry is missing or elapsed")
    summary = row.get("sanitized_summary")
    if not isinstance(summary, str) or not summary.strip():
        errors.append(prefix + "sanitized_summary is required")
    if row.get("protected_reference") is not None and not row.get("protected_reference"):
        errors.append(prefix + "protected_reference must be non-empty when present")
    sensitive = {"credential", "credentials", "token", "secret", "password", "raw_environment", "environment_values", "raw_content"}
    def walk(value):
        if isinstance(value, dict):
            for key, child in value.items():
                if key.lower() in sensitive:
                    return True
                if walk(child):
                    return True
        if isinstance(value, list):
            return any(walk(child) for child in value)
        return False
    if walk(row):
        errors.append(prefix + "evidence contains prohibited raw sensitive content")
    if row.get("producer_actor") not in {"agent", "human", "harness"}:
        errors.append(prefix + "producer_actor must be human, agent, or harness")
    if row.get("verification_function") != "harness_verification":
        errors.append(prefix + "evidence must be evaluated by the harness verification function")
result = {"evidence_validation_version": 1, "valid": not errors, "errors": errors, "count": len(rows), "assurance_limitations": ["AUDIT_ONLY does not prove technical isolation"]}
print(json.dumps(result, sort_keys=True))
raise SystemExit(0 if result["valid"] else 1)
PY
