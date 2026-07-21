#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: scripts/spec-lock.sh create|approve|verify ..." >&2
  exit 2
}

command="${1:-}"
shift || true
if [[ "$command" == "create" || "$command" == "approve" ]]; then
  echo "spec-lock authority creation is retired in v3; use the canonical Change Package intake flow" >&2
  exit 64
fi
case "$command" in
  create)
    input="${1:-}"; output="${2:-}"
    [ -f "$input" ] && [ -n "$output" ] || usage
    python3 - "$input" "$output" <<'PY'
import hashlib, json, pathlib, sys
source = pathlib.Path(sys.argv[1])
output = pathlib.Path(sys.argv[2])
value = json.loads(source.read_text())
if not isinstance(value, dict):
    raise SystemExit("specification candidate must be an object")
required = ("task_id", "run_id", "spec_version", "risk_decision_hash")
if any(not value.get(key) for key in required):
    raise SystemExit("candidate must bind task_id, run_id, spec_version, and risk_decision_hash")
if not isinstance(value["risk_decision_hash"], str) or len(value["risk_decision_hash"]) != 64:
    raise SystemExit("risk_decision_hash must be a sha256 identity")
canonical = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n"
digest = hashlib.sha256(canonical.encode()).hexdigest()
record = {"schema_version": 1, "canonicalization_version": 1,
          "kind": "SPEC_CANDIDATE", "spec_hash": digest,
          "previous_spec_hash": None, "canonical_spec": value}
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
print(digest)
PY
    ;;
  approve)
    candidate="${1:-}"; approval="${2:-}"; output="${3:-}"
    [ -f "$candidate" ] && [ -f "$approval" ] && [ -n "$output" ] || usage
    python3 - "$candidate" "$approval" "$output" <<'PY'
import datetime as dt, hashlib, json, pathlib, sys
cand = json.loads(pathlib.Path(sys.argv[1]).read_text())
approval = json.loads(pathlib.Path(sys.argv[2]).read_text())
candidate_hash = cand.get("spec_hash", "")
if cand.get("kind") != "SPEC_CANDIDATE" or len(candidate_hash) != 64:
    raise SystemExit("invalid specification candidate")
if approval.get("action") != "LOCK_SPECIFICATION" or approval.get("candidate_hash") != candidate_hash:
    raise SystemExit("approval must bind to the exact candidate hash")
if approval.get("approved") is not True:
    raise SystemExit("specification lock requires explicit human approval")
canonical = cand.get("canonical_spec", {})
for key in ("task_id", "run_id", "risk_decision_hash"):
    if approval.get(key) != canonical.get(key):
        raise SystemExit(f"approval must bind to candidate {key}")
if not approval.get("human_id") or not approval.get("approved_at") or not approval.get("expires_at"):
    raise SystemExit("approval requires human_id, approved_at, and expires_at")
try:
    expires = dt.datetime.fromisoformat(str(approval["expires_at"]).replace("Z", "+00:00"))
except ValueError:
    raise SystemExit("approval expires_at must be an ISO-8601 timestamp")
if expires <= dt.datetime.now(dt.timezone.utc):
    raise SystemExit("approval has expired")
record = {"schema_version": 1, "canonicalization_version": 1,
          "kind": "SPEC_LOCK", "spec_hash": candidate_hash,
          "previous_spec_hash": cand.get("previous_spec_hash"),
          "candidate_hash": candidate_hash, "approval": approval,
          "canonical_spec": cand["canonical_spec"], "task_id": canonical["task_id"],
          "run_id": canonical["run_id"], "spec_version": canonical["spec_version"],
          "risk_decision_hash": canonical["risk_decision_hash"]}
out = pathlib.Path(sys.argv[3])
if out.exists():
    raise SystemExit("specification lock is immutable")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
PY
    ;;
  verify)
    directory="${1:-}"
    [ -d "$directory" ] || usage
    python3 - "$directory" <<'PY'
import hashlib, json, pathlib, sys
records = sorted(pathlib.Path(sys.argv[1]).glob("*.json"))
previous = None
seen = set()
candidate_hash = None
for path in records:
    data = json.loads(path.read_text())
    if data.get("kind") not in {"SPEC_CANDIDATE", "SPEC_LOCK"}:
        continue
    if data.get("schema_version") != 1 or data.get("canonicalization_version") != 1:
        raise SystemExit(f"unsupported specification artifact: {path}")
    digest = data.get("spec_hash", "")
    if len(digest) != 64 or (digest in seen and not (data.get("kind") == "SPEC_LOCK" and digest == candidate_hash)):
        raise SystemExit(f"invalid or duplicate specification hash: {path}")
    canonical = json.dumps(data.get("canonical_spec"), sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n"
    if hashlib.sha256(canonical.encode()).hexdigest() != digest:
        raise SystemExit(f"specification hash mismatch: {path}")
    if data.get("kind") == "SPEC_CANDIDATE" and data.get("previous_spec_hash") != previous:
        raise SystemExit(f"specification chain mismatch: {path}")
    if data.get("kind") == "SPEC_LOCK":
        if candidate_hash is None:
            candidate_hash = digest
            seen.add(digest)
        elif digest != candidate_hash:
            raise SystemExit(f"lock does not immediately follow its candidate: {path}")
        approval = data.get("approval", {})
        if approval.get("candidate_hash") != digest:
            raise SystemExit(f"approval hash mismatch: {path}")
        canonical_spec = data.get("canonical_spec", {})
        if any(data.get(key) != canonical_spec.get(key) for key in ("task_id", "run_id", "spec_version", "risk_decision_hash")):
            raise SystemExit(f"lock binding mismatch: {path}")
        if approval.get("approved") is not True or any(approval.get(key) != canonical_spec.get(key) for key in ("task_id", "run_id", "risk_decision_hash")):
            raise SystemExit(f"invalid lock approval binding: {path}")
    else:
        candidate_hash = digest
        seen.add(digest)
        previous = digest
print(json.dumps({"valid": True, "count": len(records), "head": previous}, sort_keys=True))
PY
    ;;
  *) usage ;;
esac
