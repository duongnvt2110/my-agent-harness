#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-baseline-snapshot.sh --task <task_id> [--snapshot <file>]

Validate a baseline snapshot file.
EOF
}

task_id=""
snapshot_path=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    --snapshot)
      snapshot_path="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$task_id" ] || fail "Missing --task <task_id>"
snapshot_path="${snapshot_path:-$(evidence_dir)/baseline-snapshot.json}"
[ -f "$snapshot_path" ] || fail "Missing baseline snapshot: $snapshot_path"

python3 - "$task_id" "$snapshot_path" <<'PY'
import json
import hashlib
import pathlib
import re
import sys

task_id = sys.argv[1]
snapshot_path = pathlib.Path(sys.argv[2])
data = json.loads(snapshot_path.read_text())

if data.get("task_id") != task_id:
    raise SystemExit(f"Snapshot task_id mismatch: {data.get('task_id')!r} != {task_id!r}")
if data.get("mode") != "snapshot":
    raise SystemExit(f"Snapshot mode must be 'snapshot', got {data.get('mode')!r}")
snapshot_hash = data.get("snapshot_hash")
if not isinstance(snapshot_hash, str) or not re.fullmatch(r"[0-9a-f]{64}", snapshot_hash):
    raise SystemExit("Snapshot snapshot_hash must be a sha256 identity")
unsigned = dict(data)
unsigned.pop("snapshot_hash", None)
expected_hash = hashlib.sha256(json.dumps(unsigned, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()).hexdigest()
if snapshot_hash != expected_hash:
    raise SystemExit("Snapshot content hash mismatch")
files = data.get("files")
if not isinstance(files, list) or not files:
    raise SystemExit("Snapshot files array must be a non-empty list")

seen_paths = set()
ordered_paths = []
for idx, entry in enumerate(files, start=1):
    if not isinstance(entry, dict):
        raise SystemExit(f"Snapshot file entry {idx} must be an object")
    path = entry.get("path")
    sha256 = entry.get("sha256")
    size = entry.get("size")
    entry_type = entry.get("type", "file")
    if not path or not isinstance(path, str):
        raise SystemExit(f"Snapshot file entry {idx} missing path")
    if path.startswith("/"):
        raise SystemExit(f"Snapshot file entry {idx} path must be relative: {path}")
    if not sha256 or not isinstance(sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", sha256):
        raise SystemExit(f"Snapshot file entry {idx} has invalid sha256: {sha256!r}")
    if not isinstance(size, int) or size < 0:
        raise SystemExit(f"Snapshot file entry {idx} has invalid size: {size!r}")
    if entry_type not in {"file", "symlink"}:
        raise SystemExit(f"Snapshot file entry {idx} has invalid type: {entry_type!r}")
    if path in seen_paths:
        raise SystemExit(f"Snapshot contains duplicate path: {path}")
    seen_paths.add(path)
    ordered_paths.append(path)

if ordered_paths != sorted(ordered_paths):
    raise SystemExit("Snapshot files must be sorted by path")

print("Baseline snapshot checks passed.")
PY

echo "Baseline snapshot checks passed."
