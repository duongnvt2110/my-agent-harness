#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
task_id="dirty_git_baseline_snapshot"
evidence_dir="docs/evidence/$task_id"
trap 'rm -rf "$tmp" "$evidence_dir"' EXIT

repo="$tmp/repo"
plan="$tmp/current.md"
external="$tmp/external-secret.txt"

mkdir -p "$repo/src" "$repo/.github/workflows" "$repo/docs/evidence/old_task"
printf 'base\n' > "$repo/src/tracked.txt"
git -C "$repo" init -q
git -C "$repo" config user.email harness@example.test
git -C "$repo" config user.name "Harness Test"
git -C "$repo" add src/tracked.txt
git -C "$repo" commit -qm baseline

printf 'dirty\n' >> "$repo/src/tracked.txt"
printf 'staged\n' > "$repo/src/staged.txt"
git -C "$repo" add src/staged.txt
printf 'untracked\n' > "$repo/src/untracked.txt"
printf 'name: ci\n' > "$repo/.github/workflows/ci.yml"
printf 'generated evidence\n' > "$repo/docs/evidence/old_task/result.md"
printf 'must-not-be-read\n' > "$external"
ln -s "$external" "$repo/external-link"

cat > "$plan" <<EOF
---
task_id: $task_id
approved_scopes:
  - app_source
approved_files:
  - .github/**
  - external-link
approved_deletions: []
baseline_ref: null
---
EOF

PLAN_PATH="$plan" ./scripts/detect-change-baseline.sh \
  --task "$task_id" \
  --root "$repo" >/dev/null

decision="$evidence_dir/baseline-decision.md"
snapshot="$evidence_dir/baseline-snapshot.json"

grep -q '^change_tracking: snapshot$' "$decision" || {
  echo "Dirty Git repository should use snapshot tracking" >&2
  cat "$decision" >&2
  exit 1
}

for path in \
  .github/workflows/ci.yml \
  external-link \
  src/staged.txt \
  src/tracked.txt \
  src/untracked.txt
do
  jq -e --arg path "$path" '.files[] | select(.path == $path)' "$snapshot" >/dev/null || {
    echo "Snapshot missing path: $path" >&2
    exit 1
  }
done

if jq -e '.files[] | select(.path | startswith("docs/evidence/"))' "$snapshot" >/dev/null; then
  echo "Snapshot should exclude generated harness evidence" >&2
  exit 1
fi

jq -e '.files[] | select(.path == "external-link" and .type == "symlink")' "$snapshot" >/dev/null || {
  echo "Snapshot must classify external-link as a symlink" >&2
  exit 1
}

if grep -q 'must-not-be-read' "$snapshot"; then
  echo "Snapshot persisted external symlink target contents" >&2
  exit 1
fi

PLAN_PATH="$plan" ./scripts/check-baseline-snapshot.sh \
  --task "$task_id" \
  --snapshot "$snapshot" >/dev/null

PLAN_PATH="$plan" ./scripts/check-file-map.sh --root "$repo" >/dev/null

printf 'post-baseline\n' > "$repo/secret.txt"
if PLAN_PATH="$plan" ./scripts/check-file-map.sh --root "$repo" >/dev/null 2>&1; then
  echo "Snapshot comparison should reject an unapproved post-baseline change" >&2
  exit 1
fi

echo "Dirty Git baseline snapshot regression passed."
