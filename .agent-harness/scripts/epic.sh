#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

EPIC_ROOT="${EPIC_ROOT:-docs/epics}"

usage() {
  cat <<'EOF'
Usage:
  scripts/epic.sh create <epic_id> "<title>"
  scripts/epic.sh list
  scripts/epic.sh show <epic_id>
  scripts/epic.sh progress <epic_id>
  scripts/epic.sh complete <epic_id>
  scripts/epic.sh block <epic_id> "<reason>"
EOF
}

validate_id() {
  local epic_id="$1"
  [[ "$epic_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "epic_id must be lowercase snake_case: $epic_id"
}

epic_dir() {
  echo "$EPIC_ROOT/$1"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  create)
    epic_id="${1:-}"
    title="${2:-}"
    [ -n "$epic_id" ] && [ -n "$title" ] || { usage; exit 1; }
    require_full_context
    validate_id "$epic_id"
    dir="$(epic_dir "$epic_id")"
    [ ! -e "$dir" ] || fail "Epic already exists: $dir"

    mkdir -p "$dir"
    cat > "$dir/epic.md" <<EOF
# Epic: $title

## Problem

Describe the problem this epic solves.

## Goal

Describe what should be true when the epic is complete.

## Non-Goals

Describe what is not in scope.

## Users / Actors

Describe the users or systems that depend on this epic.

## Current Brownfield Context

Describe the existing code, workflows, constraints, and risks.

## Scope

## Constraints

## Risks

## Acceptance Summary

High-level acceptance criteria.

## Feature Questions

Tracked in `clarifications.md`.

## Stories

Managed in `stories.jsonl`.
EOF

    cat > "$dir/stories.jsonl" <<'EOF'
EOF

    cat > "$dir/epic-memory.md" <<'EOF'
# Epic Memory

Compressed memory across stories and tasks.

## Stable Decisions

## Important Context

## Repeated Constraints

## Do Not Forget
EOF

    cat > "$dir/integration-contract.md" <<'EOF'
# Integration Contract

Shared contracts between stories and tasks.

## APIs

## Data

## Files

## Scripts

## Compatibility Requirements
EOF

    cat > "$dir/clarifications.md" <<'EOF'
# Clarifications

## Blocking Questions

## Answered Questions

## Open Non-Blocking Questions
EOF

    cat > "$dir/progress.md" <<'EOF'
# Epic Progress

## Status

DRAFT

## Completed Stories

## Active Story

## Blocked Stories

## Next Candidate Tasks
EOF

    echo "Created epic: $dir"
    ;;
  list)
    [ -d docs/epics ] || exit 0
    find docs/epics -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r dir; do
      [ -f "$dir/epic.md" ] || continue
      basename "$dir"
    done
    ;;
  show)
    epic_id="${1:-}"
    [ -n "$epic_id" ] || { usage; exit 1; }
    cat "$(epic_dir "$epic_id")/epic.md"
    ;;
  progress)
    epic_id="${1:-}"
    [ -n "$epic_id" ] || { usage; exit 1; }
    cat "$(epic_dir "$epic_id")/progress.md"
    ;;
  complete)
    epic_id="${1:-}"
    [ -n "$epic_id" ] || { usage; exit 1; }
    file="$(epic_dir "$epic_id")/stories.jsonl"
    [ -f "$file" ] || fail "Missing story registry: $file"
    python3 - "$file" <<'PY'
import json
import pathlib
import sys

story_file = pathlib.Path(sys.argv[1])
rows = [json.loads(line) for line in story_file.read_text().splitlines() if line.strip()]
unfinished = [row for row in rows if row.get("status") != "DONE"]
if unfinished:
    details = ", ".join(f"{row.get('id')}:{row.get('status')}" for row in unfinished)
    raise SystemExit(f"Epic has unfinished stories: {details}")
PY
    if [ -x ./scripts/update-epic-progress.sh ]; then
      EPIC_ROOT="$EPIC_ROOT" ./scripts/update-epic-progress.sh "$epic_id"
    fi
    echo "Completed epic: $epic_id"
    ;;
  block)
    epic_id="${1:-}"
    reason="${2:-}"
    [ -n "$epic_id" ] && [ -n "$reason" ] || { usage; exit 1; }
    file="$(epic_dir "$epic_id")/progress.md"
    [ -f "$file" ] || fail "Missing epic progress file: $file"
    {
      echo
      echo "## Update"
      echo
      echo "- epic_id: $epic_id"
      echo "- status: BLOCKED"
      echo "- reason: $reason"
      echo "- recorded_at: $(date '+%Y-%m-%d %H:%M')"
    } >> "$file"
    echo "Blocked epic: $epic_id"
    ;;
  *)
    usage
    exit 1
    ;;
esac
