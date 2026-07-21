#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/export-harness-package.sh [--mode MODE] [--dry-run] [--output DIR] [--zip FILE] [--allow-no-git]

Export the harness package mirror into an output directory without modifying
the source repository. The exported package keeps the same top-level layout as
the source repo: root docs plus .agent-harness/.
EOF
}

dry_run=false
allow_no_git=false
mode="clean-template"
output_dir=""
output_dir_explicit=false
zip_path=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      mode="${2:-}"
      case "$mode" in clean-template|source-snapshot|audit-snapshot) ;; *) fail "Unsupported export mode: $mode" ;; esac
      shift
      ;;
    --dry-run)
      dry_run=true
      ;;
    --output)
      output_dir="${2:-}"
      [ -n "$output_dir" ] || fail "--output requires a directory"
      output_dir_explicit=true
      shift
      ;;
    --zip)
      zip_path="${2:-}"
      [ -n "$zip_path" ] || fail "--zip requires a file path"
      shift
      ;;
    --allow-no-git)
      allow_no_git=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
  shift
done

repo_name="$(basename "$HARNESS_REPO_ROOT")"
if [ -f "$HARNESS_REPO_ROOT/manifest.json" ]; then
  declared_repo="$(python3 - "$HARNESS_REPO_ROOT/manifest.json" <<'PY_REPO'
import json
import pathlib
import sys
try:
    value = json.loads(pathlib.Path(sys.argv[1]).read_text()).get("repo", "")
except Exception:
    value = ""
if isinstance(value, str) and value.strip():
    print(value.strip())
PY_REPO
)"
  [ -z "$declared_repo" ] || repo_name="$declared_repo"
fi

default_output_dir() {
  if [ -e "$HARNESS_REPO_ROOT/my_docs" ]; then
    local my_docs_real
    my_docs_real="$(realpath "$HARNESS_REPO_ROOT/my_docs")"
    printf '%s\n' "$(dirname "$my_docs_real")/harness-proof/$repo_name/clean-template"
  else
    printf '%s\n' "$HARNESS_REPO_ROOT/harness-proof/$repo_name/clean-template"
  fi
}

if [ -z "$output_dir" ]; then
  output_dir="$(default_output_dir)"
fi

if [ -n "$zip_path" ] && [ "$output_dir_explicit" = false ]; then
  output_dir="$(mktemp -d)"
fi

output_dir="${output_dir%/}"

has_git=false
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  has_git=true
fi

if [ "$dry_run" = false ] && [ "$has_git" = false ] && [ "$allow_no_git" = false ]; then
  fail "Exporting the harness package requires Git unless --allow-no-git is set"
fi

source_commit="not-available"
git_status_lines=()
if [ "$has_git" = true ]; then
  source_commit="$(git rev-parse HEAD)"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    git_status_lines+=("$line")
  done < <(git status --short)
fi

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_array() {
  local first=true
  local item
  printf '['
  for item in "$@"; do
    if [ "$first" = true ]; then
      first=false
    else
      printf ','
    fi
    printf '\n    "%s"' "$(json_escape "$item")"
  done
  if [ "$first" = false ]; then
    printf '\n'
  fi
  printf ']'
}

write_file() {
  local source="$1"
  local target="$2"
  [ -f "$source" ] || fail "Missing export source file: $source"
  mkdir -p "$(dirname "$target")"
  cp -p "$source" "$target"
}

copy_tree_files() {
  local source_root="$1"
  local target_root="$2"
  [ -d "$source_root" ] || fail "Missing export source directory: $source_root"
  if [ "$source_root" != "$HARNESS_ROOT/docs" ] || [ "$mode" != "clean-template" ]; then
    mkdir -p "$target_root"
    cp -Rp "$source_root/." "$target_root/"
    find "$target_root" -name '.DS_Store' -type f -delete
    find "$target_root" -name '*.pyc' -type f -delete
    find "$target_root" -type d -name '__pycache__' -prune -exec rm -rf {} +
    return
  fi
  while IFS= read -r -d '' source_file; do
    rel="${source_file#"$source_root"/}"
    if [ "$mode" = "clean-template" ] && [ "$source_root" = "$HARNESS_ROOT/docs" ]; then
      case "$rel" in
        exec-plans/active/*|exec-plans/completed/*)
          [ "$(basename "$rel")" = ".gitkeep" ] || continue
          ;;
        exec-plans/recovery/*)
          continue
          ;;
        evidence/*)
          [ "$rel" = "evidence/README.md" ] || continue
          ;;
        reviews/*)
          [ "$rel" = "reviews/TEMPLATE.md" ] || continue
          ;;
        epics/*)
          [ "$rel" = "epics/README.md" ] || continue
          ;;
        reports/*)
          [ "$rel" = "reports/README.md" ] || continue
          ;;
        recovery/*)
          continue
          ;;
        tasks/*|intake/*.md)
          continue
          ;;
      esac
    fi
    target="$target_root/$rel"
    mkdir -p "$(dirname "$target")"
    cp -p "$source_file" "$target"
  done < <(find "$source_root" -type f ! -name '.DS_Store' ! -name '*.pyc' ! -path '*/__pycache__/*' -print0)
}

strip_runtime_state() {
  local root="$1"
  rm -f "$root/.agent-harness/docs/exec-plans/active/current.md"
  find "$root/.agent-harness/docs/exec-plans/completed" -maxdepth 1 -type f -name '*.md' ! -name '.gitkeep' -delete
  find "$root/.agent-harness/docs/evidence" -mindepth 1 -maxdepth 1 -type d ! -name 'README.md' -exec rm -rf {} +
  find "$root/.agent-harness/docs/intake" -maxdepth 1 -type f -name '*.md' -delete
  find "$root/.agent-harness/docs/reviews" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' -delete
  : > "$root/.agent-harness/docs/tasks/tasks.jsonl"
  find "$root" -name '.DS_Store' -type f -delete
  rm -rf "$root/__MACOSX" "$root/.agent-harness/docs/tasks"/*/
}

reset_clean_policy_state() {
  local root="$1"
  local policies="$root/.agent-harness/policies"
  rm -rf "$policies/task-plan-exception-snapshots"
  cat > "$policies/task-plan-exceptions.json" <<'POLICY_EXCEPTIONS'
{
  "schema_version": 1,
  "canonicalization_version": 1,
  "entries": []
}
POLICY_EXCEPTIONS
}

reset_clean_runtime() {
  local root="$1"
  local runtime="$root/.agent-harness/runtime"
  mkdir -p "$runtime"
  cat > "$runtime/state.json" <<'STATE'
{"schema_version":1,"canonicalization_version":1,"run_id":"bootstrap","task_id":"bootstrap","state":"INTAKE","active_function":"intake","updated_at":"1970-01-01T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
STATE
  : > "$runtime/events.jsonl"
  cat > "$runtime/current.md" <<'CURRENT'
---
generated: true
projection_source: state.json
run_id: bootstrap
task_id: bootstrap
state: INTAKE
previous_state: null
event_sequence: 0
---

# Generated Run Projection

This file is read-only derived content. Edit state.json only through
transition-state.
CURRENT
  find "$runtime" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
  find "$runtime" -maxdepth 1 -type f     ! -name 'state.json'     ! -name 'events.jsonl'     ! -name 'current.md'     ! -name 'v3-workflow.json' -delete
}

strip_runtime_locks() {
  local root="$1"
  rm -f "$root/.agent-harness/docs/exec-plans/active/current.md"
  find "$root" \( -name '*.lock' -o -name '*-journal.json' -o -name '.writer-lease.json' \) -type f -delete
  find "$root" -name '.DS_Store' -type f -delete
  find "$root" -type d -name '__pycache__' -prune -exec rm -rf {} +
  find "$root" -type f -name '*.pyc' -delete
}

if [ "$dry_run" = true ]; then
  echo "DRY RUN"
  echo "Export root: $output_dir"
  echo "Git available: $has_git"
  echo "Allow no git: $allow_no_git"
  echo "Mode: $mode"
  echo
  echo "Would export root files:"
  printf '  - %s\n' AGENTS.md README.md WORKFLOW.md CONTEXT.md .gitignore
  echo
  echo "Would export directories:"
  printf '  - %s\n' .agent-harness
  printf '  - %s\n' .agent-harness/runtime .agent-harness/policies .agent-harness/recipes .agent-harness/benchmarks
  echo
  echo "Would create templates:"
  printf '  - %s\n' .agent-harness/docs/epics/README.md
  printf '  - %s\n' .agent-harness/docs/exec-plans/TEMPLATE.md
  printf '  - %s\n' .agent-harness/docs/exec-plans/active/.gitkeep
  printf '  - %s\n' .agent-harness/docs/exec-plans/completed/.gitkeep
  printf '  - %s\n' .agent-harness/docs/evidence/README.md
  printf '  - %s\n' .agent-harness/docs/reviews/TEMPLATE.md
  printf '  - %s\n' .agent-harness/docs/tasks/tasks.jsonl
  exit 0
fi

mkdir -p "$output_dir"

for file in AGENTS.md README.md WORKFLOW.md CONTEXT.md; do
  write_file "$HARNESS_REPO_ROOT/$file" "$output_dir/$file"
done
mkdir -p "$output_dir/.agent-harness"
write_file "$HARNESS_ROOT/harness.sh" "$output_dir/.agent-harness/harness.sh"
copy_tree_files "$HARNESS_ROOT/scripts" "$output_dir/.agent-harness/scripts"
copy_tree_files "$HARNESS_ROOT/docs" "$output_dir/.agent-harness/docs"
copy_tree_files "$HARNESS_ROOT/tests" "$output_dir/.agent-harness/tests"
copy_tree_files "$HARNESS_ROOT/runtime" "$output_dir/.agent-harness/runtime"
copy_tree_files "$HARNESS_ROOT/policies" "$output_dir/.agent-harness/policies"
copy_tree_files "$HARNESS_ROOT/recipes" "$output_dir/.agent-harness/recipes"
if [ -d "$HARNESS_ROOT/benchmarks" ]; then
  copy_tree_files "$HARNESS_ROOT/benchmarks" "$output_dir/.agent-harness/benchmarks"
fi
if [ -f "$HARNESS_REPO_ROOT/.gitignore" ]; then
  write_file "$HARNESS_REPO_ROOT/.gitignore" "$output_dir/.gitignore"
else
  cat > "$output_dir/.gitignore" <<'GITIGNORE'
.DS_Store
__MACOSX/
harness-proof/
GITIGNORE
fi

mkdir -p "$output_dir/.agent-harness/docs/exec-plans/active"
mkdir -p "$output_dir/.agent-harness/docs/exec-plans/completed"
mkdir -p "$output_dir/.agent-harness/docs/tasks"
: > "$output_dir/.agent-harness/docs/exec-plans/active/.gitkeep"
: > "$output_dir/.agent-harness/docs/exec-plans/completed/.gitkeep"
: > "$output_dir/.agent-harness/docs/tasks/tasks.jsonl"

case "$mode" in
  clean-template)
    strip_runtime_state "$output_dir"
    reset_clean_runtime "$output_dir"
    reset_clean_policy_state "$output_dir"
    find "$output_dir/.agent-harness/benchmarks/history" -type f ! -name '.gitkeep' -delete 2>/dev/null || true
    ;;
  source-snapshot|audit-snapshot)
    strip_runtime_locks "$output_dir"
    ;;
esac

manifest_export_root="$output_dir"
if [ "$mode" = "clean-template" ]; then
  manifest_export_root="."
fi

git_status_json="[]"
if [ "${#git_status_lines[@]}" -gt 0 ]; then
  git_status_json="$(json_array "${git_status_lines[@]}")"
fi

cat > "$output_dir/manifest.json" <<EOF
{
  "repo": "$(json_escape "$repo_name")",
  "source_commit": "$(json_escape "$source_commit")",
  "exported_at": "$(json_escape "$(date '+%Y-%m-%d %H:%M:%S %z')")",
  "export_root": "$(json_escape "$manifest_export_root")",
  "mode": "$(json_escape "$mode")",
  "git_status_before_export": $git_status_json,
  "template_files": $(json_array AGENTS.md README.md WORKFLOW.md CONTEXT.md .gitignore .agent-harness/scripts .agent-harness/docs .agent-harness/tests .agent-harness/runtime .agent-harness/policies .agent-harness/recipes .agent-harness/benchmarks),
  "placeholder_files": $(json_array .agent-harness/runtime/state.json .agent-harness/runtime/events.jsonl .agent-harness/runtime/current.md .agent-harness/runtime/v3-workflow.json .agent-harness/docs/epics/README.md .agent-harness/docs/exec-plans/TEMPLATE.md .agent-harness/docs/exec-plans/active/.gitkeep .agent-harness/docs/exec-plans/completed/.gitkeep .agent-harness/docs/evidence/README.md .agent-harness/docs/reviews/TEMPLATE.md .agent-harness/docs/tasks/tasks.jsonl)
}
EOF

python3 - "$output_dir/manifest.json" "$output_dir" <<'PY'
import hashlib, json, pathlib, sys
manifest = pathlib.Path(sys.argv[1]); root = pathlib.Path(sys.argv[2])
files = []
for path in sorted(root.rglob("*")):
    if not path.is_file() or path == manifest:
        continue
    rel = path.relative_to(root).as_posix()
    files.append({"path": rel, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
payload = json.loads(manifest.read_text())
payload["manifest_schema_version"] = 1
payload["canonicalization_version"] = 1
payload["files"] = files
payload["package_hash"] = hashlib.sha256(json.dumps(files, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
manifest.write_text(json.dumps(payload, sort_keys=True, indent=2) + "\n")
PY

if [ -n "$zip_path" ]; then
  zip_dir="$(dirname "$zip_path")"
  mkdir -p "$zip_dir"
  if command -v zip >/dev/null 2>&1; then
    (cd "$output_dir" && zip -qr "$zip_path" .)
  else
    fail "zip command is required for --zip"
  fi
fi

echo "Merged harness package into: $output_dir"
if [ -n "$zip_path" ]; then
  echo "Created zip archive: $zip_path"
fi
