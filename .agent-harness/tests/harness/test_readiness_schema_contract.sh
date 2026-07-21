#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
schema="$root/policies/readiness-schema-v1.json"
transitions="$root/policies/readiness-transitions.yaml"

python3 - "$schema" "$transitions" <<'PY'
import json
import pathlib
import re
import sys

schema = json.loads(pathlib.Path(sys.argv[1]).read_text())
if schema.get("schema_version") != 1:
    raise SystemExit("readiness schema version must be 1")
if schema.get("artifact") != "v3-implementation-readiness":
    raise SystemExit("unexpected readiness artifact name")
required = {
    "schema_version", "canonicalization_version", "readiness_id", "task_id",
    "run_id", "version", "status", "input_manifest_hash", "created_at", "updated_at",
}
if set(schema.get("required", [])) != required:
    raise SystemExit("readiness schema required fields are incomplete")
statuses = set(schema.get("statuses", []))
if statuses != {"COLLECTING", "ANALYZING", "REMEDIATING", "RETHINK_REQUIRED", "READY", "LOCKED"}:
    raise SystemExit("readiness statuses are incomplete")

lines = pathlib.Path(sys.argv[2]).read_text().splitlines()
states = {}
terminal = set()
in_transitions = False
for line in lines:
    if line.startswith("terminal_states:"):
        terminal = set(re.findall(r"[A-Z_]+", line.split(":", 1)[1]))
    elif line == "transitions:":
        in_transitions = True
    elif in_transitions and line.startswith("  ") and ":" in line:
        state, values = line.strip().split(":", 1)
        states[state] = set(re.findall(r"[A-Z_]+", values))

if set(states) != statuses | {"CANCELLED"}:
    raise SystemExit("readiness transition states do not match schema")
if terminal != {"LOCKED"} or states["LOCKED"]:
    raise SystemExit("LOCKED must be the only terminal readiness state")
if not {"ANALYZING", "CANCELLED"}.issubset(states["COLLECTING"]):
    raise SystemExit("COLLECTING transitions are incomplete")
if "RETHINK_REQUIRED" not in states["REMEDIATING"]:
    raise SystemExit("remediation must be able to require rethink")
if "REMEDIATING" not in states["RETHINK_REQUIRED"]:
    raise SystemExit("rethink must return to autonomous remediation")
if "LOCKED" not in states["READY"]:
    raise SystemExit("READY must be the only path to LOCKED")
for source, targets in states.items():
    if source == "LOCKED" and targets:
        raise SystemExit("LOCKED has an outgoing transition")
    if source != "LOCKED" and "LOCKED" in targets and source != "READY":
        raise SystemExit(f"non-ready state can lock: {source}")

print(json.dumps({"valid": True, "readiness_states": len(statuses), "terminal_state": "LOCKED"}, sort_keys=True))
PY
