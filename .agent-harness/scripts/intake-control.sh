#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HARNESS_SCRIPT_DIR="$script_dir"

usage() {
  cat >&2 <<'EOF'
Usage:
  scripts/intake-control.sh create REQUEST.json PACKAGE.json
  scripts/intake-control.sh understand PACKAGE.json
  scripts/intake-control.sh clarify PACKAGE.json QUESTIONS.json OUTPUT.json
  scripts/intake-control.sh answer PACKAGE.json ANSWERS.json OUTPUT.json
  scripts/intake-control.sh approve PACKAGE.json APPROVAL.json OUTPUT.json
  scripts/intake-control.sh bind LOCKED_PACKAGE.json STATE.json
  scripts/intake-control.sh verify PACKAGE.json
EOF
  exit 2
}

command="${1:-}"
shift || true
case "$command" in
  create|understand|clarify|answer|approve|bind|verify) ;;
  *) usage ;;
esac

python3 - "$command" "$@" <<'PY'
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import uuid

command = sys.argv[1]
args = sys.argv[2:]

def fail(message: str) -> None:
    raise SystemExit(message)

def load(path: str) -> dict:
    try:
        value = json.loads(pathlib.Path(path).read_text())
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"invalid JSON input {path}: {exc}")
    if not isinstance(value, dict):
        fail(f"JSON input must be an object: {path}")
    return value

def canonical(value: dict) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n"

def package_hash(value: dict) -> str:
    body = dict(value)
    body.pop("package_hash", None)
    return hashlib.sha256(canonical(body).encode()).hexdigest()

def freeze_sources(value: dict, package_path: str) -> None:
    package = pathlib.Path(package_path)
    snapshot_dir = package.parent / f"{package.name}.sources"
    if snapshot_dir.exists():
        fail(f"source snapshot directory is immutable and already exists: {snapshot_dir}")
    staging_dir = package.parent / f".{package.name}.sources.{uuid.uuid4().hex}.tmp"
    staging_dir.mkdir(parents=True, exist_ok=False)
    frozen = []
    committed = False
    def fsync_directory(path: pathlib.Path) -> None:
        flags = os.O_RDONLY
        if hasattr(os, "O_DIRECTORY"):
            flags |= os.O_DIRECTORY
        descriptor = os.open(path, flags)
        try:
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
    try:
        for index, source in enumerate(value["sources"], 1):
            if not isinstance(source, dict):
                fail("each source must be an object")
            payload = None
            capture_kind = "supplied_payload"
            location = str(source.get("location", ""))
            remote = location.startswith(("http://", "https://", "mcp://"))
            if remote:
                if not source.get("retrieved_at") or not (source.get("request") or source.get("query")):
                    fail(f"remote source {source.get('id', index)} requires request/query and retrieved_at capture metadata")
                if source.get("retrieval_error") and source.get("authority") == "authoritative":
                    fail(f"authoritative source {source.get('id', index)} has an uncaptured retrieval error")
            if "content" in source:
                payload = source["content"]
            elif "response" in source:
                payload = source["response"]
                capture_kind = "captured_response"
            else:
                candidate = pathlib.Path(location)
                if not remote and candidate.is_file():
                    payload = candidate.read_bytes()
                    capture_kind = "local_file"
            if payload is None:
                fail(f"source {source.get('id', index)} has no capturable content")
            if isinstance(payload, bytes):
                raw = payload
            elif isinstance(payload, str):
                raw = payload.encode("utf-8")
            else:
                raw = canonical(payload).encode("utf-8")
            digest = hashlib.sha256(raw).hexdigest()
            if source.get("response_hash") and source["response_hash"] != digest:
                fail(f"source {source.get('id', index)} response hash does not match captured response")
            source_id = str(source["id"])
            safe_id = "".join(char if char.isalnum() or char in "-_" else "_" for char in source_id)
            snapshot = staging_dir / f"{index:04d}-{safe_id}.bin"
            snapshot.write_bytes(raw)
            frozen_source = dict(source)
            frozen_source.pop("content", None)
            frozen_source.pop("response", None)
            frozen_source["snapshot_path"] = str((snapshot_dir / snapshot.name).relative_to(package.parent))
            frozen_source["content_hash"] = digest
            if remote:
                frozen_source["response_hash"] = digest
            frozen_source["capture_kind"] = capture_kind
            frozen.append(frozen_source)
        os.replace(staging_dir, snapshot_dir)
        committed = True
        fsync_directory(package.parent)
    except BaseException:
        import shutil
        shutil.rmtree(staging_dir, ignore_errors=True)
        if committed:
            shutil.rmtree(snapshot_dir, ignore_errors=True)
        raise
    value["sources"] = frozen
    value["source_snapshot"] = {"directory": str(snapshot_dir.relative_to(package.parent)), "immutable": True}

def write_immutable(path: str, value: dict) -> None:
    target = pathlib.Path(path)
    if target.exists():
        fail(f"output is immutable and already exists: {path}")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(value, sort_keys=True, indent=2) + "\n")

required_sections = (
    "goal", "business_context", "current_behavior", "target_behavior",
    "business_rules", "architecture_boundary", "data_ownership",
    "integration_boundaries", "permissions", "acceptance_criteria",
    "testable_examples", "out_of_scope", "blocking_unknowns",
    "assumptions", "risks", "verification_expectations", "sources",
    "requirements", "traceability",
)

def validate_package(value: dict, *, ready: bool = False, package_path: str | None = None) -> None:
    if value.get("kind") != "CHANGE_PACKAGE" or value.get("schema_version") != 1:
        fail("invalid change package")
    if value.get("status") not in {"UNDER_REVIEW", "CLARIFICATION_REQUIRED", "SPEC_LOCKED"}:
        fail("invalid change package status")
    for key in required_sections:
        if key not in value:
            fail(f"change package is missing {key}")
    for key in ("task_id", "run_id", "spec_version", "risk_decision_hash"):
        if not value.get(key):
            fail(f"change package is missing {key}")
    if not isinstance(value["risk_decision_hash"], str) or len(value["risk_decision_hash"]) != 64:
        fail("risk_decision_hash must be a sha256 identity")
    if not isinstance(value["acceptance_criteria"], list) or not value["acceptance_criteria"]:
        fail("acceptance_criteria must be a non-empty list")
    if not isinstance(value["requirements"], list) or not value["requirements"]:
        fail("requirements must be a non-empty list")
    if any(not isinstance(row, dict) or not row.get("id") for row in value["requirements"]):
        fail("every requirement must have a stable id")
    if any(not isinstance(row, dict) or not row.get("id") for row in value["business_rules"]):
        fail("every business rule must have a stable id")
    if any(not isinstance(row, dict) or not row.get("id") for row in value["acceptance_criteria"]):
        fail("every acceptance criterion must have a stable id")
    requirement_ids = {row["id"] for row in value["requirements"]}
    rule_ids = {row["id"] for row in value["business_rules"]}
    acceptance_ids = {row["id"] for row in value["acceptance_criteria"]}
    if len(requirement_ids) != len(value["requirements"]):
        fail("requirement IDs must be unique")
    if len(rule_ids) != len(value["business_rules"]):
        fail("business rule IDs must be unique")
    if len(acceptance_ids) != len(value["acceptance_criteria"]):
        fail("acceptance criterion IDs must be unique")
    source_ids = {source.get("id") for source in value["sources"] if isinstance(source, dict)}
    traceability = value["traceability"]
    if not isinstance(traceability, dict):
        fail("traceability must be an object")
    for key in ("source_to_requirements", "requirement_to_rules", "rule_to_acceptance", "acceptance_to_evidence"):
        if not isinstance(traceability.get(key), dict) or any(not isinstance(links, list) or not links for links in traceability[key].values()):
            fail(f"traceability requires non-empty {key} links")
    mappings = {
        "source_to_requirements": (source_ids, requirement_ids),
        "requirement_to_rules": (requirement_ids, rule_ids),
        "rule_to_acceptance": (rule_ids, acceptance_ids),
        "acceptance_to_evidence": (acceptance_ids, None),
    }
    for key, (known_keys, known_values) in mappings.items():
        mapping = traceability[key]
        if set(mapping) - known_keys:
            fail(f"traceability {key} references unknown source or contract IDs")
        if known_values is not None and any(link not in known_values for links in mapping.values() for link in links):
            fail(f"traceability {key} references unknown target IDs")
        if known_keys - set(mapping):
            fail(f"traceability {key} does not cover every normative ID")
    if not isinstance(value["sources"], list) or not value["sources"]:
        fail("sources must be a non-empty list")
    source_ids_seen = set()
    for source in value["sources"]:
        if not isinstance(source, dict) or not all(source.get(k) for k in ("id", "type", "location", "authority")):
            fail("each source requires id, type, location, and authority")
        if source["id"] in source_ids_seen:
            fail("source IDs must be unique")
        source_ids_seen.add(source["id"])
        if "classification" in source:
            if source["classification"] not in {"used", "irrelevant", "blocked"}:
                fail(f"invalid source classification: {source['id']}")
            if source["classification"] != "used" and not source.get("reason"):
                fail(f"source classification requires a reason: {source['id']}")
            if source["classification"] == "blocked":
                fail(f"blocked source prevents readiness: {source['id']}")
        units = source.get("units")
        if units is not None:
            if not isinstance(units, list) or not units:
                fail(f"source units must be a non-empty list: {source['id']}")
            unit_ids = set()
            for unit in units:
                if not isinstance(unit, dict) or not unit.get("id") or unit["id"] in unit_ids:
                    fail(f"source units must have unique IDs: {source['id']}")
                if unit.get("classification") not in {"used", "irrelevant", "blocked"}:
                    fail(f"source unit requires terminal classification: {unit.get('id')}")
                if unit["classification"] != "used" and not unit.get("reason"):
                    fail(f"source unit classification requires a reason: {unit.get('id')}")
                if unit["classification"] == "blocked":
                    fail(f"blocked source unit prevents readiness: {unit.get('id')}")
                unit_ids.add(unit["id"])
    if not isinstance(value["blocking_unknowns"], list):
        fail("blocking_unknowns must be a list")
    if ready and value["blocking_unknowns"]:
        fail("blocking unknowns must be empty before specification lock")
    observed = value.get("package_hash")
    if not isinstance(observed, str) or len(observed) != 64 or package_hash(value) != observed:
        fail("change package hash mismatch")
    if value["status"] == "SPEC_LOCKED":
        approval = value.get("approval")
        if not isinstance(approval, dict) or approval.get("approved") is not True:
            fail("locked package requires explicit human approval")
        if approval.get("candidate_hash") != value.get("locked_from_hash"):
            fail("locked package approval hash mismatch")
        for key in ("task_id", "run_id", "risk_decision_hash"):
            if approval.get(key) != value.get(key):
                fail(f"locked approval must bind to {key}")
        if approval.get("authority_status") != "PROTECTED":
            fail("locked approval requires protected authority provenance")
        script_dir = pathlib.Path(os.environ.get("HARNESS_SCRIPT_DIR", pathlib.Path(__file__).parent))
        sys.path.insert(0, str(script_dir))
        from provenance import verify
        if not verify(approval):
            fail("locked approval provenance is invalid")
    if package_path:
        package_path = pathlib.Path(package_path)
        snapshot = value.get("source_snapshot")
        if not isinstance(snapshot, dict) or not snapshot.get("directory"):
            fail("source snapshot manifest is missing")
        snapshot_dir_raw = package_path.parent / snapshot["directory"]
        if snapshot_dir_raw.is_symlink():
            fail("source snapshot directory is missing")
        snapshot_dir = snapshot_dir_raw.resolve()
        try:
            snapshot_dir.relative_to(package_path.parent.resolve())
        except ValueError:
            fail("source snapshot directory escapes package parent")
        if not snapshot_dir.is_dir():
            fail("source snapshot directory is missing")
        for source in value["sources"]:
            snapshot_path_raw = package_path.parent / source["snapshot_path"]
            if snapshot_path_raw.is_symlink():
                fail(f"source snapshot file is missing: {source['snapshot_path']}")
            snapshot_path = snapshot_path_raw.resolve()
            try:
                snapshot_path.relative_to(snapshot_dir)
            except ValueError:
                fail(f"source snapshot path escapes snapshot directory: {source['snapshot_path']}")
            if not snapshot_path.is_file():
                fail(f"source snapshot file is missing: {source['snapshot_path']}")
            if hashlib.sha256(snapshot_path.read_bytes()).hexdigest() != source.get("content_hash"):
                fail(f"source snapshot hash mismatch: {source['snapshot_path']}")

if command == "create":
    if len(args) != 2:
        fail("create requires REQUEST.json and PACKAGE.json")
    request = load(args[0])
    package = {
        "schema_version": 1,
        "kind": "CHANGE_PACKAGE",
        "package_id": str(uuid.uuid4()),
        "status": "UNDER_REVIEW",
        "created_at": dt.datetime.now(dt.timezone.utc).isoformat(),
    }
    package.update(request)
    freeze_sources(package, args[1])
    package["package_hash"] = package_hash(package)
    validate_package(package)
    write_immutable(args[1], package)
    print(json.dumps({"valid": True, "status": package["status"], "package_hash": package["package_hash"]}, sort_keys=True))
elif command == "verify":
    if len(args) != 1:
        fail("verify requires PACKAGE.json")
    value = load(args[0])
    validate_package(value, package_path=args[0])
    print(json.dumps({"valid": True, "status": value["status"], "package_hash": value["package_hash"]}, sort_keys=True))
elif command == "understand":
    if len(args) != 1:
        fail("understand requires PACKAGE.json")
    value = load(args[0])
    validate_package(value)
    ready = not value["blocking_unknowns"]
    result = {"valid": True, "ready": ready, "status": value["status"], "package_hash": value["package_hash"], "blocking_unknowns": value["blocking_unknowns"]}
    print(json.dumps(result, sort_keys=True))
    if not ready:
        raise SystemExit(78)
elif command == "clarify":
    if len(args) != 3:
        fail("clarify requires PACKAGE.json, QUESTIONS.json, and OUTPUT.json")
    value = load(args[0]); questions = load(args[1])
    validate_package(value)
    rows = questions.get("questions")
    if not isinstance(rows, list) or not rows:
        fail("questions must be a non-empty list")
    updated = dict(value)
    updated["status"] = "CLARIFICATION_REQUIRED"
    updated["clarification"] = {"questions": rows, "created_at": dt.datetime.now(dt.timezone.utc).isoformat()}
    updated["blocking_unknowns"] = rows
    updated.pop("package_hash", None)
    updated["package_hash"] = package_hash(updated)
    write_immutable(args[2], updated)
    print(json.dumps({"valid": True, "status": updated["status"], "package_hash": updated["package_hash"]}, sort_keys=True))
elif command == "answer":
    if len(args) != 3:
        fail("answer requires PACKAGE.json, ANSWERS.json, and OUTPUT.json")
    value = load(args[0]); answers = load(args[1])
    validate_package(value)
    rows = answers.get("answers")
    if not isinstance(rows, list) or not rows:
        fail("answers must be a non-empty list")
    prior_questions = (value.get("clarification") or {}).get("questions", [])
    question_ids = {row.get("id") for row in prior_questions if isinstance(row, dict) and row.get("id")}
    answer_ids = {row.get("question_id") for row in rows if isinstance(row, dict) and row.get("question_id")}
    if not question_ids or answer_ids - question_ids:
        fail("answers must reference existing clarification question IDs")
    unanswered = sorted(question_ids - answer_ids)
    updated = dict(value)
    updated["status"] = "CLARIFICATION_REQUIRED" if unanswered else "UNDER_REVIEW"
    updated["human_answers"] = rows
    updated["blocking_unknowns"] = unanswered
    updated.pop("package_hash", None)
    updated["package_hash"] = package_hash(updated)
    write_immutable(args[2], updated)
    print(json.dumps({"valid": True, "ready": not unanswered, "status": updated["status"], "package_hash": updated["package_hash"], "unanswered": unanswered}, sort_keys=True))
elif command == "approve":
    if len(args) != 3:
        fail("approve requires PACKAGE.json, APPROVAL.json, OUTPUT.json")
    value = load(args[0]); approval = load(args[1])
    validate_package(value, ready=True, package_path=args[0])
    if approval.get("action") != "LOCK_SPECIFICATION" or approval.get("approved") is not True:
        fail("approval must explicitly lock the specification")
    if not approval.get("human_id") or not approval.get("approved_at") or not approval.get("expires_at"):
        fail("approval requires human_id, approved_at, and expires_at")
    try:
        expires = dt.datetime.fromisoformat(str(approval["expires_at"]).replace("Z", "+00:00"))
    except ValueError:
        fail("approval expires_at must be ISO-8601")
    if expires <= dt.datetime.now(dt.timezone.utc):
        fail("approval has expired")
    if approval.get("candidate_hash") != value["package_hash"]:
        fail("approval candidate_hash must match the package")
    for key in ("task_id", "run_id", "risk_decision_hash"):
        if approval.get(key) != value.get(key):
            fail(f"approval must bind to {key}")
    if approval.get("authority_status") != "PROTECTED":
        fail("approval requires protected authority provenance")
    script_dir = pathlib.Path(os.environ.get("HARNESS_SCRIPT_DIR", pathlib.Path(__file__).parent))
    sys.path.insert(0, str(script_dir))
    from provenance import verify
    if not verify(approval):
        fail("approval provenance is invalid")
    approval = dict(approval)
    locked = dict(value)
    locked["status"] = "SPEC_LOCKED"
    locked["locked_from_hash"] = value["package_hash"]
    locked["approval"] = approval
    locked.pop("package_hash", None)
    locked["package_hash"] = package_hash(locked)
    write_immutable(args[2], locked)
    print(json.dumps({"valid": True, "status": locked["status"], "package_hash": locked["package_hash"]}, sort_keys=True))
elif command == "bind":
    if len(args) != 2:
        fail("bind requires LOCKED_PACKAGE.json and STATE.json")
    value = load(args[0])
    validate_package(value, ready=True, package_path=args[0])
    approval = value["approval"]
    try:
        lock_expires = dt.datetime.fromisoformat(str(approval["expires_at"]).replace("Z", "+00:00"))
    except (KeyError, ValueError):
        fail("locked approval expires_at must be ISO-8601")
    if lock_expires <= dt.datetime.now(dt.timezone.utc):
        fail("locked approval has expired before lifecycle binding")
    state_path = pathlib.Path(args[1])
    if state_path.name != "state.json":
        fail("binding requires a state.json lifecycle authority")
    try:
        state = json.loads(state_path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"invalid state.json: {exc}")
    if state.get("task_id") != value["task_id"] or state.get("run_id") != value["run_id"]:
        fail("package and state task/run identity mismatch")
    if state.get("state") == "SPEC_LOCKED":
        if state.get("spec_hash") == value["package_hash"]:
            print(json.dumps({"valid": True, "idempotent": True, "status": "SPEC_LOCKED", "package_hash": value["package_hash"]}, sort_keys=True))
            raise SystemExit(0)
        fail("state is already SPEC_LOCKED with a different package hash")
    command_line = ["bash", str(pathlib.Path(os.environ.get("HARNESS_SCRIPT_DIR", pathlib.Path(__file__).parent)) / "transition-state"), "--state", str(state_path), "--to", "SPEC_LOCKED", "--spec-hash", value["package_hash"], "--apply", "--json"]
    completed = subprocess.run(command_line, capture_output=True, text=True)
    if completed.returncode != 0:
        fail(completed.stderr.strip() or completed.stdout.strip() or "SPEC_LOCKED transition failed")
    try:
        result = json.loads(completed.stdout)
    except json.JSONDecodeError:
        fail("transition-state returned invalid JSON")
    if not result.get("applied"):
        fail("SPEC_LOCKED transition was not applied")
    bound = json.loads(state_path.read_text())
    if bound.get("spec_hash") != value["package_hash"]:
        fail("state specification hash does not match the locked package")
    print(json.dumps({"valid": True, "status": bound["state"], "package_hash": bound["spec_hash"], "event_sequence": bound.get("event_sequence")}, sort_keys=True))
PY
