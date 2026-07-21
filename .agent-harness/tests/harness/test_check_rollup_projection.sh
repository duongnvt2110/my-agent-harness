#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '%s\n' '{"id":"task-1","status":"DONE"}' > "$tmp/tasks.jsonl"
printf '%s\n' '{"id":"story-1","status":"DONE"}' > "$tmp/stories.jsonl"
task_hash="$(shasum -a 256 "$tmp/tasks.jsonl" | awk '{print $1}')"
story_hash="$(shasum -a 256 "$tmp/stories.jsonl" | awk '{print $1}')"
cat > "$tmp/progress.md" <<EOF
## Update
- task_id: task-1
- projection_schema_version: 1
- epic_status: DONE
- verification_result: pass
- task_store_hash: $task_hash
- story_registry_hash: $story_hash
EOF
scripts/check-rollup-projection.sh "$tmp/progress.md" "$tmp/tasks.jsonl" "$tmp/stories.jsonl" | grep -q 'Rollup projection checks passed.'
sed 's/task_store_hash:.*/task_store_hash: bad/' "$tmp/progress.md" > "$tmp/bad.md"
if scripts/check-rollup-projection.sh "$tmp/bad.md" "$tmp/tasks.jsonl" "$tmp/stories.jsonl" >/dev/null 2>&1; then
  echo 'hash-independent rollup mutation was accepted' >&2
  exit 1
fi
echo 'Rollup projection validation regression passed.'
