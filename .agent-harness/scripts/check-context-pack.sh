#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

file="$(evidence_dir)/context-pack.md"
[ -f "$file" ] || fail "Missing context pack evidence: $file"

python3 - "$file" "$PLAN_PATH" <<'PY'
import json
import pathlib
import re
import sys

pack_path = pathlib.Path(sys.argv[1])
plan_path = pathlib.Path(sys.argv[2])
text = pack_path.read_text()
plan = plan_path.read_text()

def fm_value(content, key):
    in_fm = False
    for line in content.splitlines():
        if line.strip() == "---":
            if not in_fm:
                in_fm = True
                continue
            break
        if not in_fm:
            continue
        if line.startswith(f"{key}:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""

def body_value(content, key):
    for line in content.splitlines():
        if line.startswith(f"{key}:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""

task_id = fm_value(plan, "task_id")
required_sections = [
    "## Active Task",
    "## Selected Context Files",
    "## Repo Mode Summary",
    "## Repository Intelligence",
    "## Impact Scan",
    "## Convention Awareness",
    "## Business Rule Awareness",
    "## Regression Scope",
    "## Verification Scope",
    "## Environment State",
    "## Human Approval",
    "## Parent Epic Summary",
    "## Parent Story Summary",
    "## Epic Memory Summary",
    "## Integration Contract Summary",
    "## Clarification Summary",
    "## Selected ADRs",
    "## Selected Repo Memory",
    "## Localization",
    "## Brownfield Conventions",
    "## Required Checks",
    "## Do Not Read",
]
for section in required_sections:
    if section not in text:
        raise SystemExit(f"Missing required section: {section}")

budget = body_value(text, "budget")
if not budget.isdigit() or int(budget) <= 0:
    raise SystemExit(f"Invalid budget: {budget!r}")
if body_value(text, "task_id") != task_id:
    raise SystemExit(f"Context pack task_id mismatch: {body_value(text, 'task_id')!r} != {task_id!r}")

def section_lines(header):
    lines = text.splitlines()
    try:
        start = lines.index(header) + 1
    except ValueError:
        return []
    result = []
    for line in lines[start:]:
        if line.startswith("## "):
            break
        if line.startswith("### "):
            break
        if line.startswith("- "):
            result.append(line[2:].strip())
    return result

context_lines = section_lines("## Selected Context Files")
if not context_lines:
    raise SystemExit("Selected Context Files section is empty")

allowed_prefixes = (
    "docs/evidence/",
    "docs/context/",
    "docs/decisions/",
    "docs/epics/",
)
for line in context_lines:
    if line.startswith("docs/exec-plans/completed/"):
        raise SystemExit(f"Completed plan leaked into context pack: {line}")
    if line.startswith("docs/reviews/") and not line.endswith("TEMPLATE.md"):
        raise SystemExit(f"Review leaked into context pack: {line}")
    if line.startswith("docs/evidence/") and f"docs/evidence/{task_id}/" not in line:
        raise SystemExit(f"Old evidence leaked into context pack: {line}")
    if not line.startswith(allowed_prefixes) and "#story:" not in line:
        raise SystemExit(f"Unexpected context file path: {line}")

required_repo_intel = {
    "docs/context/repository-intelligence/README.md",
    "docs/context/repository-intelligence/repo-profile.yml",
    "docs/context/repository-intelligence/repo-map.md",
    "docs/context/repository-intelligence/architecture-map.md",
    "docs/context/repository-intelligence/module-boundaries.md",
    "docs/context/repository-intelligence/domain-model.md",
    "docs/context/repository-intelligence/business-rules.md",
    "docs/context/repository-intelligence/data-flow.md",
    "docs/context/repository-intelligence/api-contracts.md",
    "docs/context/repository-intelligence/database-model.md",
    "docs/context/repository-intelligence/implementation-patterns.md",
    "docs/context/repository-intelligence/testing-style.md",
    "docs/context/repository-intelligence/dependency-map.md",
    "docs/context/repository-intelligence/dangerous-areas.md",
    "docs/context/repository-intelligence/legacy-constraints.md",
    "docs/context/repository-intelligence/knowledge-index.json",
}
if not required_repo_intel.issubset(context_lines):
    missing = sorted(required_repo_intel.difference(context_lines))
    raise SystemExit(f"Missing repository intelligence selections: {missing}")

adr_index = json.loads(pathlib.Path("docs/decisions/adr-index.json").read_text())
adr_lookup = {entry["id"]: entry for entry in adr_index}

adr_lines = section_lines("## Selected ADRs")
if not adr_lines:
    raise SystemExit("Selected ADRs section is empty")
for line in adr_lines:
    parts = {}
    for chunk in [p.strip() for p in line.split("|")]:
        if ":" not in chunk:
            continue
        key, value = chunk.split(":", 1)
        parts[key.strip("- ").strip()] = value.strip()
    adr_id = parts.get("id")
    path = parts.get("path")
    status = parts.get("status")
    reason = parts.get("reason")
    if not adr_id or adr_id not in adr_lookup:
        raise SystemExit(f"Unknown ADR id in context pack: {line}")
    entry = adr_lookup[adr_id]
    if path != entry["path"]:
        raise SystemExit(f"ADR path mismatch for {adr_id}: {path} != {entry['path']}")
    if status not in {"Proposed", "Accepted", "Superseded"}:
        raise SystemExit(f"Invalid ADR status for {adr_id}: {status}")
    if not reason:
        raise SystemExit(f"ADR reason missing for {adr_id}")

if "No parent epic." in text and fm_value(plan, "parent_epic_id") not in {"", "null"}:
    raise SystemExit("Parent epic summary missing")
manifest_path = pack_path.parent / "context-manifest.json"
if not manifest_path.is_file():
    raise SystemExit("Context manifest is missing")
manifest = json.loads(manifest_path.read_text())
for key in ["compiler_version", "budget", "estimated_tokens", "sources", "omissions"]:
    if key not in manifest:
        raise SystemExit(f"Context manifest is missing {key}")
if manifest.get("status") != "generated":
    raise SystemExit("Context manifest must be marked generated")
if not manifest.get("within_budget") or manifest["estimated_tokens"] > manifest["budget"]:
    raise SystemExit("Context manifest exceeds its hard budget")
for source in manifest["sources"]:
    path = pathlib.Path(source["path"])
    if not path.is_file():
        raise SystemExit(f"Context manifest source is missing: {path}")

if "No parent story." in text and fm_value(plan, "parent_story_id") not in {"", "null"}:
    raise SystemExit("Parent story summary missing")

print("Context pack checks passed.")
PY

echo "Context pack checks passed."
