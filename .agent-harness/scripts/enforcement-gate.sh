#!/usr/bin/env bash
set -euo pipefail
risk="${1:-}"; operation="${2:-}"; mode="${3:-}"; controls="${4:-}"
[ -n "$risk" ] && [ -n "$operation" ] && [ -n "$mode" ] || { echo "Usage: enforcement-gate.sh RISK OPERATION MODE CONTROLS_CSV" >&2; exit 2; }
if [ "${HARNESS_WORKFLOW_VERSION:-}" = "v3" ]; then
  context="${HARNESS_AUTHORITY_CONTEXT:-}"
  [ -f "$context" ] || { echo "v3 enforcement requires protected authority context" >&2; exit 78; }
  python3 - "$context" "$risk" "$mode" <<'PY'
import json, sys
data=json.load(open(sys.argv[1]))
if data.get("risk") != sys.argv[2] or data.get("enforcement_mode") != sys.argv[3]:
    raise SystemExit("caller risk/enforcement does not match authoritative context")
if data.get("authority_status") != "PROTECTED":
    raise SystemExit("authority context is not protected provenance")
PY
fi
python3 - "$risk" "$operation" "$mode" "$controls" <<'PY'
import json,sys
risk, operation, mode, raw = sys.argv[1:]
known={"worktree","trusted_time","recovery_journal"}
provided=set(filter(None,raw.split(",")))
errors=[]
if risk not in {"tiny","normal","high_risk"}: errors.append("unknown risk classification")
if mode not in {"ENFORCED","AUDIT_ONLY"}: errors.append("unknown enforcement mode")
if provided-known: errors.append("unknown technical control")
mandatory={
 "mutation":{"worktree"},
 "network":set(),
 "integration":{"worktree","recovery_journal"},
 "rollback":{"worktree","recovery_journal","trusted_time"},
 "finalization":{"recovery_journal","trusted_time"},
 "verification":set(),
 "inspection":set(),
 "planning":set(),
}
if operation not in mandatory: errors.append("unknown operation class")
required=mandatory.get(operation,set())
if risk=="high_risk" and operation in {"mutation","network","integration","rollback","finalization"} and mode=="AUDIT_ONLY": errors.append("AUDIT_ONLY cannot authorize high-risk operation")
missing=sorted(required-provided)
if missing: errors.append("missing mandatory controls: "+",".join(missing))
result={"enforcement_gate_version":1,"allowed":not errors,"risk":risk,"operation":operation,"enforcement_mode":mode,"required_controls":sorted(required),"provided_controls":sorted(provided),"missing_controls":missing,"assurance_limitations":["post-edit validation is detection, not prevention"] if mode=="AUDIT_ONLY" else []}
print(json.dumps(result,sort_keys=True)); raise SystemExit(0 if not errors else 1)
PY
