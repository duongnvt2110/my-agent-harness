#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"
schema="$root/policies/readiness-schema-v1.json"

usage() { echo "Usage: readiness-control.sh verify|lock|impact|rethink FILE [FILE...]" >&2; exit 2; }
command="${1:-}"; shift || true
[ -f "$schema" ] || { echo "missing readiness schema" >&2; exit 1; }

python3 - "$command" "$@" <<'PY'
import datetime as dt
import hashlib
import json
import pathlib
import sys

command, *args = sys.argv[1:]

def fail(message):
    raise SystemExit(message)

def load(path):
    try:
        value = json.loads(pathlib.Path(path).read_text())
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"invalid readiness JSON: {exc}")
    if not isinstance(value, dict):
        fail("readiness record must be an object")
    return value

def digest(value):
    body = dict(value)
    body.pop("record_hash", None)
    return hashlib.sha256((json.dumps(body, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()).hexdigest()

def validate(value, require_ready=False):
    required = {"schema_version", "canonicalization_version", "artifact", "readiness_id", "task_id", "run_id", "version", "status", "input_manifest_hash", "created_at", "updated_at", "sources", "input_units", "requirements", "traceability", "blocking_issues"}
    missing = required - set(value)
    if missing: fail("missing readiness fields: " + ",".join(sorted(missing)))
    if value.get("schema_version") != 1 or value.get("canonicalization_version") != 1 or value.get("artifact") != "v3-implementation-readiness":
        fail("unsupported readiness schema")
    statuses = {"COLLECTING", "ANALYZING", "REMEDIATING", "RETHINK_REQUIRED", "READY", "LOCKED"}
    status = value.get("status")
    if status not in statuses: fail(f"invalid readiness status: {status}")
    if not isinstance(value["version"], int) or value["version"] < 1: fail("readiness version must be positive")
    for key in ("input_manifest_hash",):
        if not isinstance(value[key], str) or len(value[key]) != 64: fail(f"{key} must be sha256")
    if not isinstance(value["sources"], list) or not value["sources"]: fail("sources must be non-empty")
    if not isinstance(value["input_units"], list) or not value["input_units"]: fail("input_units must be non-empty")
    source_ids = {row.get("id") for row in value["sources"] if isinstance(row, dict)}
    if None in source_ids or len(source_ids) != len(value["sources"]): fail("source IDs must be unique")
    unit_ids = {row.get("id") for row in value["input_units"] if isinstance(row, dict)}
    if None in unit_ids or len(unit_ids) != len(value["input_units"]): fail("input unit IDs must be unique")
    if any(not row.get("source_id") or row.get("source_id") not in source_ids for row in value["input_units"]): fail("every input unit must bind to a known source")
    terminal = {"used", "irrelevant", "blocked"}
    for row in value["sources"] + value["input_units"]:
        if not isinstance(row, dict) or row.get("classification") not in terminal:
            fail("every source and input unit requires used, irrelevant, or blocked classification")
        if row["classification"] != "used" and not row.get("reason"):
            fail("irrelevant or blocked input requires a reason")
        if row["classification"] == "blocked":
            fail(f"blocked input prevents readiness: {row.get('id')}")
    if not isinstance(value["requirements"], list) or not value["requirements"]: fail("requirements must be non-empty")
    requirement_ids = {row.get("id") for row in value["requirements"] if isinstance(row, dict)}
    if None in requirement_ids or len(requirement_ids) != len(value["requirements"]): fail("requirement IDs must be unique")
    for row in value["requirements"]:
        if not row.get("source_unit_ids"): fail(f"requirement has no source units: {row.get('id')}")
        if not set(row["source_unit_ids"]).issubset(unit_ids): fail(f"requirement references unknown source unit: {row.get('id')}")
        if not row.get("acceptance_ids"): fail(f"requirement has no acceptance criteria: {row.get('id')}")
        if not row.get("evidence"): fail(f"requirement has no source evidence: {row.get('id')}")
        if row.get("conflicts"): fail(f"requirement has unresolved conflicts: {row.get('id')}")
        if not row.get("positive_test") or not row.get("negative_test"): fail(f"requirement needs positive and negative tests: {row.get('id')}")
        if row.get("authority") == "proposed": fail(f"proposed authority is not normative: {row.get('id')}")
        interpretations = row.get("interpretation_evidence")
        if not isinstance(interpretations, list) or not interpretations:
            fail(f"requirement needs structured interpretation evidence: {row.get('id')}")
        for item in interpretations:
            if not isinstance(item, dict): fail(f"invalid interpretation evidence: {row.get('id')}")
            source_unit_id = item.get("source_unit_id")
            if source_unit_id not in unit_ids or source_unit_id not in set(row["source_unit_ids"]):
                fail(f"interpretation evidence is not bound to the requirement source: {row.get('id')}")
            if not item.get("locator"): fail(f"interpretation evidence needs a source location: {row.get('id')}")
            if not item.get("excerpt") and not item.get("region"):
                fail(f"interpretation evidence needs an excerpt or region: {row.get('id')}")
            if not item.get("interpretation"): fail(f"interpretation evidence needs an interpretation: {row.get('id')}")
            if item.get("confidence") not in {"high", "medium", "low"}:
                fail(f"interpretation evidence needs confidence: {row.get('id')}")
            if item.get("confidence") != "high":
                fail(f"low-confidence interpretation blocks readiness: {row.get('id')}")
            if not item.get("uncertainty"): fail(f"interpretation evidence needs uncertainty: {row.get('id')}")
            if item.get("authority") == "proposed": fail(f"proposed evidence authority is not normative: {row.get('id')}")
            contradictions = item.get("contradictions", [])
            if contradictions: fail(f"interpretation evidence has unresolved contradictions: {row.get('id')}")
    if value.get("status") in {"READY", "LOCKED"}:
        review = value.get("understanding_review")
        if not isinstance(review, dict): fail("READY readiness requires an understanding review")
        for key in ("restatement", "alternatives", "edge_cases", "positive_examples", "negative_examples"):
            if not review.get(key): fail(f"understanding review missing {key}")
        reviews = review.get("requirement_reviews")
        if not isinstance(reviews, list) or not reviews:
            fail("READY readiness requires a review for every requirement")
        review_ids = {row.get("requirement_id") for row in reviews if isinstance(row, dict)}
        if review_ids != requirement_ids:
            fail("understanding reviews must cover exactly every requirement")
        requirements_by_id = {row["id"]: row for row in value["requirements"]}
        for item in reviews:
            if not isinstance(item, dict): fail("invalid requirement understanding review")
            requirement = requirements_by_id[item["requirement_id"]]
            bound_units = set(item.get("source_unit_ids", []))
            if not bound_units or not bound_units.issubset(set(requirement["source_unit_ids"])):
                fail(f"understanding review is not bound to requirement evidence: {item['requirement_id']}")
            if len(str(item.get("restatement", "")).strip()) < 20:
                fail(f"understanding review restatement is too shallow: {item['requirement_id']}")
            for key in ("alternative_interpretations", "edge_cases", "scope", "non_scope", "assumptions"):
                if not isinstance(item.get(key), list) or not item[key]:
                    fail(f"understanding review missing {key}: {item['requirement_id']}")
            if item.get("unresolved_conflicts"):
                fail(f"understanding review has unresolved conflicts: {item['requirement_id']}")
            for key in ("positive_example", "negative_example"):
                example = item.get(key)
                if not isinstance(example, dict) or not example.get("input") or not example.get("expected"):
                    fail(f"understanding review missing {key}: {item['requirement_id']}")
            if item["positive_example"]["expected"] == item["negative_example"]["expected"]:
                fail(f"positive and negative examples are indistinguishable: {item['requirement_id']}")
    trace = value["traceability"]
    for key in ("source_to_requirements", "requirement_to_plan", "plan_to_code", "code_to_tests"):
        if not isinstance(trace.get(key), dict): fail(f"missing traceability map: {key}")
    if set(trace["requirement_to_plan"]) != requirement_ids: fail("every requirement needs a plan link")
    plans = {target for targets in trace["requirement_to_plan"].values() for target in targets}
    if not plans or not plans.issubset(trace["plan_to_code"]): fail("every plan item needs a code link")
    code_items = {target for targets in trace["plan_to_code"].values() for target in targets}
    if not code_items.issubset(trace["code_to_tests"]): fail("every meaningful code change needs a test link")
    if value["blocking_issues"] or status in {"COLLECTING", "ANALYZING", "REMEDIATING", "RETHINK_REQUIRED"}:
        if require_ready: fail("readiness is not ready")
    if require_ready and status not in {"READY", "LOCKED"}: fail("readiness is not READY or LOCKED")
    observed = value.get("record_hash")
    if observed and observed != digest(value): fail("readiness record hash mismatch")
    return source_ids, unit_ids, requirement_ids

if command == "verify":
    if len(args) != 1: fail("verify requires readiness JSON")
    value = load(args[0]); source_ids, unit_ids, requirement_ids = validate(value)
    interpretation_count = sum(len(row.get("interpretation_evidence", [])) for row in value["requirements"])
    print(json.dumps({"valid": True, "ready": value["status"] in {"READY", "LOCKED"} and not value["blocking_issues"], "status": value["status"], "version": value["version"], "source_count": len(source_ids), "input_unit_count": len(unit_ids), "requirement_count": len(requirement_ids), "interpretation_evidence_count": interpretation_count}, sort_keys=True))
elif command == "lock":
    if len(args) != 2: fail("lock requires readiness JSON and output JSON")
    value = load(args[0]); validate(value, require_ready=True)
    if value.get("status") != "READY": fail("only READY readiness can be locked")
    locked = dict(value); locked["status"] = "LOCKED"; locked["locked_at"] = dt.datetime.now(dt.timezone.utc).isoformat(); locked["record_hash"] = digest(locked)
    out = pathlib.Path(args[1]);
    if out.exists(): fail("locked readiness output is immutable")
    out.parent.mkdir(parents=True, exist_ok=True); out.write_text(json.dumps(locked, sort_keys=True, indent=2) + "\n")
    print(json.dumps({"valid": True, "status": "LOCKED", "record_hash": locked["record_hash"]}, sort_keys=True))
elif command == "impact":
    if len(args) != 1: fail("impact requires readiness JSON")
    value = load(args[0]); changed = []
    for source in value.get("sources", []):
        path = pathlib.Path(source.get("location", ""))
        if path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest() != source.get("content_hash"):
            changed.append(source.get("id"))
    print(json.dumps({"valid": True, "changed_sources": sorted(filter(None, changed)), "invalidates_readiness": bool(changed)}, sort_keys=True))
elif command == "rethink":
    if len(args) != 2: fail("rethink requires readiness JSON and failure JSON")
    value = load(args[0]); failure = load(args[1]); rule = failure.get("rule", "unknown"); strategy = failure.get("strategy", "unknown"); result = failure.get("result", "unknown")
    fingerprint = hashlib.sha256(f"{rule}|{strategy}|{result}".encode()).hexdigest()
    prior = [row.get("fingerprint") for row in value.get("remediation_epochs", [])]
    print(json.dumps({"valid": True, "fingerprint": fingerprint, "repeated": fingerprint in prior, "next_status": "RETHINK_REQUIRED" if fingerprint in prior else "REMEDIATING"}, sort_keys=True))
else:
    fail("unknown command")
PY
