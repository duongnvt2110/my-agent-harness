#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/create-behavior-baseline.sh --task <task_id> --mode <existing_tests|characterization|approval_snapshot|none> [--root <dir>]

Create behavior baseline evidence.
EOF
}

task_id=""
mode=""
root="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --root)
      root="${2:-}"
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

[ -n "$task_id" ] || fail "Missing --task <task_id>"
[ -n "$mode" ] || fail "Missing --mode"

dir="$(evidence_dir)"
mkdir -p "$dir"

behavior_file="$dir/behavior-baseline.md"
approval_snapshot_file="$dir/approval-snapshot.md"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

find_test_files() {
  python3 - "$root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
found = []
for path in root.rglob("*"):
    if not path.is_file():
        continue
    rel = path.relative_to(root).as_posix()
    if rel.startswith(".git/"):
        continue
    if rel.startswith("docs/evidence/"):
        continue
    if rel.startswith("node_modules/") or rel.startswith("vendor/"):
        continue
    if rel.startswith("dist/") or rel.startswith("build/") or rel.startswith("tmp/"):
        continue
    name = path.name
    if rel.startswith("tests/") or name.endswith("_test.go") or name.endswith(".test.js") or name.endswith(".test.ts") or name.endswith(".test.sh") or name.endswith(".test.py") or name.endswith("_test.py"):
        found.append(rel)

for rel in sorted(found):
    print(rel)
PY
}

tests="$(find_test_files)"

case "$mode" in
  existing_tests|none)
    {
      echo "# Behavior Baseline"
      echo
      echo "task_id: $task_id"
      echo "behavior_tracking: $mode"
      echo "created_before_execution: true"
      echo "behavior_baseline_path: $behavior_file"
      echo
      echo "## Existing Behavior To Preserve"
      echo
      if [ "$mode" = "none" ]; then
        echo "- No behavior baseline is required for this task."
      else
        echo "- Preserve the behavior covered by the existing regression tests."
      fi
      echo
      echo "## Existing Tests"
      echo
      if [ -n "$tests" ]; then
        printf '%s\n' "$tests" | sed 's/^/- /'
      else
        echo "- none detected"
      fi
      echo
      echo "## Required Regression Checks"
      echo
      if [ -n "$tests" ]; then
        echo "- Run the matching targeted tests before final verification."
      else
        echo "- None."
      fi
      echo
      echo "## Gaps"
      echo
      if [ "$mode" = "none" ]; then
        echo "- None."
      elif [ -n "$tests" ]; then
        echo "- None."
      else
        echo "- Existing tests were not detected."
      fi
    } > "$behavior_file"
    ;;
  characterization)
    {
      echo "# Behavior Baseline"
      echo
      echo "task_id: $task_id"
      echo "behavior_tracking: characterization"
      echo "created_before_execution: true"
      echo "behavior_baseline_path: $behavior_file"
      echo
      echo "## Snapshot Targets"
      echo
      echo "- Characterize the current harness behavior before edits."
      echo
      echo "## Existing Behavior To Preserve"
      echo
      echo "- Preserve the behavior currently observed in the target area."
      echo
      echo "## Existing Tests"
      echo
      if [ -n "$tests" ]; then
        printf '%s\n' "$tests" | sed 's/^/- /'
      else
        echo "- none detected"
      fi
      echo
      echo "## Required Regression Checks"
      echo
      echo "- Add focused regression coverage for the characterized behavior."
      echo
      echo "## Known Gaps"
      echo
      echo "- Existing tests are weak or missing for the target behavior."
    } > "$behavior_file"
    ;;
  approval_snapshot)
    snapshot_targets="$(python3 - "$root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
matches = []
for path in root.rglob("*"):
    if not path.is_file():
        continue
    rel = path.relative_to(root).as_posix()
    if rel.startswith(".git/"):
        continue
    if rel.startswith("docs/evidence/"):
        continue
    if rel.startswith("node_modules/") or rel.startswith("vendor/"):
        continue
    if rel.endswith((".json", ".csv", ".html", ".htm", ".pdf", ".txt")):
        matches.append(rel)
for rel in sorted(matches):
    print(rel)
PY
)"
    {
      echo "# Approval Snapshot"
      echo
      echo "task_id: $task_id"
      echo "behavior_tracking: approval_snapshot"
      echo "created_before_execution: true"
      echo "approval_snapshot_path: $approval_snapshot_file"
      echo
      echo "## Snapshot Targets"
      echo
      if [ -n "$snapshot_targets" ]; then
        printf '%s\n' "$snapshot_targets" | sed 's/^/- /'
      else
        echo "- none detected"
      fi
      echo
      echo "## Approved Behavior"
      echo
      echo "- Pending human approval."
      echo
      echo "## Approval Status"
      echo
      echo "approved: false"
      echo "approved_by:"
      echo "approved_at:"
    } > "$approval_snapshot_file"
    cat > "$behavior_file" <<EOF
# Behavior Baseline

task_id: $task_id
behavior_tracking: approval_snapshot
created_before_execution: true
behavior_baseline_path: $behavior_file
approval_snapshot_path: $approval_snapshot_file

## Existing Behavior To Preserve

- Preserve the snapshot targets recorded in the approval snapshot.

## Existing Tests

- none detected

## Required Regression Checks

- Verify the approval snapshot file exists and remains unapproved until human review.

## Gaps

- Human approval is required for the generated snapshot.
EOF
    ;;
  *)
    fail "Invalid behavior baseline mode: $mode"
    ;;
esac

echo "Created behavior baseline: $behavior_file"
