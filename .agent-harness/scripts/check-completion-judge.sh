#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

spec="${1:-}"
evidence="${2:-}"
verifier="${3:-}"
failures="${4:-}"
risk="${5:-normal}"
mode="${6:-AUDIT_ONLY}"
[ -n "$spec" ] && [ -n "$evidence" ] && [ -n "$verifier" ] && [ -n "$failures" ] || fail "Usage: scripts/check-completion-judge.sh SPEC EVIDENCE VERIFIER FAILURES [RISK] [MODE]"

python3 - "$spec" "$evidence" "$verifier" "$failures" "$risk" "$mode" <<'PY'
from __future__ import annotations
import json, pathlib, sys
import re

spec = json.loads(pathlib.Path(sys.argv[1]).read_text())
evidence = json.loads(pathlib.Path(sys.argv[2]).read_text())
verifier = json.loads(pathlib.Path(sys.argv[3]).read_text())
failures = json.loads(pathlib.Path(sys.argv[4]).read_text())
risk, mode = sys.argv[5:]
blocking = {row["id"] for row in spec.get("acceptance_criteria", []) if row.get("blocking", True)}
rows = evidence if isinstance(evidence, list) else evidence.get("evidence", [evidence])
passed = set()
errors: list[str] = []
retention = {"EPHEMERAL", "DEBUG_SHORT", "RUN_AUDIT", "PROJECT_RECORD", "COMPLIANCE_RECORD", "PROTECTED_EXTERNAL", "LEGAL_HOLD"}
for row in rows:
    if row.get("status") != "PASSED" or row.get("trusted") is not True or row.get("conclusive") is not True:
        continue
    ac_id = row.get("ac_id")
    missing = [key for key in ("evidence_class", "producer_actor", "verification_function", "verification_id", "retention_class", "artifact_hash") if not row.get(key)]
    if missing:
        errors.append(f"AC {ac_id} evidence missing: {','.join(missing)}")
        continue
    if not re.fullmatch(r"[0-9a-fA-F]{64}", str(row.get("artifact_hash"))):
        errors.append(f"AC {ac_id} evidence artifact_hash is not sha256")
        continue
    if row.get("retention_class") not in retention:
        errors.append(f"AC {ac_id} evidence has unknown retention class")
        continue
    if row.get("producer_actor") not in {"agent", "human", "harness"} or row.get("verification_function") != "harness_verification":
        errors.append(f"AC {ac_id} evidence has invalid actor/function authority")
        continue
    passed.add(ac_id)
missing = sorted(blocking - passed)
if missing:
    errors.append("blocking ACs unresolved: " + ",".join(missing))
if verifier.get("accepted_for_finalization") is not True or verifier.get("verification_function") != "harness_verification":
    errors.append("harness verification result does not authorize finalization")
if failures.get("unresolved", 0) != 0:
    errors.append("unresolved failure history remains")
if failures.get("audit_chain_valid") is not True:
    errors.append("failure history audit chain is not valid")
if risk == "high_risk" and mode == "AUDIT_ONLY" and verifier.get("requires_isolation") is True:
    errors.append("mandatory technical isolation is unavailable")
result = {
    "completion_judge_version": 1,
    "valid": not errors,
    "finalization_allowed": not errors,
    "blocking_ac_count": len(blocking),
    "passed_ac_count": len(blocking & passed),
    "errors": errors,
}
print(json.dumps(result, sort_keys=True))
raise SystemExit(0 if result["valid"] else 1)
PY
