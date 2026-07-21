#!/usr/bin/env bash
set -euo pipefail

checkpoint="${1:-}"
root="${2:-}"
[ -n "$checkpoint" ] && [ -n "$root" ] || { echo "Usage: scripts/restore-checkpoint.sh CHECKPOINT EMPTY_ROOT" >&2; exit 2; }
[ -d "$root" ] || { echo "restore destination must be a directory" >&2; exit 1; }
"$(dirname "$0")/verify-checkpoint.sh" "$checkpoint" - >/dev/null
journal="$root/.checkpoint-restore-journal.json"
python3 - "$checkpoint" "$root" "$journal" <<'PY'
from __future__ import annotations
import json, pathlib, shutil, sys, time

checkpoint = pathlib.Path(sys.argv[1]).resolve()
root = pathlib.Path(sys.argv[2]).resolve()
journal = pathlib.Path(sys.argv[3])
manifest = json.loads((checkpoint / "manifest.json").read_text())
rows = manifest.get("files", [])
if journal.exists():
    state = json.loads(journal.read_text())
    if state.get("checkpoint_id") != manifest.get("checkpoint_id"):
        raise SystemExit("restore journal checkpoint mismatch")
else:
    existing = [path for path in root.iterdir() if path.name != journal.name]
    if existing:
        raise SystemExit("restore destination must be empty and user work must be preserved")
    state = {"schema_version": 1, "checkpoint_id": manifest.get("checkpoint_id"), "status": "PENDING", "completed": []}
    journal.write_text(json.dumps(state, sort_keys=True, indent=2) + "\n")
for row in rows:
    if row["path"] in state["completed"]:
        continue
    source = checkpoint / "files" / row["path"]
    target = root / row["path"]
    target.parent.mkdir(parents=True, exist_ok=True)
    if row["type"] == "symlink":
        target.symlink_to(source.readlink())
    else:
        shutil.copy2(source, target)
    state["completed"].append(row["path"])
    state["updated_epoch"] = time.time()
    journal.write_text(json.dumps(state, sort_keys=True, indent=2) + "\n")
state["status"] = "COMPLETE"
journal.write_text(json.dumps(state, sort_keys=True, indent=2) + "\n")
PY
"$(dirname "$0")/verify-checkpoint.sh" "$checkpoint" "$root"
echo "checkpoint_restored: true"
