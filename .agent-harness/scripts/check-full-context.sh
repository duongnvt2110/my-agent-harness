#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

file="$(full_context_file)"
[ -f "$file" ] || fail "Missing full context evidence: $file"

python3 - "$file" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()

required_sections = [
    "## Problem Statement",
    "## Goal",
    "## Current Repo State",
    "## Relevant Docs",
    "## Relevant ADRs",
    "## Constraints",
    "## Risks",
    "## Unknowns",
    "## Assumptions",
    "## Implementation Boundaries",
    "## Recommended Breakdown",
    "## Validation Notes",
]

for section in required_sections:
    if section not in text:
        raise SystemExit(f"Missing required section: {section}")

placeholders = (
    "Describe the",
    "TODO",
    "TBD",
    "<name>",
    "<story>",
    "<task>",
    "<dependency>",
    "<acceptance criterion>",
    "Placeholder",
)
for token in placeholders:
    if token in text:
        raise SystemExit(f"Placeholder content remains in full context: {token}")

for heading in required_sections:
    pattern = rf"{re.escape(heading)}\n\n(.*?)(?=\n## |\Z)"
    match = re.search(pattern, text, re.S)
    if not match or not match.group(1).strip():
        raise SystemExit(f"Empty section body: {heading}")

print("Full context checks passed.")
PY

echo "Full context checks passed."
