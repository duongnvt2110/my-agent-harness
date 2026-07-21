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
  scripts/story.sh add <epic_id> <story_id> "<title>"
  scripts/story.sh list <epic_id>
  scripts/story.sh show <epic_id> <story_id>
  scripts/story.sh ready <epic_id>
  scripts/story.sh complete <epic_id> <story_id>
  scripts/story.sh block <epic_id> <story_id> "<reason>"
  scripts/story.sh acceptance <epic_id> <story_id> "<acceptance>"
  scripts/story.sh depends-on <epic_id> <story_id> <dependency_story_id>
  scripts/story.sh activate <epic_id> <story_id>
EOF
}

validate_id() {
  local value="$1"
  [[ "$value" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "value must be lowercase snake_case: $value"
}

epic_dir() {
  echo "$EPIC_ROOT/$1"
}

story_file() {
  echo "$(epic_dir "$1")/stories.jsonl"
}

story_json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

story_line() {
  local story_id="$1"
  local file="$2"
  awk -v id="$story_id" '
    $0 ~ "\"id\":\"" id "\"" { print; exit }
  ' "$file"
}

story_exists() {
  local epic_id="$1"
  local story_id="$2"
  [ -f "$(story_file "$epic_id")" ] && grep -q "\"id\":\"$story_id\"" "$(story_file "$epic_id")"
}

update_story_json() {
  local epic_id="$1"
  local story_id="$2"
  local python_snippet="$3"
  python3 - "$(story_file "$epic_id")" "$story_id" <<PY
import json
import pathlib
import sys

story_file = pathlib.Path(sys.argv[1])
story_id = sys.argv[2]
rows = [json.loads(line) for line in story_file.read_text().splitlines() if line.strip()]
story = next((row for row in rows if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Unknown story id: {story_id}")
$python_snippet
story_file.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in rows) + "\n")
PY
}

update_story_status() {
  local file="$1"
  local story_id="$2"
  local next_status="$3"
  local reason="${4:-}"
  local tmp
  tmp="$(mktemp)"
  awk -v id="$story_id" -v status="$next_status" -v reason="$reason" '
    function replace_field(line, field, value) {
      gsub("\"" field "\":\"[^\"]*\"", "\"" field "\":\"" value "\"", line)
      return line
    }
    $0 ~ "\"id\":\"" id "\"" {
      $0 = replace_field($0, "status", status)
      if (reason != "") {
        $0 = replace_field($0, "notes", reason)
      }
    }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  add)
    epic_id="${1:-}"
    story_id="${2:-}"
    title="${3:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] && [ -n "$title" ] || { usage; exit 1; }
    require_full_context
    validate_id "$epic_id"
    validate_id "$story_id"
    dir="$(epic_dir "$epic_id")"
    [ -d "$dir" ] || fail "Missing epic: $dir"
    file="$(story_file "$epic_id")"
    touch "$file"
    grep -q "\"id\":\"$story_id\"" "$file" && fail "Story already exists: $story_id"
    printf '{"id":"%s","title":"%s","status":"READY","depends_on":[],"acceptance":[],"notes":""}\n' \
      "$story_id" "$(story_json_escape "$title")" >> "$file"
    echo "Added story: $epic_id/$story_id"
    ;;
  list)
    epic_id="${1:-}"
    [ -n "$epic_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    awk -F'"' '
      $0 ~ /"id":/ {
        id=$4
        title=$8
        status=$12
        print id "\t" status "\t" title
      }
    ' "$file"
    ;;
  show)
    epic_id="${1:-}"
    story_id="${2:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    story_line "$story_id" "$file"
    ;;
  ready)
    epic_id="${1:-}"
    [ -n "$epic_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    awk -F'"' '
      $0 ~ /"id":/ {
        id=$4
        title=$8
        status=$12
        if (status == "READY") {
          print id "\t" status "\t" title
        }
      }
    ' "$file"
    ;;
  complete)
    epic_id="${1:-}"
    story_id="${2:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    python3 - "$TASK_STORE" "$epic_id" "$story_id" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
epic_id = sys.argv[2]
story_id = sys.argv[3]
rows = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]
for row in rows:
    if row.get("epic_id") == epic_id and row.get("story_id") == story_id and row.get("status") != "DONE":
        raise SystemExit(f"Story has unfinished task: {row.get('id')}")
PY
    update_story_status "$file" "$story_id" "DONE"
    if [ -x ./scripts/update-epic-progress.sh ]; then
      EPIC_ROOT="$EPIC_ROOT" ./scripts/update-epic-progress.sh "$epic_id"
    fi
    echo "Completed story: $epic_id/$story_id"
    ;;
  block)
    epic_id="${1:-}"
    story_id="${2:-}"
    reason="${3:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] && [ -n "$reason" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    update_story_status "$file" "$story_id" "BLOCKED" "$reason"
    if [ -x ./scripts/update-epic-progress.sh ]; then
      EPIC_ROOT="$EPIC_ROOT" ./scripts/update-epic-progress.sh "$epic_id"
    fi
    echo "Blocked story: $epic_id/$story_id"
    ;;
  acceptance)
    epic_id="${1:-}"
    story_id="${2:-}"
    acceptance_text="${3:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] && [ -n "$acceptance_text" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    python3 - "$file" "$story_id" "$acceptance_text" <<'PY'
import json
import pathlib
import sys

file = pathlib.Path(sys.argv[1])
story_id = sys.argv[2]
acceptance_text = sys.argv[3]
rows = [json.loads(line) for line in file.read_text().splitlines() if line.strip()]
story = next((row for row in rows if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Unknown story id: {story_id}")
acceptance = story.setdefault("acceptance", [])
if acceptance_text not in acceptance:
    acceptance.append(acceptance_text)
file.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in rows) + "\n")
PY
    echo "Added story acceptance: $epic_id/$story_id"
    ;;
  depends-on)
    epic_id="${1:-}"
    story_id="${2:-}"
    dependency_story_id="${3:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] && [ -n "$dependency_story_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    grep -q "\"id\":\"$dependency_story_id\"" "$file" || fail "Unknown dependency story id: $dependency_story_id"
    python3 - "$file" "$story_id" "$dependency_story_id" <<'PY'
import json
import pathlib
import sys

file = pathlib.Path(sys.argv[1])
story_id = sys.argv[2]
dependency_story_id = sys.argv[3]
rows = [json.loads(line) for line in file.read_text().splitlines() if line.strip()]
story = next((row for row in rows if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Unknown story id: {story_id}")
depends_on = story.setdefault("depends_on", [])
if dependency_story_id not in depends_on:
    depends_on.append(dependency_story_id)
file.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in rows) + "\n")
PY
    echo "Added story dependency: $epic_id/$story_id -> $dependency_story_id"
    ;;
  activate)
    epic_id="${1:-}"
    story_id="${2:-}"
    [ -n "$epic_id" ] && [ -n "$story_id" ] || { usage; exit 1; }
    file="$(story_file "$epic_id")"
    [ -f "$file" ] || fail "Missing story registry: $file"
    python3 - "$TASK_STORE" "$file" "$story_id" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
story_file = pathlib.Path(sys.argv[2])
story_id = sys.argv[3]
stories = [json.loads(line) for line in story_file.read_text().splitlines() if line.strip()]
story = next((row for row in stories if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Unknown story id: {story_id}")
tasks = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]
for dep in story.get("depends_on", []):
    dep_story = next((row for row in stories if row.get("id") == dep), None)
    if dep_story is None:
        raise SystemExit(f"Unknown dependency story id: {dep}")
    if dep_story.get("status") != "DONE":
        raise SystemExit(f"Dependency story not complete: {dep}")
PY
    update_story_status "$file" "$story_id" "ACTIVE"
    progress_file="$(epic_dir "$epic_id")/progress.md"
    [ -f "$progress_file" ] || fail "Missing epic progress file: $progress_file"
    {
      echo
      echo "## Active Story"
      echo
      echo "$story_id"
    } >> "$progress_file"
    echo "Activated story: $epic_id/$story_id"
    ;;
  *)
    usage
    exit 1
    ;;
esac
