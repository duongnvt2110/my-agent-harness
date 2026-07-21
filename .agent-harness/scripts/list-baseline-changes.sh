#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

format="name-status"
case "${1:-}" in
  "") ;;
  --format)
    format="${2:-}"
    ;;
  -h|--help)
    echo "Usage: scripts/list-baseline-changes.sh [--format name-status|name-only]"
    exit 0
    ;;
  *) fail "Unknown argument: $1" ;;
esac

case "$format" in
  name-status|name-only) ;;
  *) fail "Invalid format: $format" ;;
esac

decision="$(evidence_dir)/baseline-decision.md"
if [ -f "$decision" ]; then
  change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
  repo_root="$(awk -F: '/^repo_root:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
  [ -n "$repo_root" ] || fail "Baseline decision missing repo_root: $decision"
else
  change_tracking="git"
  repo_root="$HARNESS_REPO_ROOT"
  legacy_git_ref="$(fm_value "$PLAN_PATH" "baseline_ref")"
  [ -n "$legacy_git_ref" ] && [ "$legacy_git_ref" != "null" ] || \
    fail "Missing baseline decision and legacy baseline_ref: $decision"
fi

case "$change_tracking" in
  git)
    if [ -f "$decision" ]; then
      git_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
    else
      git_ref="$legacy_git_ref"
    fi
    [ -n "$git_ref" ] && [ "$git_ref" != "null" ] || fail "Git baseline decision missing git_ref"
    git -C "$repo_root" rev-parse --verify "$git_ref" >/dev/null 2>&1 || \
      fail "Git baseline is not a valid ref: $git_ref"
    if [ "$format" = "name-only" ]; then
      git -C "$repo_root" diff --name-only "$git_ref" --
      git -C "$repo_root" status --porcelain --untracked-files=all | sed -n 's/^?? //p'
    else
      git -C "$repo_root" diff --name-status "$git_ref" --
      git -C "$repo_root" status --porcelain --untracked-files=all | sed -n 's/^?? /A\t/p'
    fi
    ;;
  snapshot)
    snapshot="$(awk -F: '/^snapshot_path:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
    [ -f "$snapshot" ] || fail "Missing baseline snapshot: $snapshot"
    python3 - "$repo_root" "$snapshot" "$format" <<'PY'
import hashlib
import json
import os
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
snapshot_path = pathlib.Path(sys.argv[2])
output_format = sys.argv[3]
ignored = {".git", "node_modules", "vendor", "dist", "build", "tmp", "__pycache__"}

snapshot = {
    entry["path"]: {"sha256": entry["sha256"], "type": entry.get("type", "file")}
    for entry in json.loads(snapshot_path.read_text()).get("files", [])
}
current = {}

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

def record(path, rel):
    if path.is_symlink():
        value = os.fsencode(os.readlink(path))
        current[rel] = {"sha256": hashlib.sha256(value).hexdigest(), "type": "symlink"}
    elif path.is_file():
        current[rel] = {"sha256": hashlib.sha256(path.read_bytes()).hexdigest(), "type": "file"}

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
                record(path, rel)
            continue
        ensure_traversable(path)
        kept_dirs.append(dirname)
    dirs[:] = kept_dirs
    for filename in filenames:
        path = current_path / filename
        rel = path.relative_to(root).as_posix()
        if any(part in ignored for part in path.relative_to(root).parts):
            continue
        if is_generated_harness_state(rel):
            continue
        record(path, rel)

changes = []
for rel, entry in snapshot.items():
    observed = current.get(rel)
    if observed is None:
        changes.append(("D", rel))
    elif observed != entry:
        changes.append(("M", rel))
for rel in current:
    if rel not in snapshot:
        changes.append(("A", rel))

for status, rel in sorted(changes, key=lambda row: row[1]):
    print(rel if output_format == "name-only" else f"{status}\t{rel}")
PY
    ;;
  *)
    fail "Invalid change_tracking in baseline decision: $change_tracking"
    ;;
esac
