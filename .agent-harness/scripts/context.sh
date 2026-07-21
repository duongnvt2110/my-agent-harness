#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/context.sh index
  scripts/context.sh localize --task <task_id>
  scripts/context.sh conventions --task <task_id>
  scripts/context.sh pack --task <task_id> --budget <n>
  scripts/context.sh budget --task <task_id>
EOF
}

cmd="${1:-}"
shift || true

task_id=""
budget="5000"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --task) task_id="${2:-}"; shift 2 ;;
    --budget) budget="${2:-}"; shift 2 ;;
    *) usage; exit 1 ;;
  esac
done

ensure_task_dir() {
  [ -n "$task_id" ] || fail "Missing --task <task_id>"
  mkdir -p "docs/evidence/$task_id"
}

plan_value() {
  fm_value "$PLAN_PATH" "$1"
}

normalize_plan_value() {
  local value="${1:-}"
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    printf '%s' ""
  else
    printf '%s' "$value"
  fi
}

plan_repo_mode() {
  local mode
  mode="$(normalize_plan_value "$(plan_value repo_mode)")"
  [ -n "$mode" ] || mode="brownfield"
  printf '%s' "$mode"
}

plan_task_change_type() {
  normalize_plan_value "$(plan_value task_change_type)"
}

plan_task_touches_existing_behavior() {
  normalize_plan_value "$(plan_value task_touches_existing_behavior)"
}

plan_task_backward_compatibility_required() {
  normalize_plan_value "$(plan_value task_backward_compatibility_required)"
}

selected_adr_rows() {
  local task_id="${1:-}"
  local review_file="docs/evidence/$task_id/adr-review.md"
  if [ -n "$task_id" ] && [ -f "$review_file" ]; then
    python3 - "$review_file" <<'PY'
import pathlib
import re
import sys

review = pathlib.Path(sys.argv[1]).read_text()
lines = review.splitlines()
try:
    start = lines.index("## Relevant ADRs") + 1
except ValueError:
    sys.exit(0)
for line in lines[start:]:
    if line.startswith("## "):
        break
    if not line.lstrip().startswith("- id: ADR-"):
        continue
    parts = {}
    for chunk in [p.strip() for p in line.lstrip()[2:].split("|")]:
        if ":" not in chunk:
            continue
        key, value = chunk.split(":", 1)
        parts[key.strip()] = value.strip()
    adr_id = parts.get("id")
    path = parts.get("path")
    content_hash = parts.get("hash")
    status = parts.get("status")
    reason = parts.get("reason")
    if adr_id and path and content_hash and status and reason:
        print(f"- id: {adr_id} | path: {path} | hash: {content_hash} | status: {status} | reason: {reason}")
PY
    return
  fi

  python3 - <<'PY'
import hashlib
import json
from pathlib import Path

index = json.loads(Path("docs/decisions/adr-index.json").read_text())
accepted = [row for row in index if row.get("status") == "Accepted"]
for row in accepted[:3]:
    path = Path(row["path"])
    if not path.is_file():
        raise SystemExit(f"ADR path missing: {path}")
    content_hash = hashlib.sha256(path.read_bytes()).hexdigest()
    tags = ", ".join(row.get("tags", []))
    reason = row.get("summary", "")
    print(f"- id: {row['id']} | path: {row['path']} | hash: {content_hash} | status: {row['status']} | tags: {tags} | reason: {reason}")
PY
}

memory_index_paths() {
  python3 - <<'PY'
import json
from pathlib import Path

index_path = Path("docs/context/memory-index.json")
if not index_path.exists():
    raise SystemExit(0)
for row in json.loads(index_path.read_text()):
    path = row.get("path", "")
    if path:
        print(path)
PY
}

selected_memory_rows() {
  python3 - <<'PY'
import json
from pathlib import Path

index_path = Path("docs/context/memory-index.json")
if not index_path.exists():
    raise SystemExit(0)

reasons = {
    "repo_profile": "baseline repo overview",
    "commands": "command interface",
    "boundaries": "file and scope control",
    "conventions": "documentation and evidence conventions",
    "runbooks": "workflow runbooks",
    "known_errors": "common failure patterns",
    "discussions": "discussion history",
}

for row in json.loads(index_path.read_text()):
    path = row.get("path", "")
    if not path:
        continue
    reason = reasons.get(row.get("id", ""), row.get("summary", "selected memory"))
    print(f"- id: {row.get('id', 'unknown')} | path: {path} | reason: {reason}")
PY
}

selected_context_files() {
  local task_id="$1"
  local epic_id="$2"
  local story_id="$3"
  local repo_mode
  repo_mode="$(plan_repo_mode)"

  [ -f docs/context/memory-index.json ] && echo "- docs/context/memory-index.json"
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    [ -f "$file" ] && echo "- $file"
  done < <(memory_index_paths)

  for file in \
    docs/evidence/"$task_id"/working-memory.md \
    docs/evidence/"$task_id"/localization.md \
    docs/evidence/"$task_id"/brownfield-conventions.md \
    docs/evidence/"$task_id"/repo-knowledge-selection.md \
    docs/evidence/"$task_id"/impact-scan.md \
    docs/evidence/"$task_id"/convention-awareness.md \
    docs/evidence/"$task_id"/business-rule-awareness.md \
    docs/evidence/"$task_id"/regression-scope.md \
    docs/evidence/"$task_id"/verification-scope.md \
    docs/evidence/"$task_id"/environment-state.md \
    docs/evidence/"$task_id"/human-approval.md \
    docs/evidence/"$task_id"/adr-review.md \
    docs/decisions/adr-index.json
  do
    [ -f "$file" ] && echo "- $file"
  done

  for file in \
    docs/context/repository-intelligence/README.md \
    docs/context/repository-intelligence/repo-profile.yml \
    docs/context/repository-intelligence/repo-map.md \
    docs/context/repository-intelligence/architecture-map.md \
    docs/context/repository-intelligence/module-boundaries.md \
    docs/context/repository-intelligence/domain-model.md \
    docs/context/repository-intelligence/business-rules.md \
    docs/context/repository-intelligence/data-flow.md \
    docs/context/repository-intelligence/api-contracts.md \
    docs/context/repository-intelligence/database-model.md \
    docs/context/repository-intelligence/implementation-patterns.md \
    docs/context/repository-intelligence/testing-style.md \
    docs/context/repository-intelligence/dependency-map.md \
    docs/context/repository-intelligence/dangerous-areas.md \
    docs/context/repository-intelligence/legacy-constraints.md \
    docs/context/repository-intelligence/knowledge-index.json
  do
    [ -f "$file" ] && echo "- $file"
  done

  case "$repo_mode" in
    greenfield)
      [ -f docs/context/repository-intelligence/greenfield-decisions.md ] && echo "- docs/context/repository-intelligence/greenfield-decisions.md"
      ;;
    hybrid)
      for file in \
        docs/context/repository-intelligence/error-handling-style.md \
        docs/context/repository-intelligence/logging-style.md \
        docs/context/repository-intelligence/transaction-patterns.md \
        docs/context/repository-intelligence/brownfield-observations.md \
        docs/context/repository-intelligence/greenfield-decisions.md
      do
        [ -f "$file" ] && echo "- $file"
      done
      ;;
    brownfield|*)
      for file in \
        docs/context/repository-intelligence/error-handling-style.md \
        docs/context/repository-intelligence/logging-style.md \
        docs/context/repository-intelligence/transaction-patterns.md \
        docs/context/repository-intelligence/brownfield-observations.md
      do
        [ -f "$file" ] && echo "- $file"
      done
      ;;
  esac

  if [ -n "$epic_id" ] && [ "$epic_id" != "null" ]; then
    for file in \
      docs/epics/"$epic_id"/epic.md \
      docs/epics/"$epic_id"/epic-memory.md \
      docs/epics/"$epic_id"/integration-contract.md \
      docs/epics/"$epic_id"/clarifications.md \
      docs/epics/"$epic_id"/progress.md \
      docs/epics/"$epic_id"/stories.jsonl
    do
      [ -f "$file" ] && echo "- $file"
    done
  fi

  if [ -n "$story_id" ] && [ "$story_id" != "null" ] && [ -n "$epic_id" ] && [ "$epic_id" != "null" ]; then
    echo "- docs/epics/$epic_id/stories.jsonl#story:$story_id"
  fi
}

write_context_manifest() {
  local task_id="$1"
  local budget="$2"
  local pack_path="docs/evidence/$task_id/context-pack.md"
  local manifest_path="docs/evidence/$task_id/context-manifest.json"

  python3 - "$PLAN_PATH" "$pack_path" "$manifest_path" "$budget" <<'PY'
import hashlib
import json
import math
import pathlib
import re
import sys

plan_path = pathlib.Path(sys.argv[1])
pack_path = pathlib.Path(sys.argv[2])
manifest_path = pathlib.Path(sys.argv[3])
budget = int(sys.argv[4])
pack = pack_path.read_text(encoding="utf-8")
volatile = re.compile(r"(?:recorded_at|packed_at|generated_at|reviewed_at|scanned_at|timestamp):", re.I)

def stable_bytes(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    stable = [line for line in text.splitlines() if not volatile.search(line)]
    return ("\n".join(stable) + "\n").encode("utf-8")

lines = pack.splitlines()
start = lines.index("## Selected Context Files") + 1
selected = []
for line in lines[start:]:
    if line.startswith("## "):
        break
    if line.startswith("- ") and "#story:" not in line:
        path = line[2:].strip()
        if path not in selected:
            selected.append(path)

sources = []
for name in selected:
    path = pathlib.Path(name)
    if not path.is_file():
        raise SystemExit(f"Selected context source is missing: {name}")
    data = stable_bytes(path)
    sources.append({"path": name, "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data), "selection_reason": "task, repository mode, or required harness evidence"})

candidate_roots = [pathlib.Path("docs/context/repository-intelligence"), pathlib.Path(f"docs/evidence/{plan_path.parent.name}")]
candidates = sorted({p.as_posix() for root in candidate_roots if root.exists() for p in root.rglob("*") if p.is_file()})
omissions = [{"path": name, "reason": "not selected by the locked task and repository-mode compiler"} for name in candidates if name not in set(selected)]
normalized_pack = "\n".join(line for line in pack.splitlines() if not volatile.search(line)) + "\n"
estimated_tokens = math.ceil(len(normalized_pack.encode("utf-8")) / 4)

frontmatter = plan_path.read_text(encoding="utf-8").split("---", 2)[1]
critical = []
in_acceptance = False
for line in frontmatter.splitlines():
    if line.startswith("acceptance_criteria:"):
        in_acceptance = True
    elif in_acceptance and line.startswith("  - "):
        critical.append(line[4:].strip().strip('"'))
    elif in_acceptance and line and not line.startswith(" "):
        in_acceptance = False

task_id = next((line.split(":", 1)[1].strip() for line in frontmatter.splitlines() if line.startswith("task_id:")), "")
payload = {"schema_version": 1, "status": "generated", "compiler_version": "v4-context-compiler-1", "task_id": task_id, "budget": budget, "estimated_tokens": estimated_tokens, "within_budget": estimated_tokens <= budget, "critical_requirements": critical, "sources": sources, "omissions": omissions}
if not payload["within_budget"]:
    raise SystemExit(f"Compiled context exceeds hard budget: {estimated_tokens} > {budget}")
manifest_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
}

case "$cmd" in
  index)
    mkdir -p docs/context
    ./scripts/repository-intelligence.sh build >/dev/null
    cat > docs/context/memory-index.json <<'EOF'
[
  {
    "id": "repo_profile",
    "type": "document",
    "path": "docs/context/repo-profile.md",
    "summary": "Repo purpose and major harness areas.",
    "tags": ["harness", "repo", "overview"]
  },
  {
    "id": "commands",
    "type": "document",
    "path": "docs/context/commands.md",
    "summary": "Common commands for plan, verify, finalize, intake, and context.",
    "tags": ["harness", "commands", "workflow"]
  },
  {
    "id": "boundaries",
    "type": "document",
    "path": "docs/context/boundaries.md",
    "summary": "Operational and file-scope boundaries.",
    "tags": ["harness", "boundaries", "scope"]
  },
  {
    "id": "conventions",
    "type": "document",
    "path": "docs/context/conventions.md",
    "summary": "Documentation and evidence conventions.",
    "tags": ["harness", "conventions", "evidence"]
  },
  {
    "id": "runbooks",
    "type": "document",
    "path": "docs/context/runbooks.md",
    "summary": "Recurring harness workflows.",
    "tags": ["harness", "runbooks", "workflow"]
  },
  {
    "id": "known_errors",
    "type": "document",
    "path": "docs/context/known-errors.md",
    "summary": "Common harness failures and fixes.",
    "tags": ["harness", "errors", "triage"]
  },
  {
    "id": "discussions",
    "type": "document",
    "path": "docs/context/discussions.md",
    "summary": "Reusable discussion summaries.",
    "tags": ["harness", "discussion", "memory"]
  }
]
EOF
    echo "Context index written: docs/context/memory-index.json"
    ;;
  localize)
    ensure_task_dir
    cat > "docs/evidence/$task_id/localization.md" <<EOF
# Localization

task_id: $task_id
recorded_at: "$(date '+%Y-%m-%d %H:%M')"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.
EOF
    echo "Created localization: docs/evidence/$task_id/localization.md"
    ;;
  conventions)
    ensure_task_dir
    cat > "docs/evidence/$task_id/brownfield-conventions.md" <<EOF
# Brownfield Conventions

task_id: $task_id
recorded_at: "$(date '+%Y-%m-%d %H:%M')"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.
EOF
    echo "Created conventions: docs/evidence/$task_id/brownfield-conventions.md"
    ;;
  pack)
    ensure_task_dir

    epic_id="$(plan_value "parent_epic_id")"
    story_id="$(plan_value "parent_story_id")"
    repo_mode="$(plan_repo_mode)"
    task_change_type="$(plan_task_change_type)"
    task_touches_existing_behavior="$(plan_task_touches_existing_behavior)"
    task_backward_compatibility_required="$(plan_task_backward_compatibility_required)"
    task_title="$(plan_value "title")"
    task_lane="$(plan_value "lane")"
    task_status="$(plan_value "status")"
    lifecycle_phase="$(plan_value "lifecycle_phase")"
    review_required="$(plan_value "review_required")"
    verification_mode="$(plan_value "verification_mode")"
    required_checks_count="$(required_check_rows "$PLAN_PATH" | awk 'END {print NR+0}')"

    ./scripts/repository-intelligence.sh select "$task_id"

    cat > "docs/evidence/$task_id/working-memory.md" <<EOF
# Working Memory

task_id: $task_id
recorded_at: "$(date '+%Y-%m-%d %H:%M')"

## Current State

- Brownfield harness implementation is in progress.
- The repo has a live active plan and task-local evidence.
- Context, ADR, and skill evidence are selected for the task.
- repo_mode: $repo_mode
- task_change_type: $task_change_type
- task_touches_existing_behavior: $task_touches_existing_behavior
- task_backward_compatibility_required: $task_backward_compatibility_required
EOF

    adr_review_file="docs/evidence/$task_id/adr-review.md"
    if [ ! -f "$adr_review_file" ]; then
      adr_rows="$(selected_adr_rows "$task_id")"
      {
        echo "# ADR Review"
        echo
        echo "task_id: $task_id"
        echo "reviewed_at: \"$(date '+%Y-%m-%d %H:%M')\""
        echo "result: reviewed"
        echo "new_adr_required: false"
        echo "relevant_adrs:"
        printf '%s\n' "$adr_rows" | sed '/^$/d; s/^/  /'
        echo
        echo "## Relevant ADRs"
        echo
        printf '%s\n' "$adr_rows"
        echo
        echo "## Result"
        echo
        echo "ADR review completed."
      } > "$adr_review_file"
    fi

    {
      echo "# Context Pack"
      echo
      echo "task_id: $task_id"
      echo "budget: $budget"
      echo "packed_at: \"$(date '+%Y-%m-%d %H:%M')\""
      echo
      echo "## Active Task"
      echo
      echo "- task_id: $task_id"
      echo "- title: $task_title"
      echo "- status: $task_status"
      echo "- lifecycle_phase: $lifecycle_phase"
      echo "- lane: $task_lane"
      echo "- review_required: $review_required"
      echo "- verification_mode: $verification_mode"
      echo "- required_checks: $required_checks_count"
      echo
      echo "## Selected Context Files"
      echo
      selected_context_files "$task_id" "$epic_id" "$story_id"
      echo
      echo "## Repo Mode Summary"
      echo
      echo "- repo_mode: $repo_mode"
      echo "- task_change_type: $task_change_type"
      echo "- task_touches_existing_behavior: $task_touches_existing_behavior"
      echo "- task_backward_compatibility_required: $task_backward_compatibility_required"
      echo
      echo "## Repository Intelligence"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/repo-knowledge-selection.md"
      echo
      echo "## Impact Scan"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/impact-scan.md"
      echo
      echo "## Convention Awareness"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/convention-awareness.md"
      echo
      echo "## Business Rule Awareness"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/business-rule-awareness.md"
      echo
      echo "## Regression Scope"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/regression-scope.md"
      echo
      echo "## Verification Scope"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/verification-scope.md"
      echo
      echo "## Environment State"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/environment-state.md"
      echo
      echo "## Human Approval"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/human-approval.md"
      echo
    echo "## Parent Epic Summary"
    echo
    if [ -n "$epic_id" ] && [ "$epic_id" != "null" ] && [ -f "docs/epics/$epic_id/epic.md" ]; then
        sed -n '1,120p' "docs/epics/$epic_id/epic.md"
      else
        echo "No parent epic."
      fi
      echo
      echo "## Parent Story Summary"
      echo
      if [ -n "$epic_id" ] && [ "$epic_id" != "null" ] && [ -n "$story_id" ] && [ "$story_id" != "null" ]; then
        awk -v id="$story_id" '
          $0 ~ "\"id\":\"" id "\"" { print; found=1; exit }
          END { if (!found) exit 1 }
        ' "docs/epics/$epic_id/stories.jsonl" 2>/dev/null || echo "Missing parent story summary."
      else
        echo "No parent story."
      fi
      echo
      echo "## Epic Memory Summary"
      echo
      if [ -n "$epic_id" ] && [ "$epic_id" != "null" ] && [ -f "docs/epics/$epic_id/epic-memory.md" ]; then
        sed -n '1,120p' "docs/epics/$epic_id/epic-memory.md"
      else
        echo "No epic memory."
      fi
      echo
      echo "## Integration Contract Summary"
      echo
      if [ -n "$epic_id" ] && [ "$epic_id" != "null" ] && [ -f "docs/epics/$epic_id/integration-contract.md" ]; then
        sed -n '1,120p' "docs/epics/$epic_id/integration-contract.md"
      else
        echo "No integration contract."
      fi
      echo
      echo "## Clarification Summary"
      echo
      if [ -n "$epic_id" ] && [ "$epic_id" != "null" ] && [ -f "docs/epics/$epic_id/clarifications.md" ]; then
        sed -n '1,120p' "docs/epics/$epic_id/clarifications.md"
      else
        echo "No clarifications."
      fi
      echo
      echo "## Selected ADRs"
      echo
      selected_adr_rows "$task_id"
      echo
      echo "## Selected Repo Memory"
      echo
      selected_memory_rows
      echo
      echo "## Localization"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/localization.md"
      echo
      echo "## Brownfield Conventions"
      echo
      sed -n '1,120p' "docs/evidence/$task_id/brownfield-conventions.md"
      echo
      echo "## Required Checks"
      echo
      required_check_rows "$PLAN_PATH" | awk -F'\t' '
        {
          printf("- id: %s | type: %s | command: %s | blocking: %s | timeout_seconds: %s | evidence: %s\n",
            $1, $2, $3, $4, $5, $6)
        }
      '
      echo
      echo "## Do Not Read"
      echo
      echo "- docs/exec-plans/completed/*"
      echo "- docs/evidence/*/verification-pass.md"
      echo "- docs/evidence/*/autonomous-run-report.md"
    } > "docs/evidence/$task_id/context-pack.md"

    write_context_manifest "$task_id" "$budget"
    echo "Created context pack: docs/evidence/$task_id/context-pack.md"
    ;;
  budget)
    ensure_task_dir
    echo "$budget"
    ;;
  *)
    usage
    exit 1
    ;;
esac
