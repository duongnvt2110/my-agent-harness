#!/usr/bin/env bash
set -euo pipefail
metric="${1:-}"; used="${2:-}"; warn="${3:-}"; pause="${4:-}"; deny="${5:-}"; risk="${6:-}"
[ -n "$metric" ] && [ -n "$used" ] && [ -n "$warn" ] && [ -n "$pause" ] && [ -n "$deny" ] && [ -n "$risk" ] || { echo "Usage: budget-guard.sh METRIC USED WARN PAUSE DENY RISK" >&2; exit 2; }
python3 - "$metric" "$used" "$warn" "$pause" "$deny" "$risk" <<'PY'
import json,sys
metric,used,warn,pause,deny,risk=sys.argv[1:]; errors=[]
try: used,warn,pause,deny=map(float,(used,warn,pause,deny))
except ValueError: raise SystemExit("budget values must be numeric")
if risk not in {"tiny","normal","high_risk"}: errors.append("unknown risk")
if not (0 <= warn <= pause <= deny): errors.append("thresholds must satisfy warn <= pause <= deny")
if not metric or metric not in {"time","tokens","commands","tests","disk","network","remediation","subagents"}: errors.append("unknown metric")
action="DENY" if used>=deny else "PAUSE" if used>=pause else "WARN" if used>=warn else "ALLOW"
if errors: action="DENY"
result={"budget_guard_version":1,"metric":metric,"used":used,"warn":warn,"pause":pause,"deny":deny,"risk":risk,"decision":action,"preserves_failure_history":True,"weakens_verification":False,"expands_scope":False,"changes_model":False,"errors":errors}
print(json.dumps(result,sort_keys=True)); raise SystemExit(0 if not errors else 1)
PY
