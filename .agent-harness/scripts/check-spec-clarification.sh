#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

mode="check-only"
if [ "${1:-}" = "--write-evidence" ]; then
  mode="write-evidence"
elif [ "${1:-}" = "--check-only" ] || [ -z "${1:-}" ]; then
  mode="check-only"
else
  echo "Usage: scripts/check-spec-clarification.sh [--check-only|--write-evidence]" >&2
  exit 1
fi

dir="$(evidence_dir)"
file="$dir/spec-clarification.md"
task_id="$(fm_value "$PLAN_PATH" "task_id")"
epic_required="$(fm_value "$PLAN_PATH" "epic_context_required")"
task_required="$(fm_value "$PLAN_PATH" "spec_clarification_required")"
epic_id="$(fm_value "$PLAN_PATH" "parent_epic_id")"
story_id="$(fm_value "$PLAN_PATH" "parent_story_id")"
epic_path="$(fm_value "$PLAN_PATH" "epic_path")"
story_registry="$(fm_value "$PLAN_PATH" "story_registry")"
clarifications="$(fm_value "$PLAN_PATH" "epic_clarifications")"

mkdir -p "$dir"

python3 - "$PLAN_PATH" <<'PY'
import pathlib
import json
import re
import sys

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

plan = pathlib.Path(sys.argv[1]).read_text()
task_id = fm_value(plan, "task_id")
epic_required = fm_value(plan, "epic_context_required")
task_required = fm_value(plan, "spec_clarification_required")
epic_id = fm_value(plan, "parent_epic_id")
story_id = fm_value(plan, "parent_story_id")
epic_path = fm_value(plan, "epic_path")
story_registry = fm_value(plan, "story_registry")
clarifications = fm_value(plan, "epic_clarifications")

if epic_required == "true":
    if epic_id in {"", "null"} or story_id in {"", "null"}:
        raise SystemExit("epic_context_required=true requires parent_epic_id and parent_story_id")
    epic = pathlib.Path(epic_path)
    registry = pathlib.Path(story_registry)
    clar = pathlib.Path(clarifications)
    if not epic.exists():
        raise SystemExit(f"Missing epic path: {epic_path}")
    if not registry.exists():
        raise SystemExit(f"Missing story registry: {story_registry}")
    if not clar.exists():
        raise SystemExit(f"Missing epic clarifications: {clarifications}")
    story_rows = [line for line in registry.read_text().splitlines() if f'"id":"{story_id}"' in line]
    if not story_rows:
        raise SystemExit(f"Story not found in registry: {story_id}")
    story_record = json.loads(story_rows[0])
    if not story_record.get("acceptance"):
        raise SystemExit(f"Story acceptance empty: {story_id}")
    epic_text = epic.read_text()

    def section_body(text, header):
        match = re.search(rf"{re.escape(header)}\n\n(.*?)(?=\n## |\Z)", text, re.S)
        return match.group(1).strip() if match else ""

    def has_placeholder(text):
        placeholders = (
            "Describe the",
            "TODO",
            "TBD",
            "Fix latest",
            "Describe outcome",
            "Explain the",
        )
        return any(token in text for token in placeholders)

    required_sections = ["## Goal", "## Scope", "## Acceptance Summary"]
    for section in required_sections:
        body = section_body(epic_text, section)
        if not body:
            raise SystemExit(f"Missing epic section: {section}")
        if has_placeholder(body):
            raise SystemExit(f"Epic section still placeholder: {section}")
    clar_text = clar.read_text()
    if "## Blocking Questions" in clar_text:
        block_body = clar_text.split("## Blocking Questions", 1)[1].split("##", 1)[0]
        if "- " in block_body:
            raise SystemExit(f"Blocking questions remain in {clarifications}")
    if has_placeholder(clar_text):
        raise SystemExit(f"Clarifications still placeholder text: {clarifications}")

if task_required == "true" and not task_id:
    raise SystemExit("spec_clarification_required=true requires a task_id")
PY

if [ "$mode" = "write-evidence" ]; then
  {
    echo "# Spec Clarification"
    echo
    echo "task_id: $task_id"
    echo "result: CLEAR"
    echo "unresolved_blocking_questions: 0"
    echo "checked_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Status"
    echo
    echo "- epic_context_required: $epic_required"
    echo "- spec_clarification_required: $task_required"
    echo "- parent_epic_id: ${epic_id:-none}"
    echo "- parent_story_id: ${story_id:-none}"
    echo "- epic_path: ${epic_path:-none}"
    echo "- story_registry: ${story_registry:-none}"
    echo "- epic_clarifications: ${clarifications:-none}"
    echo
    echo "## Result"
    echo
    echo "Spec clarification checks passed with no blocking questions."
  } > "$file"
fi

[ -f "$file" ] || fail "Missing spec clarification evidence: $file"
grep -q '^result:[[:space:]]*CLEAR$' "$file" || fail "Spec clarification evidence is not clear: $file"
grep -q '^unresolved_blocking_questions:[[:space:]]*0$' "$file" || fail "Spec clarification evidence still has blocking questions: $file"

echo "Spec clarification checks passed."
