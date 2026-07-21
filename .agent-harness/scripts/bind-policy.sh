#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

policy=""
intake=""
task=""
run=""
output=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --policy) policy="${2:-}"; shift 2 ;;
    --intake) intake="${2:-}"; shift 2 ;;
    --task) task="${2:-}"; shift 2 ;;
    --run) run="${2:-}"; shift 2 ;;
    --out) output="${2:-}"; shift 2 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done
[ -n "$policy" ] || fail "--policy is required"
[ -n "$intake" ] || fail "--intake is required"
[ -n "$task" ] || fail "--task is required"
[ -n "$run" ] || fail "--run is required"

python3 - "$policy" "$intake" "$task" "$run" "$output" <<'PY'
from __future__ import annotations
import hashlib
import json
import pathlib
import sys

policy = pathlib.Path(sys.argv[1])
if not policy.is_file():
    raise SystemExit(f"policy does not exist: {policy}")
bundle = json.loads(policy.read_text())
if bundle.get("schema_version") != 1 or bundle.get("canonicalization_version") != 1:
    raise SystemExit("unsupported policy bundle schema or canonicalization version")
for key in ("policy_bundle_id", "policy_bundle_version", "enforcement_mode", "unknown_trust", "high_risk_mutation_without_controls"):
    if key not in bundle:
        raise SystemExit(f"policy bundle missing {key}")
if bundle["enforcement_mode"] not in {"ENFORCED", "AUDIT_ONLY"}:
    raise SystemExit("unsupported enforcement mode")
binding = {
    "binding_version": 1,
    "policy_bundle_hash": hashlib.sha256(policy.read_bytes()).hexdigest(),
    "intake_id": sys.argv[2],
    "task_id": sys.argv[3],
    "run_id": sys.argv[4],
    "policy_bundle_id": bundle["policy_bundle_id"],
    "policy_bundle_version": bundle["policy_bundle_version"],
    "enforcement_mode": bundle["enforcement_mode"],
    "authority": "control_plane",
}
if sys.argv[5]:
    output = pathlib.Path(sys.argv[5])
    if output.exists():
        raise SystemExit("policy binding is immutable")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(binding, sort_keys=True, indent=2) + "\n")
print(json.dumps(binding, sort_keys=True))
PY
