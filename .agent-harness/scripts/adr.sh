#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/adr.sh list
  scripts/adr.sh index
  scripts/adr.sh select <task_id> ADR-0001 [ADR-0002...] --reason "..."
  scripts/adr.sh review <task_id>
  scripts/adr.sh new "<title>" [--tags "tag1,tag2"]
EOF
}

index_file="docs/decisions/adr-index.json"

load_index_json() {
  [ -f "$index_file" ] || fail "Missing ADR index: $index_file"
  cat "$index_file"
}

review_file() {
  local task_id="$1"
  echo "docs/evidence/$task_id/adr-review.md"
}

selected_reason=""

cmd="${1:-}"
shift || true

case "$cmd" in
  list|index)
    [ -f "$index_file" ] || fail "Missing ADR index: $index_file"
    cat "$index_file"
    ;;
  select)
    task_id="${1:-}"
    shift || true
    [ -n "$task_id" ] || { usage; exit 1; }

    selected=()
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --reason)
          selected_reason="${2:-}"
          shift 2
          ;;
        --*)
          usage
          exit 1
          ;;
        *)
          selected+=("$1")
          shift
          ;;
      esac
    done

    [ "${#selected[@]}" -gt 0 ] || fail "select requires at least one ADR id"
    [ -n "$selected_reason" ] || fail "select requires --reason \"...\""

    dir="docs/evidence/$task_id"
    mkdir -p "$dir"

    python3 - "$index_file" "$task_id" "$selected_reason" "${selected[@]}" <<'PY'
import json
import hashlib
import pathlib
from datetime import datetime
import sys

index_path = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
reason = sys.argv[3]
selected = sys.argv[4:]

entries = json.loads(index_path.read_text())
lookup = {entry["id"]: entry for entry in entries}

lines = [
    "# ADR Review",
    "",
    f"task_id: {task_id}",
    f"reviewed_at: \"{datetime.now().strftime('%Y-%m-%d %H:%M')}\"",
    "result: reviewed",
    "new_adr_required: false",
    "relevant_adrs:",
]

for adr in selected:
    entry = lookup.get(adr)
    if not entry:
        raise SystemExit(f"Unknown ADR id: {adr}")
    adr_path = pathlib.Path(entry["path"])
    if not adr_path.is_file():
        raise SystemExit(f"ADR path missing: {adr_path}")
    adr_hash = hashlib.sha256(adr_path.read_bytes()).hexdigest()
    lines.append(
        f"  - id: {entry['id']} | path: {entry['path']} | hash: {adr_hash} | status: {entry['status']} | reason: {reason}"
    )

lines.extend([
    "",
    "## Relevant ADRs",
    "",
])
for adr in selected:
    entry = lookup[adr]
    adr_hash = hashlib.sha256(pathlib.Path(entry["path"]).read_bytes()).hexdigest()
    lines.append(f"- id: {entry['id']} | path: {entry['path']} | hash: {adr_hash} | status: {entry['status']} | reason: {reason}")

lines.extend([
    "",
    "## Result",
    "",
    "ADR review completed.",
    "",
])

review_file = pathlib.Path("docs/evidence") / task_id / "adr-review.md"
review_file.write_text("\n".join(lines))
PY
    echo "Created ADR review: $(review_file "$task_id")"
    ;;
  review)
    task_id="${1:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    file="$(review_file "$task_id")"
    [ -f "$file" ] || fail "Missing ADR review file: $file"
    cat "$file"
    ;;
  new)
    title="${1:-}"
    [ -n "$title" ] || { usage; exit 1; }
    shift || true
    tags=""
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --tags)
          tags="${2:-}"
          shift 2
          ;;
        *)
          usage
          exit 1
          ;;
      esac
    done

    python3 - "$index_file" "$title" "$tags" <<'PY'
import json
import pathlib
import re
import sys

index_path = pathlib.Path(sys.argv[1])
title = sys.argv[2]
tags = [t for t in sys.argv[3].split(",") if t]

entries = json.loads(index_path.read_text()) if index_path.exists() else []
ids = [entry["id"] for entry in entries]
next_num = max([int(i.split("-")[1]) for i in ids], default=0) + 1
adr_id = f"ADR-{next_num:04d}"
slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
file_path = pathlib.Path(f"docs/decisions/{next_num:04d}-{slug}.md")

file_path.write_text(
    "\n".join([
        f"# {adr_id}: {title}",
        "",
        "Date: " + __import__("datetime").datetime.now().strftime("%Y-%m-%d"),
        "",
        "## Status",
        "",
        "Proposed",
        "",
        "## Context",
        "",
        "Describe the decision context.",
        "",
        "## Decision",
        "",
        "Describe the decision.",
        "",
        "## Consequences",
        "",
        "Describe the consequences.",
        "",
    ])
)

entries.append({
    "id": adr_id,
    "title": title,
    "path": str(file_path),
    "status": "Proposed",
    "tags": tags,
    "summary": "",
})
index_path.write_text(json.dumps(entries, indent=2) + "\n")
print(f"Created ADR draft: {file_path}")
PY
    ;;
  *)
    usage
    exit 1
    ;;
esac
