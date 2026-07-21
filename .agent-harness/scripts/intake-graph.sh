#!/usr/bin/env bash
set -euo pipefail

command="${1:-}"; shift || true
usage() { echo "Usage: intake-graph.sh create|verify|impact ..." >&2; exit 2; }

if [[ "$command" == "create" ]]; then
  echo "intake-graph authority creation is retired in v3; use the canonical Change Package intake flow" >&2
  exit 64
fi

case "$command" in
  create)
    requirements="${1:-}"; spec_lock="${2:-}"; graph="${3:-}"; output="${4:-}"
    [ -f "$requirements" ] && [ -f "$spec_lock" ] && [ -f "$graph" ] && [ -n "$output" ] || usage
    python3 - "$requirements" "$spec_lock" "$graph" "$output" <<'PY'
import hashlib, json, pathlib, sys, uuid
def canonical(value): return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n"
req = json.loads(pathlib.Path(sys.argv[1]).read_text())
lock = json.loads(pathlib.Path(sys.argv[2]).read_text())
graph = json.loads(pathlib.Path(sys.argv[3]).read_text())
if lock.get("kind") != "SPEC_LOCK" or len(lock.get("spec_hash", "")) != 64:
    raise SystemExit("intake requires a verified specification lock")
tasks = graph.get("tasks", []); acs = graph.get("acceptance_criteria", [])
task_ids = {task.get("task_id") for task in tasks}; ac_ids = {ac.get("ac_id") for ac in acs}
if None in task_ids or None in ac_ids or len(task_ids) != len(tasks) or len(ac_ids) != len(acs):
    raise SystemExit("task and AC identities must be unique")
for task in tasks:
    if not task.get("ac_ids") or any(ac not in ac_ids for ac in task["ac_ids"]):
        raise SystemExit("every task must map to known acceptance criteria")
    if any(dep not in task_ids for dep in task.get("depends_on", [])):
        raise SystemExit("task dependency references unknown task")
for ac in acs:
    if ac.get("blocking") is True and not any(ac["ac_id"] in task.get("ac_ids", []) for task in tasks):
        raise SystemExit("blocking acceptance criterion has no task mapping")
for task in tasks:
    if task.get("check_ids") is None or any(not check for check in task["check_ids"]):
        raise SystemExit("task check_ids are required for traceability")
    consumption = task.get("dependency_consumption", {})
    if not isinstance(consumption, dict):
        raise SystemExit("dependency_consumption must be an object")
    for producer, contract in consumption.items():
        if producer not in task.get("depends_on", []):
            raise SystemExit("dependency consumption must reference a declared dependency")
        if not isinstance(contract, dict):
            raise SystemExit("dependency consumption contract must be an object")
        if contract.get("mode", "FINALIZED") == "EARLY_ARTIFACT":
            required = ("artifact_hash", "artifact_version", "contract_hash", "freshness", "rollback_semantics")
            if any(not contract.get(key) for key in required):
                raise SystemExit("early artifact consumption requires immutable hash, version, freshness, and rollback contract")
            if not isinstance(contract.get("artifact_hash"), str) or len(contract["artifact_hash"]) != 64:
                raise SystemExit("early artifact hash must be a sha256 identity")
        elif contract.get("mode", "FINALIZED") != "FINALIZED":
            raise SystemExit("unknown dependency consumption mode")
record = {"schema_version": 1, "canonicalization_version": 1, "kind": "INTAKE", "intake_id": str(uuid.uuid4()), "requirements_hash": hashlib.sha256(canonical(req).encode()).hexdigest(), "spec_hash": lock["spec_hash"], "graph": graph}
out = pathlib.Path(sys.argv[4]); out.parent.mkdir(parents=True, exist_ok=True)
if out.exists(): raise SystemExit("intake artifact is immutable")
out.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
PY
    ;;
  verify)
    intake="${1:-}"; [ -f "$intake" ] || usage
    python3 - "$intake" <<'PY'
import json, pathlib, sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text())
if data.get("kind") != "INTAKE" or data.get("schema_version") != 1 or data.get("canonicalization_version") != 1:
    raise SystemExit("invalid intake artifact")
graph = data.get("graph", {}); tasks = graph.get("tasks", []); acs = graph.get("acceptance_criteria", [])
if not tasks or not acs: raise SystemExit("intake graph is incomplete")
ids = {task["task_id"] for task in tasks}
if any(dep not in ids for task in tasks for dep in task.get("depends_on", [])): raise SystemExit("unknown dependency")
if any(not task.get("check_ids") for task in tasks): raise SystemExit("missing verification traceability")
for task in tasks:
    consumption = task.get("dependency_consumption", {})
    if not isinstance(consumption, dict): raise SystemExit("dependency_consumption must be an object")
    for producer, contract in consumption.items():
        if producer not in task.get("depends_on", []): raise SystemExit("dependency consumption references undeclared dependency")
        if not isinstance(contract, dict): raise SystemExit("dependency consumption contract must be an object")
        mode = contract.get("mode", "FINALIZED")
        if mode == "EARLY_ARTIFACT":
            if any(not contract.get(key) for key in ("artifact_hash", "artifact_version", "contract_hash", "freshness", "rollback_semantics")): raise SystemExit("incomplete early artifact contract")
            if not isinstance(contract.get("artifact_hash"), str) or len(contract["artifact_hash"]) != 64: raise SystemExit("invalid early artifact hash")
        elif mode != "FINALIZED": raise SystemExit("unknown dependency consumption mode")
print(json.dumps({"valid": True, "intake_id": data["intake_id"], "tasks": len(tasks), "acceptance_criteria": len(acs)}, sort_keys=True))
PY
    ;;
  impact)
    intake="${1:-}"; changed_ac="${2:-}"; [ -f "$intake" ] && [ -n "$changed_ac" ] || usage
    python3 - "$intake" "$changed_ac" <<'PY'
import json, pathlib, sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text()); changed = sys.argv[2]
graph = data.get("graph", {}); tasks = graph.get("tasks", []); acs = {ac.get("ac_id") for ac in graph.get("acceptance_criteria", [])}
if changed not in acs or any(not task.get("check_ids") for task in tasks) or any(any(ac not in acs for ac in task.get("ac_ids", [])) for task in tasks):
    print(json.dumps({"invalidates_all": True, "tasks": [task.get("task_id") for task in tasks], "checks": sorted({check for task in tasks for check in task.get("check_ids", [])})}, sort_keys=True)); raise SystemExit(0)
direct = {task["task_id"] for task in tasks if changed in task.get("ac_ids", [])}; affected = set(direct)
while True:
    additions = {task["task_id"] for task in tasks if task["task_id"] not in affected and any(dep in affected for dep in task.get("depends_on", []))}
    if not additions: break
    affected.update(additions)
checks = sorted({check for task in tasks if task["task_id"] in affected for check in task.get("check_ids", [])})
print(json.dumps({"invalidates_all": False, "direct_tasks": sorted(direct), "tasks": sorted(affected), "checks": checks}, sort_keys=True))
PY
    ;;
  *) usage ;;
esac
