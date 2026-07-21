#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command_name="${1:-validate}"
metadata="${2:-${HARNESS_WORKFLOW_METADATA:-}}"
if [ -f "$command_name" ] && [ -z "${2:-}" ]; then
  metadata="$command_name"
  command_name="validate"
fi
[ -n "$metadata" ] && [ -f "$metadata" ] || { echo "Usage: workflow-dispatch.sh validate|run COMMAND METADATA [ARGS...]" >&2; exit 2; }

dispatch_json="$(python3 - "$metadata" <<'PY'
import json, pathlib, sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text())
required = ("workflow_version", "implementation_version", "enforcement_mode", "assurance_limitations")
missing = [key for key in required if key not in data]
if missing:
    raise SystemExit("missing authoritative metadata: " + ",".join(missing))
version = data["workflow_version"]
if version != "v3":
    raise SystemExit("unsupported workflow version")
if data.get("mixed_artifacts") is True or data.get("migration_required") is True:
    raise SystemExit("mixed or migration-required artifacts fail closed")
if data["enforcement_mode"] not in {"ENFORCED", "AUDIT_ONLY"}:
    raise SystemExit("unsupported enforcement mode")
if not isinstance(data["assurance_limitations"], list):
    raise SystemExit("assurance_limitations must be a list")
print(json.dumps({
    "workflow_version": version,
    "implementation_version": data["implementation_version"],
    "enforcement_mode": data["enforcement_mode"],
    "assurance_limitations": data["assurance_limitations"],
    "dispatch": "v3_core",
}, sort_keys=True))
PY
)"

if [ "$command_name" = "validate" ]; then
  printf '%s\n' "$dispatch_json"
  exit 0
fi
[ "$command_name" = "run" ] || { echo "unsupported dispatcher operation" >&2; exit 2; }
command_name="${3:-}"
[ -n "$command_name" ] || { echo "run requires COMMAND" >&2; exit 2; }
version="$(python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["workflow_version"])' <<<"$dispatch_json")"
case "$version:$command_name" in
  v3:status|v3:next)
    state_path="$(python3 - "$metadata" <<'PY'
import json,sys
print(json.load(open(sys.argv[1])).get("state_path", ""))
PY
    )"
    [ -n "$state_path" ] || { echo "v3 metadata lacks state_path" >&2; exit 78; }
    "$script_dir/validate-current-state.sh" --state "$state_path" --require-v3 >/dev/null
    HARNESS_V3_DISPATCHED=1 HARNESS_WORKFLOW_METADATA="$metadata" exec "$script_dir/../harness.sh" "$command_name"
    ;;
  v3:verify)
    state_path="$(python3 - "$metadata" <<'PY'
import json,sys
print(json.load(open(sys.argv[1])).get("state_path", ""))
PY
    )"
    [ -n "$state_path" ] || { echo "v3 metadata lacks state_path" >&2; exit 78; }
    "$script_dir/validate-current-state.sh" --state "$state_path" --require-v3 >/dev/null
    HARNESS_V3_DISPATCHED=1 HARNESS_WORKFLOW_METADATA="$metadata" exec "$script_dir/../harness.sh" verify "${@:4}"
    ;;
  v3:finalize)
    if [ "$#" -le 3 ]; then
      HARNESS_WORKFLOW_VERSION=v3 HARNESS_V3_DISPATCHED=1 HARNESS_WORKFLOW_METADATA="$metadata" exec "$script_dir/../harness.sh" finalize-task
    fi
    HARNESS_WORKFLOW_VERSION=v3 HARNESS_V3_DISPATCHED=1 HARNESS_WORKFLOW_METADATA="$metadata" exec "$script_dir/finalize-v3-run" "${@:4}"
    ;;
  *)
    echo "unsupported or ambiguous workflow command; no fallback" >&2
    exit 78
    ;;
esac
