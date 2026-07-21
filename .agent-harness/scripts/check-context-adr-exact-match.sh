#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

context_pack="$(evidence_dir)/context-pack.md"
adr_review="$(evidence_dir)/adr-review.md"

[ -f "$context_pack" ] || fail "Missing context pack evidence: $context_pack"
[ -f "$adr_review" ] || fail "Missing ADR review evidence: $adr_review"

python3 - "$context_pack" "$adr_review" <<'PY'
import pathlib
import re
import sys

context_pack = pathlib.Path(sys.argv[1]).read_text()
adr_review = pathlib.Path(sys.argv[2]).read_text()

def selected_ids(text, header, end_markers):
    lines = text.splitlines()
    try:
        start = lines.index(header) + 1
    except ValueError:
        return []
    ids = []
    for line in lines[start:]:
        if line.startswith("## "):
            break
        match = re.search(r"id:\s*(ADR-[0-9]+)", line)
        if match:
            ids.append(match.group(1))
    return ids

def section_count(text, header):
    return sum(1 for line in text.splitlines() if line.strip() == header)

context_ids = selected_ids(context_pack, "## Selected ADRs", [])
review_ids = selected_ids(adr_review, "## Relevant ADRs", [])

if not context_ids:
    raise SystemExit("Context pack selected ADRs are empty")
if not review_ids:
    raise SystemExit("ADR review selected ADRs are empty")

if section_count(context_pack, "## Selected ADRs") != 1:
    raise SystemExit("Context pack must contain exactly one ## Selected ADRs section")
if section_count(adr_review, "## Relevant ADRs") != 1:
    raise SystemExit("ADR review must contain exactly one ## Relevant ADRs section")

if len(context_ids) != len(set(context_ids)):
    raise SystemExit(f"Context pack selected ADRs contain duplicates: {context_ids}")
if len(review_ids) != len(set(review_ids)):
    raise SystemExit(f"ADR review selected ADRs contain duplicates: {review_ids}")

if context_ids != review_ids:
    raise SystemExit(
        "Selected ADRs do not match between context pack and ADR review: "
        f"{context_ids} != {review_ids}"
    )
PY

echo "Context ADR exact-match checks passed."
