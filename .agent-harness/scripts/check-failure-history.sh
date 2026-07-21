#!/usr/bin/env bash
set -euo pipefail
history="${1:-}"
[ -n "$history" ] || { echo "Usage: scripts/check-failure-history.sh HISTORY.jsonl" >&2; exit 2; }
python3 - "$history" <<'PY'
import hashlib, json, pathlib, sys
path = pathlib.Path(sys.argv[1])
rows = [json.loads(line) for line in path.read_text().splitlines() if line.strip()] if path.exists() else []
previous = "0" * 64
for index, row in enumerate(rows, 1):
    required = ("history_schema_version", "run_id", "task_id", "risk", "kind", "sanitized_message", "exact_attempt_signature", "stable_failure_family", "comparison_epoch", "rerun_confirmed", "repeatable_count", "threshold", "resolution", "previous_hash", "recorded_at")
    missing = [key for key in required if key not in row]
    if missing:
        raise SystemExit("failure history missing fields: " + ",".join(missing))
    if row.get("history_schema_version") != 1 or row.get("risk") not in {"tiny", "normal", "high_risk"}:
        raise SystemExit("unsupported failure history schema or risk")
    if row.get("threshold") != {"tiny": 2, "normal": 3, "high_risk": 2}[row["risk"]]:
        raise SystemExit("failure threshold does not match risk policy")
    if not all(isinstance(row.get(key), str) and len(row[key]) == 64 and all(char in "0123456789abcdef" for char in row[key]) for key in ("exact_attempt_signature", "stable_failure_family", "comparison_epoch")):
        raise SystemExit("failure signatures must be lowercase SHA-256 digests")
    if not isinstance(row.get("rerun_confirmed"), bool) or not isinstance(row.get("uncertain_external", False), bool):
        raise SystemExit("failure rerun and uncertainty flags are invalid")
    if not isinstance(row.get("repeatable_count"), int) or row["repeatable_count"] < 0:
        raise SystemExit("failure repeatable_count is invalid")
    immediate = row["kind"] in {"policy", "audit_integrity", "unknown_side_effect"} or row.get("uncertain_external") is True
    if immediate and row["resolution"] != "RECOVERY_REQUIRED":
        raise SystemExit("immediate recovery failure has a weaker resolution")
    if not immediate and row["resolution"] == "RETHINK_REQUIRED" and row["repeatable_count"] < row["threshold"]:
        raise SystemExit("failure became RETHINK_REQUIRED before its threshold")
    if row["resolution"] not in {"REMEDIATING", "RETHINK_REQUIRED", "RECOVERY_REQUIRED"}:
        raise SystemExit("unknown failure resolution")
    if row.get("sequence") != index or row.get("previous_hash") != previous:
        raise SystemExit("failure history sequence or predecessor mismatch")
    unsigned = dict(row)
    event_hash = unsigned.pop("event_hash", None)
    expected = hashlib.sha256(previous.encode() + json.dumps(unsigned, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    if event_hash != expected:
        raise SystemExit("failure history hash mismatch")
    previous = event_hash
print("failure_history_valid: true")
print(f"records: {len(rows)}")
PY
