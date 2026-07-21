#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

state_path="${1:-}"
[ -n "$state_path" ] || fail "Usage: scripts/check-state-schema.sh <state.json>"

python3 - "$state_path" "$HARNESS_ROOT/policies/state-schema-v1.json" <<'PY'
from __future__ import annotations

import json
import pathlib
import sys

state_path = pathlib.Path(sys.argv[1])
schema_path = pathlib.Path(sys.argv[2])
schema = json.loads(schema_path.read_text(encoding="utf-8"))
data = json.loads(state_path.read_text(encoding="utf-8"))
errors: list[str] = []

for key in schema["required"]:
    if key not in data:
        errors.append(f"missing required field: {key}")

if schema.get("additional_properties") is False:
    unknown = sorted(set(data) - set(schema["properties"]))
    errors.extend(f"unknown field: {key}" for key in unknown)

for key, rule in schema["properties"].items():
    if key not in data:
        continue
    value = data[key]
    types = rule["type"] if isinstance(rule["type"], list) else [rule["type"]]
    valid_type = any(
        (kind == "null" and value is None)
        or (kind == "string" and isinstance(value, str))
        or (kind == "integer" and isinstance(value, int) and not isinstance(value, bool))
        for kind in types
    )
    if not valid_type:
        errors.append(f"invalid type: {key}")
        continue
    if "const" in rule and value != rule["const"]:
        errors.append(f"unsupported value: {key}")
    if isinstance(value, str) and len(value) < rule.get("min_length", 0):
        errors.append(f"empty value: {key}")
    if isinstance(value, int) and value < rule.get("minimum", value):
        errors.append(f"value below minimum: {key}")

if errors:
    for error in errors:
        print(f"error: {error}")
    raise SystemExit(1)
print("state_schema: v1")
print("canonicalization_version: 1")
print("valid: true")
PY
