#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-behavior-baseline.sh [--task <task_id>]

Validate behavior baseline safety for the active task.
EOF
}

task_id=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$task_id" ] || task_id="$(fm_value "$PLAN_PATH" "task_id")"
dir="$(evidence_dir)"
behavior_file="$dir/behavior-baseline.md"
approval_snapshot="$dir/approval-snapshot.md"

repo_mode="$(fm_value "$PLAN_PATH" "repo_mode")"
touches_existing_behavior="$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"

[ -f "$behavior_file" ] || fail "Missing behavior baseline: $behavior_file"

python3 - "$PLAN_PATH" "$behavior_file" "$approval_snapshot" <<'PY'
import pathlib
import sys

plan = pathlib.Path(sys.argv[1]).read_text()
behavior_file = pathlib.Path(sys.argv[2]).read_text()
approval_snapshot = pathlib.Path(sys.argv[3])

def body_value(content, key):
    for line in content.splitlines():
        if line.startswith(f"{key}:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""

def section_body(text, header):
    lines = text.splitlines()
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

repo_mode = fm_value(plan, "repo_mode")
touches_existing_behavior = fm_value(plan, "task_touches_existing_behavior")

behavior_tracking = body_value(behavior_file, "behavior_tracking")
if behavior_tracking not in {"none", "existing_tests", "characterization", "approval_snapshot"}:
    raise SystemExit(f"Invalid behavior tracking mode: {behavior_tracking!r}")

if repo_mode in {"brownfield", "hybrid"} or touches_existing_behavior == "true":
    if behavior_tracking == "none":
        raise SystemExit("Brownfield or behavior-touching tasks require a behavior baseline")

if behavior_tracking in {"none", "existing_tests"}:
    tests = section_body(behavior_file, "## Existing Tests")
    if behavior_tracking == "existing_tests" and not tests:
        raise SystemExit("existing_tests behavior baseline must list existing tests")
    if behavior_tracking == "none" and not section_body(behavior_file, "## Existing Behavior To Preserve"):
        raise SystemExit("none behavior baseline must still describe the preservation decision")

if behavior_tracking == "characterization":
    if not section_body(behavior_file, "## Known Gaps"):
        raise SystemExit("characterization baseline must list known gaps")
    if not section_body(behavior_file, "## Required Regression Checks"):
        raise SystemExit("characterization baseline must list regression checks")

if behavior_tracking == "approval_snapshot":
    if not approval_snapshot.exists():
        raise SystemExit(f"Missing approval snapshot: {approval_snapshot}")
    approval_text = approval_snapshot.read_text()
    if body_value(approval_text, "approved") != "false":
        raise SystemExit("approval snapshot must remain unapproved until human review")

print("Behavior baseline checks passed.")
PY

echo "Behavior baseline checks passed."
