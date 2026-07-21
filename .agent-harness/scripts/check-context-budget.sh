#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

file="$(evidence_dir)/context-pack.md"
[ -f "$file" ] || fail "Missing context pack evidence: $file"

python3 - "$file" "$PLAN_PATH" <<'PY'
import pathlib
import re
import sys

pack_path = pathlib.Path(sys.argv[1])
plan_path = pathlib.Path(sys.argv[2])

pack = pack_path.read_text()
plan = plan_path.read_text()

budget_match = re.search(r"^budget:\s*(\d+)\s*$", pack, re.M)
limit_match = re.search(r"^max_context_tokens:\s*(\d+)\s*$", plan, re.M)

if not budget_match:
    raise SystemExit("Invalid context budget: missing budget field")
if not limit_match:
    raise SystemExit("Invalid max_context_tokens: missing plan limit")

budget = int(budget_match.group(1))
limit = int(limit_match.group(1))
if budget > limit:
    raise SystemExit(f"Context budget exceeds plan limit: {budget} > {limit}")

manifest_path = pack_path.parent / "context-manifest.json"
if not manifest_path.is_file():
    raise SystemExit("Context manifest is missing")
manifest = __import__("json").loads(manifest_path.read_text())
if manifest.get("budget") != budget:
    raise SystemExit("Context manifest budget does not match context pack")
if not manifest.get("within_budget") or manifest.get("estimated_tokens", budget + 1) > budget:
    raise SystemExit("Context manifest reports usage above the hard budget")
PY

echo "Context budget checks passed."
