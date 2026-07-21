#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

input="${1:-}"
[ -n "$input" ] || fail "Usage: scripts/classify-risk.sh evidence.json [--json]"
format="text"
[ "${2:-}" = "--json" ] && format="json"

python3 - "$input" "$format" "$HARNESS_ROOT/policies/risk-classification-v1.json" "$script_dir" <<'PY'
from __future__ import annotations
import json
import pathlib
import sys
sys.path.insert(0, sys.argv[4])
from provenance import verify

evidence_path = pathlib.Path(sys.argv[1])
output_format = sys.argv[2]
policy = json.loads(pathlib.Path(sys.argv[3]).read_text(encoding="utf-8"))
evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
if not isinstance(evidence, dict):
    raise SystemExit("risk evidence must be a JSON object")
if __import__("os").environ.get("HARNESS_WORKFLOW_VERSION") == "v3" and not verify(evidence):
    raise SystemExit("v3 risk evidence lacks protected provenance")

categories = {str(item).strip() for item in evidence.get("baseline_categories", [])}
signals = {str(item).strip() for item in evidence.get("mandatory_signals", [])}
observable = {str(item).strip() for item in evidence.get("observable_signals", [])}
matched_categories = sorted(categories & set(policy["baseline_high_risk_categories"]))
matched_signals = sorted((signals | observable) & set(policy["mandatory_high_risk_signals"]))
status = str(evidence.get("evidence_status", "missing")).lower()
reasons: list[str] = []

if matched_categories:
    risk = "high_risk"
    reasons.append("mandatory baseline high-risk category present")
elif matched_signals:
    risk = "high_risk"
    reasons.append("mandatory high-risk signal present")
elif status in {"missing", "ambiguous", "inconclusive", "unknown"}:
    risk = "normal"
    reasons.append("risk evidence is missing or ambiguous")
elif status == "clear_low_risk" and evidence.get("tiny_eligible") is True:
    risk = "tiny"
    reasons.append("clear low-risk evidence satisfies tiny-task policy")
else:
    risk = "normal"
    reasons.append("evidence does not prove tiny-task eligibility")

result = {
    "classifier_version": 1,
    "policy_id": policy["policy_id"],
    "risk": risk,
    "sticky": risk == "high_risk" and policy["high_risk_sticky"],
    "matched_baseline_categories": matched_categories,
    "matched_mandatory_signals": matched_signals,
    "reasons": reasons,
    "agent_requested_risk_ignored": evidence.get("requested_risk") is not None,
}
if output_format == "json":
    print(json.dumps(result, sort_keys=True))
else:
    print(f"classifier_version: {result['classifier_version']}")
    print(f"policy_id: {result['policy_id']}")
    print(f"risk: {result['risk']}")
    print(f"sticky: {'true' if result['sticky'] else 'false'}")
    for reason in result["reasons"]:
        print(f"reason: {reason}")
PY
