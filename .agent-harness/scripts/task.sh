#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

TASK_STORE="${TASK_STORE:-docs/tasks/tasks.jsonl}"
EPIC_ROOT="${EPIC_ROOT:-docs/epics}"

usage() {
  cat <<'EOF'
Usage:
  scripts/task.sh add <task_id> <title>
  scripts/task.sh add <task_id> <title> --epic <epic_id> --story <story_id>
  scripts/task.sh list
  scripts/task.sh ready [--limit N]
  scripts/task.sh activate <task_id>
  scripts/task.sh mark-active <task_id>
  scripts/task.sh mark-in-progress <task_id>
  scripts/task.sh mark-done <task_id> [title]
  scripts/task.sh depends-on <task_id> <dependency_task_id>
  scripts/task.sh validate <task_id>
  scripts/task.sh packet
  scripts/task.sh block <task_id> [title]
EOF
}

ensure_store() {
  mkdir -p "$(dirname "$TASK_STORE")"
  touch "$TASK_STORE"
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

task_exists() {
  local task_id="$1"
  [ -f "$TASK_STORE" ] && grep -q "\"id\":\"$task_id\"" "$TASK_STORE"
}

task_field() {
  local task_id="$1"
  local field="$2"
  awk -v id="$task_id" '
    $0 ~ "\"id\":\"" id "\"" {
      line=$0
      sub(/^.*"/, "", line)
      print line
      exit
    }
  ' "$TASK_STORE"
}

set_task_status() {
  local task_id="$1"
  local next_status="$2"
  local tmp
  task_exists "$task_id" || fail "Unknown task id: $task_id"
  tmp="$(mktemp)"
  awk -v id="$task_id" -v status="$next_status" '
    $0 ~ "\"id\":\"" id "\"" {
      sub(/"status":"[^"]*"/, "\"status\":\"" status "\"")
    }
    {print}
  ' "$TASK_STORE" > "$tmp"
  mv "$tmp" "$TASK_STORE"
}

set_task_fields() {
  local task_id="$1"
  local epic_id="$2"
  local story_id="$3"
  local tmp
  task_exists "$task_id" || fail "Unknown task id: $task_id"
  tmp="$(mktemp)"
  awk -v id="$task_id" -v epic_id="$epic_id" -v story_id="$story_id" '
    function replace_field(line, field, value) {
      gsub("\"" field "\":\"[^\"]*\"", "\"" field "\":\"" value "\"", line)
      return line
    }
    $0 ~ "\"id\":\"" id "\"" {
      if (epic_id != "") {
        $0 = replace_field($0, "epic_id", epic_id)
      }
      if (story_id != "") {
        $0 = replace_field($0, "story_id", story_id)
      }
    }
    {print}
  ' "$TASK_STORE" > "$tmp"
  mv "$tmp" "$TASK_STORE"
}

upsert_task_status() {
  local task_id="$1"
  local next_status="$2"
  local title="${3:-$task_id}"
  local epic_id="${4:-}"
  local story_id="${5:-}"

  ensure_store
  if task_exists "$task_id"; then
    set_task_status "$task_id" "$next_status"
    if [ -n "$epic_id" ] || [ -n "$story_id" ]; then
      set_task_fields "$task_id" "$epic_id" "$story_id"
    fi
    return
  fi

  printf '{"id":"%s","epic_id":"%s","story_id":"%s","title":"%s","status":"%s","depends_on":[],"priority":"normal","lane":"normal"}\n' \
    "$task_id" "$(json_escape "$epic_id")" "$(json_escape "$story_id")" "$(json_escape "$title")" "$next_status" >> "$TASK_STORE"
}

story_task_line() {
  local task_id="$1"
  awk -v id="$task_id" '
    $0 ~ "\"id\":\"" id "\"" { print; exit }
  ' "$TASK_STORE"
}

task_title() {
  local task_id="$1"
  task_field "$task_id" title | sed -n 's/^.*"title":"\([^"]*\)".*$/\1/p'
}

task_record_json() {
  local task_id="$1"
  awk -v id="$task_id" '
    $0 ~ "\"id\":\"" id "\"" { print; exit }
  ' "$TASK_STORE"
}

validate_task_record() {
  local task_id="$1"
  python3 - "$TASK_STORE" "$task_id" "$EPIC_ROOT" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
epic_root = pathlib.Path(sys.argv[3])
records = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    raise SystemExit(f"Unknown task id: {task_id}")

# The v3 task graph may retain older task artifacts for historical evidence,
# but activation must never select one of those artifacts as live authority.
source_plan = record.get("source_plan_path")
implementation_plan = record.get("implementation_plan_path")
if not source_plan or not implementation_plan:
    raise SystemExit(f"Task {task_id} is not a complete v3 task artifact")
source_path = pathlib.Path(source_plan)
implementation_path = pathlib.Path(implementation_plan)
if not source_path.is_absolute():
    source_path = epic_root.parent / source_path
if not implementation_path.is_absolute():
    implementation_path = epic_root.parent / implementation_path
if not source_path.is_file() or not implementation_path.is_file():
    raise SystemExit(f"Task {task_id} references missing v3 task artifacts")
source_text = source_path.read_text()
implementation_text = implementation_path.read_text()
if "v3" not in source_text.lower():
    raise SystemExit(f"Task {task_id} source plan is not v3-authoritative")
if any(marker in implementation_text for marker in ("workflow_version: 1", "workflow_version: 2", "workflow_version: v1", "workflow_version: v2")):
    raise SystemExit(f"Task {task_id} implementation plan selects a legacy workflow artifact")

epic_id = record.get("epic_id", "")
story_id = record.get("story_id", "")
if epic_id:
    if not story_id:
        raise SystemExit(f"Task {task_id} has epic_id but no story_id")
    epic_dir = epic_root / epic_id
    if not epic_dir.exists():
        raise SystemExit(f"Missing epic: {epic_dir}")
    story_registry = epic_dir / "stories.jsonl"
    if not story_registry.exists():
        raise SystemExit(f"Missing story registry: {story_registry}")
    story_rows = [json.loads(line) for line in story_registry.read_text().splitlines() if line.strip()]
    story = next((row for row in story_rows if row.get("id") == story_id), None)
    if story is None:
        raise SystemExit(f"Story not found in registry: {story_id}")
    if not story.get("acceptance"):
        raise SystemExit(f"Story acceptance empty: {story_id}")

deps = record.get("depends_on", [])
if not isinstance(deps, list):
    raise SystemExit(f"Task dependencies malformed: {task_id}")
for dep in deps:
    dep_record = next((row for row in records if row.get("id") == dep), None)
    if dep_record is None:
        raise SystemExit(f"Unknown dependency task id: {dep}")
    if dep_record.get("status") != "DONE":
        raise SystemExit(f"Dependency not done: {dep}")
PY
}

add_task_dependencies() {
  local task_id="$1"
  shift
  python3 - "$TASK_STORE" "$task_id" "$@" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
deps = sys.argv[3:]
records = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    raise SystemExit(f"Unknown task id: {task_id}")
current = record.setdefault("depends_on", [])
if not isinstance(current, list):
    raise SystemExit(f"Task dependencies malformed: {task_id}")
for dep in deps:
    if dep not in current:
        current.append(dep)
store.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in records) + "\n")
PY
}

cmd="${1:-}"
shift || true

case "$cmd" in
  add)
    task_id="${1:-}"
    title="${2:-}"
    [ -n "$task_id" ] && [ -n "$title" ] || { usage; exit 1; }
    require_full_context
    [[ "$task_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "task_id must be lowercase snake_case: $task_id"
    epic_id=""
    story_id=""
    shift 2 || true
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --epic)
          epic_id="${2:-}"
          shift 2
          ;;
        --story)
          story_id="${2:-}"
          shift 2
          ;;
        *)
          usage
          exit 1
          ;;
      esac
    done
    if [ -n "$epic_id" ] || [ -n "$story_id" ]; then
      [ -n "$epic_id" ] && [ -n "$story_id" ] || fail "add with --epic requires --story"
      [ -d "$EPIC_ROOT/$epic_id" ] || fail "Missing epic: $EPIC_ROOT/$epic_id"
      [ -f "$EPIC_ROOT/$epic_id/stories.jsonl" ] || fail "Missing story registry: $EPIC_ROOT/$epic_id/stories.jsonl"
      python3 - "$EPIC_ROOT/$epic_id/stories.jsonl" "$story_id" <<'PY'
import json
import pathlib
import sys

story_registry = pathlib.Path(sys.argv[1])
story_id = sys.argv[2]
rows = [json.loads(line) for line in story_registry.read_text().splitlines() if line.strip()]
story = next((row for row in rows if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Story not found in registry: {story_id}")
if not story.get("acceptance"):
    raise SystemExit(f"Story acceptance empty: {story_id}")
PY
    fi
    ensure_store
    task_exists "$task_id" && fail "Task already exists: $task_id"
    printf '{"id":"%s","epic_id":"%s","story_id":"%s","title":"%s","status":"READY","depends_on":[],"priority":"normal","lane":"normal"}\n' \
      "$task_id" "$(json_escape "$epic_id")" "$(json_escape "$story_id")" "$(json_escape "$title")" >> "$TASK_STORE"
    echo "Added task: $task_id"
    ;;
  list)
    ensure_store
    awk -F'"' '
      /"id":/ {
        id=$4
        epic_id=$8
        story_id=$12
        title=$16
        status=$20
        print id "\t" status "\t" epic_id "\t" story_id "\t" title
      }
    ' "$TASK_STORE"
    ;;
  ready)
    ensure_store
    limit=10
    if [ "${1:-}" = "--limit" ]; then
      limit="${2:-10}"
    fi
    awk -v limit="$limit" '
      /"status":"READY"/ {print; count++}
      count >= limit {exit}
    ' "$TASK_STORE"
    ;;
  activate)
    task_id="${1:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    # Decomposed backlog activation may happen before an active plan exists.
    # Keep full-context enforcement only for legacy plan-driven activation.
    if [ -f "$PLAN_PATH" ]; then
      require_full_context
    fi
    ensure_store
    task_exists "$task_id" || fail "Unknown task id: $task_id"
    validate_task_record "$task_id"
    python3 - "$TASK_STORE" "$task_id" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
records = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    raise SystemExit(f"Unknown task id: {task_id}")
for dep in record.get("depends_on", []):
    dep_record = next((row for row in records if row.get("id") == dep), None)
    if dep_record is None:
        raise SystemExit(f"Unknown dependency task id: {dep}")
    if dep_record.get("status") != "DONE":
        raise SystemExit(f"Dependency not done: {dep}")
PY
    title="$(task_title "$task_id")"
    [ -n "$title" ] || title="$task_id"
    ./scripts/create-active-plan.sh "$task_id" "$title"
    upsert_task_status "$task_id" "ACTIVE" "$title"
    ;;
  mark-active)
    task_id="${1:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    ensure_store
    title="$(task_title "$task_id")"
    [ -n "$title" ] || title="$task_id"
    upsert_task_status "$task_id" "ACTIVE" "$title"
    ;;
  mark-in-progress)
    task_id="${1:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    ensure_store
    title="$(task_title "$task_id")"
    [ -n "$title" ] || title="$task_id"
    upsert_task_status "$task_id" "IN_PROGRESS" "$title"
    ;;
  packet)
    if [ -f "$PLAN_PATH" ]; then
      ./scripts/harness.sh next
    else
      echo "TASK PACKET"
      echo
      echo "Active task: missing"
      echo "Ready tasks:"
      "$0" ready --limit 10
    fi
    ;;
  mark-done)
    task_id="${1:-}"
    title="${2:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    [ "${HARNESS_INTERNAL_FINALIZATION:-0}" = "1" ] || fail "Direct task completion is denied; use the harness finalization path"
    journal="${HARNESS_FINALIZATION_JOURNAL:-}"
    [ -f "$journal" ] || fail "Internal finalization journal is required"
    python3 - "$journal" "$task_id" <<'PY'
import json
import pathlib
import sys

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
if data.get("status") != "FINALIZING":
    raise SystemExit("task projection requires a FINALIZING journal")
if data.get("task_id") != sys.argv[2]:
    raise SystemExit("task projection journal task mismatch")
PY
    upsert_task_status "$task_id" "DONE" "$title"
    echo "Marked done: $task_id"
    ;;
  depends-on)
    task_id="${1:-}"
    dependency_task_id="${2:-}"
    [ -n "$task_id" ] && [ -n "$dependency_task_id" ] || { usage; exit 1; }
    ensure_store
    task_exists "$task_id" || fail "Unknown task id: $task_id"
    task_exists "$dependency_task_id" || fail "Unknown dependency task id: $dependency_task_id"
    add_task_dependencies "$task_id" "$dependency_task_id"
    echo "Added dependency: $task_id -> $dependency_task_id"
    ;;
  validate)
    task_id="${1:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    ensure_store
    validate_task_record "$task_id"
    echo "Task validation passed: $task_id"
    ;;
  block)
    task_id="${1:-}"
    title="${2:-}"
    [ -n "$task_id" ] || { usage; exit 1; }
    upsert_task_status "$task_id" "BLOCKED" "$title"
    echo "Blocked task: $task_id"
    ;;
  *)
    usage
    exit 1
    ;;
esac
