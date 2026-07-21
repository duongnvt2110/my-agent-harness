#!/usr/bin/env bash
set -euo pipefail
history="${1:-}"
failure="${2:-}"
[ -n "$history" ] && [ -n "$failure" ] || { echo "Usage: scripts/record-failure.sh HISTORY.jsonl FAILURE.json" >&2; exit 2; }
python3 - "$history" "$failure" <<'PY'
import datetime as dt
import hashlib
import json
import pathlib
import re
import sys
import os

history = pathlib.Path(sys.argv[1])
source = json.loads(pathlib.Path(sys.argv[2]).read_text())
required = ("run_id", "task_id", "risk", "kind", "message", "spec_hash", "policy_hash", "command_hash", "environment_hash", "patch_hash")
missing = [key for key in required if not source.get(key)]
if missing:
    raise SystemExit("missing failure fields: " + ",".join(missing))
sanitized = re.sub(r"/(?:[^ ]+/)+", "<path>", str(source["message"]))
sanitized = re.sub(r"\b[0-9a-fA-F]{8,}\b", "<id>", sanitized)
sanitized = re.sub(r"\b\d+\b", "<n>", sanitized)
sanitized = re.sub(r"\s+", " ", sanitized).strip()[:500]
epoch_data = {key: source[key] for key in ("spec_hash", "policy_hash", "command_hash", "environment_hash", "patch_hash")}
epoch = hashlib.sha256(json.dumps(epoch_data, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
family_data = {"kind": source["kind"], "message": sanitized, "command_hash": source["command_hash"], "environment_hash": source["environment_hash"], "patch_hash": source["patch_hash"]}
family = hashlib.sha256(json.dumps(family_data, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
attempt_data = dict(family_data)
attempt_data.update({"run_id": source["run_id"], "task_id": source["task_id"], "session_id": source.get("session_id", ""), "rerun_index": source.get("rerun_index", 0)})
attempt = hashlib.sha256(json.dumps(attempt_data, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
rows = [json.loads(line) for line in history.read_text().splitlines() if line.strip()] if history.exists() else []
repeatable = sum(1 for row in rows if row.get("stable_failure_family") == family and row.get("comparison_epoch") == epoch and row.get("rerun_confirmed") is True) + (1 if source.get("rerun_confirmed") is True else 0)
threshold = {"tiny": 2, "normal": 3, "high_risk": 2}.get(source["risk"], 2)
immediate = source["kind"] in {"policy", "audit_integrity", "unknown_side_effect"} or source.get("uncertain_external") is True
event = {"history_schema_version": 1, "sequence": len(rows) + 1, "run_id": source["run_id"], "task_id": source["task_id"], "risk": source["risk"], "kind": source["kind"], "sanitized_message": sanitized, "exact_attempt_signature": attempt, "stable_failure_family": family, "comparison_epoch": epoch, "rerun_confirmed": bool(source.get("rerun_confirmed", False)), "uncertain_external": bool(source.get("uncertain_external", False)), "repeatable_count": repeatable, "threshold": threshold, "resolution": "RECOVERY_REQUIRED" if immediate else ("RETHINK_REQUIRED" if repeatable >= threshold else "REMEDIATING"), "previous_hash": rows[-1].get("event_hash", "0" * 64) if rows else "0" * 64, "recorded_at": dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")}
event["event_hash"] = hashlib.sha256(event["previous_hash"].encode() + json.dumps(event, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
history.parent.mkdir(parents=True, exist_ok=True)
with history.open("a") as handle:
    handle.write(json.dumps(event, sort_keys=True, separators=(",", ":")) + "\n")
    handle.flush()
    os.fsync(handle.fileno())
print(json.dumps({"failure_recorded": True, "exact_attempt_signature": attempt, "stable_failure_family": family, "comparison_epoch": epoch, "resolution": event["resolution"], "repeatable_count": repeatable}, sort_keys=True))
PY
