#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

target=""
allow_no_git=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    --allow-no-git)
      allow_no_git=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 --target <dir> [--allow-no-git]" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$target" ] || fail "Missing --target <dir>"
target="$(bash "$HARNESS_SCRIPTS_DIR/check-target-safety.sh" --target "$target")"

export_root="$(mktemp -d)"
trap 'rm -rf "$export_root"' EXIT

bash "$HARNESS_SCRIPTS_DIR/export-harness-package.sh" --allow-no-git --output "$export_root/package" >/dev/null

sync_managed_block() {
  local source="$1"
  local destination="$2"
  python3 - "$source" "$destination" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1])
destination = pathlib.Path(sys.argv[2])
start = "<!-- BEGIN AGENT-HARNESS -->"
end = "<!-- END AGENT-HARNESS -->"

src = source.read_text()
try:
    _, src_rest = src.split(start, 1)
    src_body, _ = src_rest.split(end, 1)
except ValueError:
    raise SystemExit(f"Missing managed block in {source}")

src_body = src_body.strip("\n")
if destination.exists():
    dst = destination.read_text()
    try:
        dst_before, dst_rest = dst.split(start, 1)
        _, dst_after = dst_rest.split(end, 1)
        updated = dst_before.rstrip() + "\n" + start + "\n" + src_body + "\n" + end + "\n" + dst_after.lstrip("\n")
    except ValueError:
        updated = src
else:
    updated = src

destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(updated)
PY
}

copy_tree_files() {
  local source_root="$1"
  local target_root="$2"
  [ -d "$source_root" ] || fail "Missing export source directory: $source_root"
  while IFS= read -r -d '' source_file; do
    rel="${source_file#"$source_root"/}"
    destination="$target_root/$rel"
    mkdir -p "$(dirname "$destination")"
    if [ "$rel" = "docs/tasks/tasks.jsonl" ] && [ -f "$destination" ]; then
      continue
    fi
    cp -p "$source_file" "$destination"
  done < <(find "$source_root" -type f ! -name '.DS_Store' -print0)
}

package_root="$export_root/package"

cleanup_target_runtime_state() {
  local root="$1"
  mkdir -p "$root/.agent-harness/docs/exec-plans/active" "$root/.agent-harness/docs/exec-plans/completed" "$root/.agent-harness/docs/evidence" "$root/.agent-harness/docs/reviews" "$root/.agent-harness/docs/tasks"
  rm -f "$root/.agent-harness/docs/exec-plans/active/current.md"
  find "$root/.agent-harness/docs/exec-plans/completed" -maxdepth 1 -type f -name '*.md' ! -name '.gitkeep' -delete 2>/dev/null || true
  find "$root/.agent-harness/docs/evidence" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
  find "$root/.agent-harness/docs/reviews" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' -delete 2>/dev/null || true
  : > "$root/.agent-harness/docs/tasks/tasks.jsonl"
  find "$root" -name '.DS_Store' -type f -delete 2>/dev/null || true
}

# Preserve target runtime state on normal install. Use an explicit reset command in the future if runtime state must be cleared.

for file in AGENTS.md README.md WORKFLOW.md CONTEXT.md; do
  sync_managed_block "$package_root/$file" "$target/$file"
done

if [ -f "$package_root/.gitignore" ] && [ ! -f "$target/.gitignore" ]; then
  cp -p "$package_root/.gitignore" "$target/.gitignore"
fi
mkdir -p "$target/.agent-harness/docs/install"
cp -p "$package_root/manifest.json" "$target/.agent-harness/docs/install/install-manifest.json"

copy_tree_files "$package_root/.agent-harness" "$target/.agent-harness"

bash "$target/.agent-harness/scripts/check-install-integrity.sh" --root "$target"

echo "Installed harness into: $target"
