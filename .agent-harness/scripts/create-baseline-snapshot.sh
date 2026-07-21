#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/create-baseline-snapshot.sh --task <task_id> [--root <dir>] [--snapshot <file>]

Create a snapshot of the current file tree before execution.
EOF
}

task_id=""
root="$HARNESS_REPO_ROOT"
snapshot_path=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    --root)
      root="${2:-}"
      shift 2
      ;;
    --snapshot)
      snapshot_path="${2:-}"
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
snapshot_path="${snapshot_path:-$(evidence_dir)/baseline-snapshot.json}"

python3 - "$task_id" "$root" "$snapshot_path" <<'PY'
import hashlib
import json
import os
import pathlib
import stat
import sys
from datetime import datetime, timezone

task_id = sys.argv[1]
root = pathlib.Path(sys.argv[2]).resolve(strict=True)
snapshot_path = pathlib.Path(os.path.abspath(sys.argv[3]))

if not root.is_dir():
    raise SystemExit(f"Snapshot root is not a directory: {root}")

ignored_prefixes = {
    ".git",
    "node_modules",
    "vendor",
    "dist",
    "build",
    "tmp",
    "__pycache__",
}

ignored_exact = {
    "docs/exec-plans/active/current.md",
}

ignored_evidence_prefix = "docs/evidence/"

files = []

def ensure_traversable(path):
    mode = path.stat(follow_symlinks=False).st_mode
    if mode & 0o444 == 0 or mode & 0o111 == 0:
        raise PermissionError(f"Snapshot directory is not readable and searchable: {path}")

def raise_walk_error(error):
    raise error

def harness_relative(rel):
    prefix = ".agent-harness/"
    return rel[len(prefix):] if rel.startswith(prefix) else rel

def is_generated_harness_state(rel):
    logical = harness_relative(rel)
    return logical in ignored_exact or logical.startswith(ignored_evidence_prefix)

def add_path(path, rel):
    if path.is_symlink():
        link_bytes = os.fsencode(os.readlink(path))
        files.append({
            "path": rel,
            "sha256": hashlib.sha256(link_bytes).hexdigest(),
            "size": len(link_bytes),
            "type": "symlink",
        })
        return
    if not path.is_file():
        return
    files.append({
        "path": rel,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "size": path.stat().st_size,
        "type": "file",
    })

ensure_traversable(root)
for current_root, dirs, filenames in os.walk(root, onerror=raise_walk_error):
    current_path = pathlib.Path(current_root)
    kept_dirs = []
    for dirname in dirs:
        path = current_path / dirname
        rel = path.relative_to(root).as_posix()
        if dirname in ignored_prefixes:
            continue
        if path.is_symlink():
            if not is_generated_harness_state(rel):
                add_path(path, rel)
            continue
        ensure_traversable(path)
        kept_dirs.append(dirname)
    dirs[:] = kept_dirs
    for filename in filenames:
        path = current_path / filename
        try:
            rel = path.relative_to(root).as_posix()
        except ValueError:
            continue
        if is_generated_harness_state(rel):
            continue
        if any(part in ignored_prefixes for part in path.relative_to(root).parts):
            continue
        add_path(path, rel)

files.sort(key=lambda item: item["path"])

payload = {
    "task_id": task_id,
    "mode": "snapshot",
    "created_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "files": files,
}
canonical_payload = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()
payload["snapshot_hash"] = hashlib.sha256(canonical_payload).hexdigest()
payload_bytes = (json.dumps(payload, indent=2, sort_keys=True) + "\n").encode()

if not hasattr(os, "O_NOFOLLOW"):
    raise SystemExit("Safe snapshot creation requires O_NOFOLLOW support")

parent_fd = os.open(snapshot_path.anchor, os.O_RDONLY | os.O_DIRECTORY)
try:
    for component in snapshot_path.parts[1:-1]:
        try:
            os.mkdir(component, mode=0o700, dir_fd=parent_fd)
        except FileExistsError:
            pass
        try:
            before = os.stat(component, dir_fd=parent_fd, follow_symlinks=False)
        except OSError as error:
            raise SystemExit(
                f"Snapshot output parent cannot be inspected safely: {component}: {error}"
            ) from error
        if stat.S_ISLNK(before.st_mode) or not stat.S_ISDIR(before.st_mode):
            raise SystemExit(
                f"Snapshot output parent must be a real directory: {component}"
            )
        try:
            next_fd = os.open(
                component,
                os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                dir_fd=parent_fd,
            )
        except OSError as error:
            raise SystemExit(
                f"Snapshot output parent must be a real directory: {component}: {error}"
            ) from error
        after = os.fstat(next_fd)
        if not stat.S_ISDIR(after.st_mode) or (before.st_dev, before.st_ino) != (after.st_dev, after.st_ino):
            os.close(next_fd)
            raise SystemExit(
                f"Snapshot output parent changed during validation: {component}"
            )
        os.close(parent_fd)
        parent_fd = next_fd

    leaf = snapshot_path.name
    try:
        existing = os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
        if stat.S_ISLNK(existing.st_mode):
            raise SystemExit(f"Refusing symlink snapshot destination: {snapshot_path}")
        if not stat.S_ISREG(existing.st_mode):
            raise SystemExit(f"Snapshot destination is not a regular file: {snapshot_path}")
    except FileNotFoundError:
        pass

    temporary = f".{leaf}.tmp-{os.getpid()}"
    output_fd = None
    try:
        output_fd = os.open(
            temporary,
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
            0o600,
            dir_fd=parent_fd,
        )
        with os.fdopen(output_fd, "wb", closefd=True) as output:
            output_fd = None
            output.write(payload_bytes)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary, leaf, src_dir_fd=parent_fd, dst_dir_fd=parent_fd)
        os.fsync(parent_fd)
    except BaseException:
        if output_fd is not None:
            os.close(output_fd)
        try:
            os.unlink(temporary, dir_fd=parent_fd)
        except FileNotFoundError:
            pass
        raise
finally:
    os.close(parent_fd)
PY

echo "Created baseline snapshot: $snapshot_path"
