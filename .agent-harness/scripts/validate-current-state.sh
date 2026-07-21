#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

state_path=""
format="text"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --state)
      state_path="${2:-}"
      [ -n "$state_path" ] || fail "--state requires a path"
      shift 2
      ;;
    --json)
      format="json"
      shift
      ;;
    --require-v3)
      # Retained as a v3-only compatibility flag for existing gate wiring.
      shift
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: scripts/validate-current-state.sh --state PATH [--json]

Validate an explicit v3 state.json lifecycle authority without mutating state.
Legacy current.md projections and implicit state-source fallback are rejected.
USAGE
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$state_path" ] || fail "--state PATH is required; v3 validation never falls back to current.md"

python3 - "$state_path" "$format" "$HARNESS_ROOT" <<'PY'
from __future__ import annotations

import json
import hashlib
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
output_format = sys.argv[2]
harness_root = pathlib.Path(sys.argv[3])

def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)

def validate_event_chain(events_path, state):
    lines = [line for line in events_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    sequence = 0
    previous_hash = "0" * 64
    for line_number, line in enumerate(lines, 1):
        try:
            event = json.loads(line)
        except json.JSONDecodeError as exc:
            return f"invalid event JSON at line {line_number}: {exc}"
        if event.get("sequence") != sequence + 1:
            return "event sequence is not contiguous"
        if event.get("previous_hash") != previous_hash:
            return "event previous_hash does not match chain"
        event_hash = event.get("event_hash")
        unsigned = dict(event)
        unsigned.pop("event_hash", None)
        expected = hashlib.sha256((previous_hash + canonical(unsigned)).encode()).hexdigest()
        if event_hash != expected:
            return "event hash mismatch"
        sequence += 1
        previous_hash = event_hash
    if state.get("event_sequence") != sequence:
        return "state event_sequence does not match event log"
    if state.get("event_hash") != previous_hash:
        return "state event_hash does not match event log"
    if lines:
        last = json.loads(lines[-1])
        if last.get("run_id") != state.get("run_id") or last.get("task_id") != state.get("task_id"):
            return "event identity does not match state identity"
    return None

result: dict[str, object] = {
    "validator_version": 1,
    "source": str(path),
    "valid": False,
    "workflow_version": None,
    "authority": "unknown",
    "transition_writer": False,
    "enforcement_mode": "AUDIT_ONLY",
    "limitations": [],
    "errors": [],
}

writer = harness_root / "scripts" / "transition-state"
result["transition_writer"] = writer.is_file() and writer.stat().st_mode & 0o111 != 0

if not path.is_file():
    result["errors"] = [f"state source does not exist: {path}"]
elif path.suffix == ".json":
    result["authority"] = "state.json"
    result["workflow_version"] = 3
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        result["errors"] = [f"invalid state.json: {exc}"]
    else:
        required = ("schema_version", "canonicalization_version", "run_id", "task_id", "state", "active_function", "updated_at")
        missing = [key for key in required if not data.get(key)]
        allowed_states = {
            "INTAKE", "UNDER_REVIEW", "CLARIFICATION_REQUIRED", "HUMAN_APPROVED",
            "SPEC_LOCKED", "IMPLEMENTING", "VERIFYING", "REMEDIATING", "RETHINK_REQUIRED",
            "HUMAN_FINAL_REVIEW", "CONFLICT_REVIEW_REQUIRED", "RECOVERY_REQUIRED",
            "POST_APPROVAL_CHANGE_DETECTED", "FINALIZED", "CANCELLED",
        }
        errors = [f"missing required field: {key}" for key in missing]
        if not isinstance(data.get("schema_version"), int) or data.get("schema_version") < 1:
            errors.append("schema_version must be a positive integer")
        if data.get("canonicalization_version") != 1:
            errors.append("canonicalization_version must be 1")
        if data.get("state") not in allowed_states:
            errors.append("state is not a recognized v3 lifecycle state")
        events_path = path.parent / "events.jsonl"
        if events_path.exists():
            chain_error = validate_event_chain(events_path, data)
            if chain_error:
                errors.append(chain_error)
        if not result["transition_writer"]:
            errors.append("transition-state writer is missing or not executable")
        result["errors"] = errors
        result["valid"] = not errors
        result["limitations"] = [
            "v3 authority is locally validated; OS-level isolation is outside scope",
            "AUDIT_ONLY remains the honest enforcement mode until runtime controls exist",
        ]
else:
    result["errors"] = ["v3 state.json is required; legacy current.md is not an authority source"]
    result["valid"] = False
    result["limitations"] = [
        "current.md is a generated projection and cannot be validated as lifecycle authority",
    ]

if output_format == "json":
    print(json.dumps(result, sort_keys=True))
else:
    print(f"state_validation_version: {result['validator_version']}")
    print(f"source: {result['source']}")
    print(f"workflow_version: {result['workflow_version']}")
    print(f"authority: {result['authority']}")
    print(f"transition_writer: {'available' if result['transition_writer'] else 'missing'}")
    print(f"enforcement_mode: {result['enforcement_mode']}")
    print(f"valid: {'true' if result['valid'] else 'false'}")
    for item in result["limitations"]:
        print(f"limitation: {item}")
    for item in result["errors"]:
        print(f"error: {item}")

raise SystemExit(0 if result["valid"] else 1)
PY
