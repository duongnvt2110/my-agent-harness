#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-file-map.sh [--root <dir>] [--baseline-ref <ref>] [--baseline-snapshot <file>]

Validate file changes against the approved scope.
EOF
}

root="$HARNESS_REPO_ROOT"
root_explicit="false"
baseline_ref=""
baseline_snapshot=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      root="${2:-}"
      root_explicit="true"
      shift 2
      ;;
    --baseline-ref)
      baseline_ref="${2:-}"
      shift 2
      ;;
    --baseline-snapshot)
      baseline_snapshot="${2:-}"
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

violation_fail() {
  local message="$1"
  local dir packet
  dir="$(evidence_dir)"
  packet="$dir/file-map-violation.md"
  mkdir -p "$dir"
  {
    echo "# File Map Violation"
    echo
    echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
    echo "result: fail"
    echo "detected_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Violation"
    echo
    echo "$message"
    echo
    echo "## Resolution"
    echo
    echo "Use scripts/resolve-file-map-violation.sh with an explicit action and exact path,"
    echo "or request a human-approved scope expansion."
  } > "$packet"
  fail "$message"
}

decision_file="$(evidence_dir)/baseline-decision.md"
if [ -f "$decision_file" ]; then
  change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
  if [ "$root_explicit" = "false" ]; then
    decision_root="$(awk -F: '/^repo_root:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
    [ -n "$decision_root" ] || fail "Baseline decision missing repo_root: $decision_file"
    root="$decision_root"
  fi
  case "$change_tracking" in
    git)
      baseline_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
      ;;
    snapshot)
      baseline_snapshot="$(awk -F: '/^snapshot_path:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
      ;;
    *) fail "Invalid change_tracking in baseline decision: $change_tracking" ;;
  esac
fi

baseline_ref="${baseline_ref:-$(fm_value "$PLAN_PATH" "baseline_ref")}"
if [ -n "$baseline_snapshot" ]; then
  [ -f "$baseline_snapshot" ] || fail "Missing baseline snapshot: $baseline_snapshot"
  ./scripts/check-baseline-snapshot.sh --task "$(fm_value "$PLAN_PATH" "task_id")" --snapshot "$baseline_snapshot" >/dev/null
  baseline_ref=""
elif [ -n "$baseline_ref" ] && [ "$baseline_ref" != "null" ]; then
  git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "File-map enforcement requires a Git repository"
  git -C "$root" rev-parse --verify "$baseline_ref" >/dev/null 2>&1 || fail "baseline_ref is not a valid Git ref: $baseline_ref"
else
  fail "Missing baseline_ref or baseline_snapshot"
fi

approved_files=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  approved_files+=("$line")
done < <(fm_list "$PLAN_PATH" "approved_files")

approved_deletions=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  approved_deletions+=("$line")
done < <(fm_list "$PLAN_PATH" "approved_deletions")

approved_scopes=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  approved_scopes+=("$line")
done < <(fm_list "$PLAN_PATH" "approved_scopes")

scope_patterns_list=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  scope_patterns_list+=("$line")
done < <(expand_scopes "${approved_scopes[@]}")

allowed_patterns=("${scope_patterns_list[@]}")
if [ "${#approved_files[@]}" -gt 0 ]; then
  allowed_patterns+=("${approved_files[@]}")
fi

check_path() {
  local status="$1"
  local path="$2"
  case "$path" in
    .DS_Store|*/.DS_Store)
      return 0
      ;;
  esac
  case "$path" in
    .agent-harness/*)
      path="${path#.agent-harness/}"
      ;;
  esac
  case "$path" in
    docs/exec-plans/active/current.md)
      return 0
      ;;
  esac
  if [ "$status" = "D" ]; then
    if ! matches_any_pattern "$path" "${allowed_patterns[@]}"; then
      if [ "${#approved_deletions[@]}" -gt 0 ] && matches_any_pattern "$path" "${approved_deletions[@]}"; then
        return 0
      fi
      violation_fail "Deleted file outside approved scopes/deletions: $path"
    fi
  else
    matches_any_pattern "$path" "${allowed_patterns[@]}" || violation_fail "Changed file outside approved scope/files: $path"
  fi
}

if [ -n "$baseline_ref" ]; then
  while IFS=$'\t' read -r status path rest; do
    [ -n "${status:-}" ] || continue
    case "$path" in
      .agent-harness/*)
        path="${path#.agent-harness/}"
        ;;
    esac
    check_path "$status" "$path"
  done < <(git -C "$root" diff --name-status "$baseline_ref" --)

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    status="${line%% *}"
    path="${line#?? }"
    [ "$status" = "??" ] || continue
    case "$path" in
      .agent-harness/*)
        path="${path#.agent-harness/}"
        ;;
    esac
    case "$path" in
      docs/exec-plans/active/current.md)
        continue
        ;;
    esac
    matches_any_pattern "$path" "${allowed_patterns[@]}" || violation_fail "Untracked file outside approved scope/files: $path"
  done < <(git -C "$root" status --porcelain --untracked-files=all --no-renames)
else
  snapshot_args=("$root" "$baseline_snapshot" "${#allowed_patterns[@]}")
  if [ "${#allowed_patterns[@]}" -gt 0 ]; then
    snapshot_args+=("${allowed_patterns[@]}")
  fi
  if [ "${#approved_deletions[@]}" -gt 0 ]; then
    snapshot_args+=("${approved_deletions[@]}")
  fi
  python3 - "${snapshot_args[@]}" <<'PY'
import hashlib
import os
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
snapshot_path = pathlib.Path(sys.argv[2])
allowed_count = int(sys.argv[3])
allowed_patterns = sys.argv[4:4 + allowed_count]
approved_deletions = sys.argv[4 + allowed_count:]

def matches(path, patterns):
    import fnmatch
    return any(fnmatch.fnmatch(path, pattern) for pattern in patterns)

snapshot = {}
for entry in __import__("json").loads(snapshot_path.read_text()).get("files", []):
    snapshot[entry["path"]] = entry

current = {}
ignored = {
    ".git",
    "node_modules",
    "vendor",
    "dist",
    "build",
    "tmp",
    "__pycache__",
}
def harness_relative(rel):
    prefix = ".agent-harness/"
    return rel[len(prefix):] if rel.startswith(prefix) else rel

def is_generated_harness_state(rel):
    logical = harness_relative(rel)
    return logical.startswith("docs/evidence/") or logical == "docs/exec-plans/active/current.md"

def ensure_traversable(path):
    mode = path.stat(follow_symlinks=False).st_mode
    if mode & 0o444 == 0 or mode & 0o111 == 0:
        raise PermissionError(f"Snapshot directory is not readable and searchable: {path}")

def raise_walk_error(error):
    raise error

def record_path(path, rel):
    if path.is_symlink():
        link_bytes = os.fsencode(os.readlink(path))
        current[rel] = {
            "sha256": hashlib.sha256(link_bytes).hexdigest(),
            "type": "symlink",
        }
        return
    if path.is_file():
        current[rel] = {
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "type": "file",
        }

ensure_traversable(root)
for current_root, dirs, filenames in os.walk(root, onerror=raise_walk_error):
    current_path = pathlib.Path(current_root)
    kept_dirs = []
    for dirname in dirs:
        path = current_path / dirname
        rel = path.relative_to(root).as_posix()
        if dirname in ignored:
            continue
        if path.is_symlink():
            if not is_generated_harness_state(rel):
                record_path(path, rel)
            continue
        ensure_traversable(path)
        kept_dirs.append(dirname)
    dirs[:] = kept_dirs
    for filename in filenames:
        if filename == ".DS_Store":
            continue
        path = current_path / filename
        rel = path.relative_to(root).as_posix()
        if any(part in ignored for part in path.relative_to(root).parts):
            continue
        if is_generated_harness_state(rel):
            continue
        record_path(path, rel)

diffs = []
for rel, entry in snapshot.items():
    cur = current.get(rel)
    if cur is None:
        diffs.append(("D", rel))
    elif cur["sha256"] != entry["sha256"] or cur["type"] != entry.get("type", "file"):
        diffs.append(("M", rel))
for rel in current:
    if rel not in snapshot:
        diffs.append(("A", rel))

for status, path in diffs:
    if pathlib.PurePosixPath(path).name == ".DS_Store":
        continue
    logical_path = harness_relative(path)
    if status == "D" and matches(logical_path, approved_deletions):
        continue
    if not matches(logical_path, allowed_patterns):
        raise SystemExit(f"Changed file outside approved scope/files: {path}")

print("Snapshot file-map checks passed.")
PY
fi

echo "File-map checks passed."
