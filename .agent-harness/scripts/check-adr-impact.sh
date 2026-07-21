#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

file="$(evidence_dir)/adr-review.md"
[ -f "$file" ] || fail "Missing ADR review evidence: $file"

python3 - "$file" "docs/decisions/adr-index.json" "$(fm_value "$PLAN_PATH" "task_id")" <<'PY'
import json
import hashlib
import pathlib
import re
import sys

review_path = pathlib.Path(sys.argv[1])
index_path = pathlib.Path(sys.argv[2])
task_id = sys.argv[3]
review = review_path.read_text()
index = {row["id"]: row for row in json.loads(index_path.read_text())}

def fm_value(text, key):
    for line in text.splitlines():
        if line.startswith(f"{key}:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""

new_required = fm_value(review, "new_adr_required")
if new_required not in {"true", "false"}:
    raise SystemExit("ADR review missing new_adr_required boolean")
if fm_value(review, "task_id") != task_id:
    raise SystemExit("ADR review task_id does not match active task")
if not fm_value(review, "reviewed_at"):
    raise SystemExit("ADR review missing reviewed_at")

result = fm_value(review, "result")
if result not in {"reviewed", "CLEAR"}:
    raise SystemExit(f"ADR review result must be reviewed or CLEAR, got: {result}")

entries = []
in_entries = False
for line in review.splitlines():
    if line.strip() == "relevant_adrs:":
        in_entries = True
        continue
    if in_entries and line.startswith("## "):
        break
    if in_entries and re.match(r"^\s*-\s+id:", line):
        entries.append(line.strip())

if not entries:
    raise SystemExit("ADR review missing relevant ADR entries")

for entry in entries:
    match = re.search(r"id:\s*([A-Z0-9-]+)\s*\|\s*path:\s*([^\s|]+)\s*\|\s*hash:\s*([0-9a-fA-F]{64})\s*\|\s*status:\s*([^|]+)", entry)
    if not match:
        raise SystemExit(f"Malformed ADR review entry: {entry}")
    adr_id, path, expected_hash, status = match.group(1), match.group(2), match.group(3), match.group(4).strip()
    if adr_id not in index:
        raise SystemExit(f"Unknown ADR id in review: {adr_id}")
    if not pathlib.Path(path).exists():
        raise SystemExit(f"ADR path does not exist: {path}")
    actual_hash = hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
    if actual_hash.lower() != expected_hash.lower():
        raise SystemExit(f"ADR content hash mismatch for {adr_id}")
    if status != "Accepted":
        raise SystemExit(f"ADR status must be Accepted for selected ADRs: {adr_id}")

if new_required == "false" and not entries:
    raise SystemExit("ADR review should include relevant ADRs when no new ADR is required")
PY

echo "ADR impact checks passed."
