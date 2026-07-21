#!/usr/bin/env bash
set -euo pipefail

ledger="${1:-}"
[ -n "$ledger" ] || { echo "Usage: scripts/check-remediation-epochs.sh EPOCHS.jsonl" >&2; exit 2; }
python3 - "$ledger" <<'PY'
import hashlib, json, pathlib, sys
path = pathlib.Path(sys.argv[1])
rows = [json.loads(line) for line in path.read_text().splitlines() if line.strip()] if path.exists() else []
previous = "0" * 64
for index, row in enumerate(rows, 1):
    required = ("schema_version", "sequence", "epoch_number", "task_id", "run_id", "risk", "reason", "budget_exhausted", "budget_reset", "failure_history_hash", "failure_history_preserved", "requires_human_review", "previous_hash", "created_at", "epoch_hash")
    missing = [key for key in required if key not in row]
    if missing:
        raise SystemExit("remediation epoch missing: " + ",".join(missing))
    if row["schema_version"] != 1 or row["sequence"] != index or row["epoch_number"] != index:
        raise SystemExit("remediation epoch sequence is invalid")
    if row["reason"] != "BUDGET_EXHAUSTED" or row["budget_exhausted"] is not True or row["budget_reset"] is not True:
        raise SystemExit("remediation epoch reason or budget reset is invalid")
    if row["failure_history_preserved"] is not True or row["requires_human_review"] is not False:
        raise SystemExit("remediation epoch weakens autonomy or resets history")
    if row["previous_hash"] != previous:
        raise SystemExit("remediation epoch predecessor mismatch")
    unsigned = dict(row)
    observed = unsigned.pop("epoch_hash")
    expected = hashlib.sha256(previous.encode() + json.dumps(unsigned, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    if observed != expected:
        raise SystemExit("remediation epoch hash mismatch")
    previous = observed
print(f"remediation_epochs_valid: true\nrecords: {len(rows)}")
PY
