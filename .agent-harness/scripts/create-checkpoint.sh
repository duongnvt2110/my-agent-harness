#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

root="${1:-$HARNESS_REPO_ROOT}"
output="${2:-}"
run_id="${3:-}"
risk="${4:-${CHECKPOINT_RISK:-normal}}"
[ -n "$output" ] && [ -n "$run_id" ] || fail "Usage: scripts/create-checkpoint.sh ROOT OUTPUT RUN_ID [RISK]"

python3 - "$root" "$output" "$run_id" "$risk" <<'PY'
from __future__ import annotations
import hashlib, json, os, pathlib, platform, shutil, subprocess, sys, tempfile

root = pathlib.Path(sys.argv[1]).resolve(strict=True)
output = pathlib.Path(sys.argv[2]).resolve()
run_id, risk = sys.argv[3:5]
if output.exists():
    raise SystemExit(f"checkpoint destination already exists: {output}")
ignored = {".git", "node_modules", "vendor", "dist", "build", "tmp", "__pycache__"}
sensitive = {".env", "credentials", "token", "secret"}
bound = {
    "specification_hash": os.environ.get("CHECKPOINT_SPEC_HASH", "UNBOUND"),
    "policy_hash": os.environ.get("CHECKPOINT_POLICY_HASH", "UNBOUND"),
    "workflow_state_hash": os.environ.get("CHECKPOINT_WORKFLOW_STATE_HASH", "UNBOUND"),
    "event_chain_position": os.environ.get("CHECKPOINT_EVENT_CHAIN_POSITION", "UNBOUND"),
    "pending_operations_hash": os.environ.get("CHECKPOINT_PENDING_OPERATIONS_HASH", "UNBOUND"),
}
if risk == "high_risk" and any(value == "UNBOUND" for value in bound.values()):
    raise SystemExit("high-risk checkpoint requires complete authority bindings")
stage = pathlib.Path(tempfile.mkdtemp(prefix="checkpoint-stage-"))
files = []
try:
    payload = stage / "files"
    for current, dirs, names in os.walk(root, followlinks=False):
        current_path = pathlib.Path(current)
        dirs[:] = [item for item in dirs if item not in ignored]
        for name in names:
            source = current_path / name
            rel = source.relative_to(root).as_posix()
            if any(part.lower() in sensitive or part.lower().startswith(".env") for part in pathlib.PurePosixPath(rel).parts):
                raise SystemExit(f"sensitive path prevents safe checkpoint: {rel}")
            target = payload / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            if source.is_symlink():
                target.symlink_to(os.readlink(source))
                raw = os.fsencode(os.readlink(source))
                files.append({"path": rel, "type": "symlink", "state": "unclassified", "sha256": hashlib.sha256(raw).hexdigest(), "size": len(raw)})
            elif source.is_file():
                shutil.copy2(source, target)
                raw = source.read_bytes()
                files.append({"path": rel, "type": "file", "state": "unclassified", "sha256": hashlib.sha256(raw).hexdigest(), "size": len(raw)})
    git = (root / ".git").exists() or (root / ".git").is_file()
    git_status = ""
    base_commit = "not-available"
    tracked = staged = untracked = []
    if git:
        def git_cmd(*args):
            return subprocess.check_output(("git", "-C", str(root), *args), text=True, stderr=subprocess.DEVNULL).splitlines()
        base_commit = git_cmd("rev-parse", "HEAD")[0]
        git_status = "\n".join(git_cmd("status", "--porcelain=v1"))
        tracked = git_cmd("ls-files")
        staged = git_cmd("diff", "--cached", "--name-only")
        untracked = [line[3:] for line in git_status.splitlines() if line.startswith("?? ")]
    tracked_set, staged_set, untracked_set = set(tracked), set(staged), set(untracked)
    for row in files:
        path = row["path"]
        if path in staged_set:
            row["state"] = "staged"
        elif path in untracked_set:
            row["state"] = "untracked"
        elif path in tracked_set:
            row["state"] = "tracked"
        elif path.startswith(".agent-harness/"):
            row["state"] = "generated"
        else:
            row["state"] = "untracked"
    files.sort(key=lambda row: row["path"])
    workspace_identity = {"root_hash": hashlib.sha256(str(root).encode()).hexdigest(), "git": git, "base_commit": base_commit, "git_status": git_status, "tracked": sorted(tracked), "staged": sorted(staged), "untracked": sorted(untracked), "generated": sorted(row["path"] for row in files if row["state"] == "generated")}
    manifest = {"checkpoint_schema_version": 2, "canonicalization_version": 1, "checkpoint_id": run_id, "run_id": run_id, "risk": risk, "workspace_identity": workspace_identity, "authority_bindings": bound, "toolchain": {"platform": platform.platform(), "python": platform.python_version(), "shell": os.environ.get("SHELL", "unknown")}, "workflow_state": os.environ.get("CHECKPOINT_WORKFLOW_STATE", "UNBOUND"), "pending_operations": os.environ.get("CHECKPOINT_PENDING_OPERATIONS", "UNBOUND"), "files": files}
    manifest["manifest_hash"] = hashlib.sha256(json.dumps(manifest, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    (stage / "manifest.json").write_text(json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n")
    output.parent.mkdir(parents=True, exist_ok=True)
    os.replace(stage, output)
finally:
    if stage.exists():
        shutil.rmtree(stage, ignore_errors=True)
print(f"checkpoint: {output}")
print(f"files: {len(files)}")
PY
