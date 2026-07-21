#!/usr/bin/env bash
set -euo pipefail

history="${1:-}"
output="${2:-}"
[ -n "$history" ] && [ -n "$output" ] || {
  echo "Usage: scripts/rethink.sh FAILURE_HISTORY.jsonl RETHINK.json" >&2
  exit 2
}

python3 - "$history" "$output" <<'PY'
from __future__ import annotations
import hashlib
import json
import os
import pathlib
import sys

history_path = pathlib.Path(sys.argv[1])
output_path = pathlib.Path(sys.argv[2])
rows = [json.loads(line) for line in history_path.read_text(encoding="utf-8").splitlines() if line.strip()] if history_path.exists() else []
if not rows:
    raise SystemExit("rethink requires failure history")
latest = rows[-1]
if latest.get("resolution") != "RETHINK_REQUIRED":
    raise SystemExit("rethink requires the latest failure resolution to be RETHINK_REQUIRED")
seed = f"{latest.get('stable_failure_family')}:{latest.get('sequence')}:rethink"
rethink_id = hashlib.sha256(seed.encode()).hexdigest()
result = {
    "schema_version": 1,
    "rethink_id": rethink_id,
    "task_id": latest.get("task_id"),
    "run_id": latest.get("run_id"),
    "trigger": "RETHINK_REQUIRED",
    "prior_failure_family": latest.get("stable_failure_family"),
    "prior_attempt_signature": latest.get("exact_attempt_signature"),
    "strategy_revision": latest.get("repeatable_count", 0) + 1,
    "action": "CONTINUE_WITH_NEW_STRATEGY",
    "next_state": "REMEDIATING",
    "failure_history_preserved": True,
    "requires_human_review": False,
    "evidence": str(history_path),
}
output_path.parent.mkdir(parents=True, exist_ok=True)
temporary = output_path.with_suffix(output_path.suffix + ".tmp")
temporary.write_text(json.dumps(result, sort_keys=True, indent=2) + "\n", encoding="utf-8")
os.replace(temporary, output_path)
print(json.dumps({"decision": "CONTINUE", "rethink_id": rethink_id, "strategy_revision": result["strategy_revision"], "requires_human_review": False}, sort_keys=True))
PY
