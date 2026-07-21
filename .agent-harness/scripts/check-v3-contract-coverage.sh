#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

registry="${1:-policies/v3-contract.json}"
[ -f "$registry" ] || fail "Missing v3 contract registry: $registry"

python3 - "$registry" <<'PY'
import json
import pathlib
import sys

registry = pathlib.Path(sys.argv[1])
data = json.loads(registry.read_text())
if data.get("schema_version") != 1 or data.get("workflow_version") != "v3":
    raise SystemExit("unsupported v3 contract registry")
rules = data.get("rules")
if not isinstance(rules, list) or not rules:
    raise SystemExit("v3 contract registry must contain rules")
required = ("id", "name", "entry_points", "validators", "positive_tests", "negative_tests", "recovery_tests")
seen = set()
errors = []
for rule in rules:
    missing = [key for key in required if key not in rule]
    if missing:
        errors.append(f"{rule.get('id', '<unknown>')}: missing {','.join(missing)}")
        continue
    rule_id = rule["id"]
    if rule_id in seen:
        errors.append(f"duplicate rule id: {rule_id}")
    seen.add(rule_id)
    for key in ("entry_points", "validators", "positive_tests", "negative_tests", "recovery_tests"):
        values = rule[key]
        if not isinstance(values, list) or not values:
            errors.append(f"{rule_id}: {key} must be non-empty")
            continue
        for value in values:
            path = pathlib.Path(value.split(" ", 1)[0])
            if not path.exists():
                errors.append(f"{rule_id}: missing {key} path {value}")
    if rule.get("forbidden_paths") is not None and not isinstance(rule["forbidden_paths"], list):
        errors.append(f"{rule_id}: forbidden_paths must be an array")
if errors:
    raise SystemExit("contract coverage failed:\n" + "\n".join(f"- {error}" for error in errors))
print(json.dumps({"valid": True, "workflow_version": "v3", "rule_count": len(rules), "uncovered_blocking_rules": 0}, sort_keys=True))
PY
