#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

task_id="$(fm_value "$PLAN_PATH" "task_id")"
[ -n "$task_id" ] || fail "Missing task_id in active plan"

dir="$(evidence_dir)"
context_pack="$dir/context-pack.md"
full_context="$(full_context_file)"

./scripts/context.sh localize --task "$task_id"
./scripts/context.sh conventions --task "$task_id"
./scripts/context.sh pack --task "$task_id" --budget "${FULL_CONTEXT_BUDGET:-5000}"

python3 - "$PLAN_PATH" "$context_pack" "$full_context" <<'PY'
import datetime
import pathlib
import re
import sys

plan = pathlib.Path(sys.argv[1]).read_text()
context_pack = pathlib.Path(sys.argv[2]).read_text()
full_context = pathlib.Path(sys.argv[3])
repo_root = pathlib.Path.cwd().parent

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

def section_text(start_heading, end_headings):
    lines = plan.splitlines()
    try:
        start = next(i for i, line in enumerate(lines) if line.strip() == start_heading)
    except StopIteration:
        return ""
    end = len(lines)
    for heading in end_headings:
        try:
            idx = next(i for i, line in enumerate(lines[start + 1:], start + 1) if line.strip() == heading)
        except StopIteration:
            continue
        if idx < end:
            end = idx
    return "\n".join(lines[start + 1:end]).strip()

def selected_lines(header):
    lines = context_pack.splitlines()
    try:
        start = lines.index(header) + 1
    except ValueError:
        return []
    result = []
    for line in lines[start:]:
        if line.startswith("## "):
            break
        if line.startswith("- "):
            result.append(line[2:].strip())
    return result

def selected_adr_lines():
    lines = context_pack.splitlines()
    try:
        start = lines.index("## Selected ADRs") + 1
    except ValueError:
        return []
    result = []
    for line in lines[start:]:
        if line.startswith("## "):
            break
        if line.startswith("- "):
            result.append(line[2:].strip())
    return result

task_id = fm_value(plan, "task_id")
title = fm_value(plan, "title")
goal = section_text("## Goal", ["## Baseline Contract", "## Feature Intake"])
problem = section_text("### Problem", ["### Scope", "### Out of Scope", "### Success Criteria", "### Dependencies", "## Epic / Story / Task Breakdown"])
scope = section_text("### Scope", ["### Out of Scope", "### Success Criteria", "### Dependencies", "## Epic / Story / Task Breakdown"])
out_of_scope = section_text("### Out of Scope", ["### Success Criteria", "### Dependencies", "## Epic / Story / Task Breakdown"])
success = section_text("### Success Criteria", ["### Dependencies", "## Epic / Story / Task Breakdown"])
dependencies = section_text("### Dependencies", ["## Epic / Story / Task Breakdown"])
breakdown = section_text("## Epic / Story / Task Breakdown", ["## Brownfield Evidence", "## Report Shape", "## Approved Decisions", "## Scope", "## Phases", "## Verification", "## Review", "## Risks"])
repo_mode = fm_value(plan, "repo_mode")
task_change_type = fm_value(plan, "task_change_type")
touches_existing = fm_value(plan, "task_touches_existing_behavior")
backward_compat = fm_value(plan, "task_backward_compatibility_required")
baseline_ref = fm_value(plan, "baseline_ref")
approved_scopes = []
lines = plan.splitlines()
try:
    start = next(i for i, line in enumerate(lines) if line.strip() == "approved_scopes:")
except StopIteration:
    start = None
if start is not None:
    for line in lines[start + 1:]:
        if not line.startswith("  - "):
            break
        approved_scopes.append(line[4:].strip())

selected_context_docs = selected_lines("## Selected Context Files")
selected_adrs = selected_adr_lines()
contract_registry = repo_root / ".agent-harness/policies/v3-contract.json"
contract_coverage = "not available"
if contract_registry.exists():
    import subprocess
    result = subprocess.run([str(repo_root / ".agent-harness/scripts/check-v3-contract-coverage.sh"), str(contract_registry)], cwd=repo_root / ".agent-harness", capture_output=True, text=True)
    contract_coverage = (result.stdout + result.stderr).strip() or "coverage check produced no output"
readiness_contract = "readiness record not bound for this task"
readiness_path = repo_root / ".agent-harness/runtime/readiness.json"
readiness_validator = repo_root / ".agent-harness/scripts/readiness-control.sh"
if readiness_path.exists() and readiness_validator.exists():
    result = subprocess.run(["bash", str(readiness_validator), "verify", str(readiness_path)], cwd=repo_root, capture_output=True, text=True)
    readiness_contract = (result.stdout + result.stderr).strip() or "readiness check produced no output"

def bullets(items):
    return "\n".join(f"- {item}" for item in items) if items else "- (none)"

content = f"""# Full Context

task_id: {task_id}
title: {title}
generated_at: {datetime.datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %z')}
source_plan: {sys.argv[1]}
source_context_pack: {sys.argv[2]}

## Problem Statement

{problem or "The harness needs a repo-grounded context layer before decomposition."}

## Goal

{goal or "Introduce a required full-context layer before epic, story, and task breakdown."}

## Current Repo State

- active_plan: {sys.argv[1]}
- repo_mode: {repo_mode}
- task_change_type: {task_change_type}
- task_touches_existing_behavior: {touches_existing}
- task_backward_compatibility_required: {backward_compat}
- baseline_ref: {baseline_ref}
- approved_scopes: {", ".join(approved_scopes) if approved_scopes else "(none)"}
- context_pack: {sys.argv[2]}

## Relevant Docs

{bullets(selected_context_docs)}

## Relevant ADRs

{bullets(selected_adrs)}

## Constraints

- The full-context artifact must be generated before epic, story, or task decomposition.
- The artifact must remain task-scoped and repo-grounded.
- The harness should not require the user to hand-author the context layer.
- Existing task lifecycle commands remain the source of truth.

## Risks

- Repo state may change after the artifact is generated.
- Selected context may omit a newly relevant file if the pack is stale.
- A missing full-context file would cause breakdown commands to block.

## Unknowns

- Whether future tasks should store a canonical copy outside task evidence.
- How much of the generated context should be reused across follow-on tasks.
- Whether some breakdowns should require explicit human review before create.

## Assumptions

- The active plan and repository intelligence are sufficient to ground the breakdown.
- The selected docs and ADRs reflect the current implementation constraints.
- The full-context layer is a generation step, not a new lifecycle phase.

## Implementation Boundaries

- Add the full-context generator and validator.
- Wire the harness packet and task breakdown commands to require the artifact.
- Update workflow and context docs to name the new layer.
- Avoid broad task-store or lifecycle redesign.

## Recommended Breakdown

{breakdown or "- Add a full-context generator command.\n- Add a full-context validation command.\n- Wire epic, story, and task creation to require the artifact.\n- Update packet output and workflow docs.\n- Add tests for generation and gating."}

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.

## V3 Contract Coverage

```text
{contract_coverage}
```

## Implementation Readiness

```text
{readiness_contract}
```
"""

full_context.write_text(content)
PY

echo "Created full context: $full_context"
