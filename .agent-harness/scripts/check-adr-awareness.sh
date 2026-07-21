#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

index_file="docs/decisions/adr-index.json"
review_file="$(evidence_dir)/adr-review.md"
context_pack="$(evidence_dir)/context-pack.md"

[ -f "$index_file" ] || fail "Missing ADR index: $index_file"
[ -f "$review_file" ] || fail "Missing ADR review evidence: $review_file"
[ -f "$context_pack" ] || fail "Missing context pack evidence: $context_pack"

grep -q '^result:[[:space:]]*reviewed$' "$review_file" || fail "ADR review must have result: reviewed"
grep -q '^relevant_adrs:[[:space:]]*$' "$review_file" || fail "Missing relevant_adrs section in $review_file"
grep -q '^## Relevant ADRs$' "$review_file" || fail "Missing ADR list section in $review_file"

context_ids="$(awk '
  /^## Selected ADRs$/ {in_section=1; next}
  /^## / && in_section {exit}
  in_section && /^[[:space:]]*-[[:space:]]+id:[[:space:]]+ADR-[0-9]+/ {
    line=$0
    sub(/^[[:space:]]*-[[:space:]]+id:[[:space:]]+/, "", line)
    split(line, parts, /[[:space:]]+\|[[:space:]]+/)
    print parts[1]
  }
' "$context_pack" | sort -u)"

python3 - "$index_file" "$review_file" "$context_ids" <<'PY'
import json
import hashlib
import pathlib
import re
import sys

index_path = pathlib.Path(sys.argv[1])
review_path = pathlib.Path(sys.argv[2])
context_ids = set(filter(None, sys.argv[3].splitlines()))
index = {entry["id"]: entry for entry in json.loads(index_path.read_text())}

selected = []
for line in review_path.read_text().splitlines():
    if not line.lstrip().startswith("- id: ADR-"):
        continue
    pieces = {}
    for part in [p.strip() for p in line.lstrip()[2:].split("|")]:
        if ":" not in part:
            continue
        key, value = part.split(":", 1)
        pieces[key.strip()] = value.strip()
    adr_id = pieces.get("id")
    path = pieces.get("path")
    content_hash = pieces.get("hash")
    status = pieces.get("status")
    reason = pieces.get("reason")
    if not adr_id or adr_id not in index:
        raise SystemExit(f"Unknown ADR id '{adr_id}' in {review_path}")
    entry = index[adr_id]
    if not path or path != entry["path"]:
        raise SystemExit(f"ADR path mismatch for {adr_id}: {path} != {entry['path']}")
    if not pathlib.Path(path).exists():
        raise SystemExit(f"ADR path missing for {adr_id}: {path}")
    if not content_hash or len(content_hash) != 64:
        raise SystemExit(f"ADR hash missing for {adr_id}")
    if hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest() != content_hash.lower():
        raise SystemExit(f"ADR content hash mismatch for {adr_id}")
    if not status or status not in {"Proposed", "Accepted", "Superseded"}:
        raise SystemExit(f"Invalid ADR status for {adr_id}: {status}")
    if not reason:
        raise SystemExit(f"Missing ADR reason for {adr_id}")
    selected.append(adr_id)
    if context_ids and adr_id not in context_ids:
        raise SystemExit(f"Selected ADR {adr_id} missing from context pack")

if not selected:
    raise SystemExit(f"No selected ADRs found in {review_path}")
PY

echo "ADR awareness checks passed."
