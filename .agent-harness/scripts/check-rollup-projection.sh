#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

progress="${1:-}"
task_store="${2:-${TASK_STORE:-docs/tasks/tasks.jsonl}}"
story_registry="${3:-}"
[ -n "$progress" ] && [ -n "$story_registry" ] || fail "Usage: scripts/check-rollup-projection.sh PROGRESS.md TASKS.jsonl STORIES.jsonl"

python3 - "$progress" "$task_store" "$story_registry" <<'PY'
import hashlib
import pathlib
import re
import sys

progress, task_store, story_registry = map(pathlib.Path, sys.argv[1:])
text = progress.read_text()
sections = re.findall(r"## Update\n(.*?)(?=\n## Update|\Z)", text, re.S)
if not sections:
    raise SystemExit("rollup has no update section")
latest = sections[-1]
def field(name):
    match = re.search(rf"^- {re.escape(name)}:\s*(.+)$", latest, re.M)
    return match.group(1).strip() if match else ""
if field("projection_schema_version") != "1":
    raise SystemExit("rollup projection schema is missing or unsupported")
for path, key in ((task_store, "task_store_hash"), (story_registry, "story_registry_hash")):
    expected = hashlib.sha256(path.read_bytes()).hexdigest()
    if field(key) != expected:
        raise SystemExit(f"rollup {key} does not match source")
if not field("task_id") or not field("epic_status") or not field("verification_result"):
    raise SystemExit("rollup update is missing identity or verification fields")
print("Rollup projection checks passed.")
PY
