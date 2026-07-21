#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

repo="$tmp/repo"
mkdir -p "$repo"
printf '# Fixture\n' > "$repo/README.md"
git -C "$repo" init -q
git -C "$repo" config user.email harness@example.test
git -C "$repo" config user.name "Harness Test"
git -C "$repo" add README.md
git -C "$repo" commit -qm baseline

"$harness_root/scripts/install-harness.sh" --target "$repo" >/dev/null

installed="$repo/.agent-harness"
"$installed/scripts/create-active-plan.sh" \
  dirty_public_activation \
  "Dirty public activation" >/dev/null

plan="$installed/docs/exec-plans/active/current.md"
decision="$installed/docs/evidence/dirty_public_activation/baseline-decision.md"
snapshot="$installed/docs/evidence/dirty_public_activation/baseline-snapshot.json"

grep -q '^change_tracking: snapshot$' "$decision" || {
  echo "Public activation should select snapshot mode for a dirty repository" >&2
  exit 1
}

grep -q '^baseline_ref: null$' "$plan" || {
  echo "Snapshot activation should project baseline_ref: null" >&2
  exit 1
}

jq -e '.files[] | select(.path == "README.md")' "$snapshot" >/dev/null || {
  echo "Repository-root snapshot missing README.md" >&2
  exit 1
}

jq -e '.files[] | select(.path == ".agent-harness/harness.sh")' "$snapshot" >/dev/null || {
  echo "Repository-root snapshot missing installed harness files" >&2
  exit 1
}

initial_changes="$($installed/scripts/list-baseline-changes.sh --format name-status)"
[ -z "$initial_changes" ] || {
  echo "Activation state should not appear as task changes" >&2
  printf '%s\n' "$initial_changes" >&2
  exit 1
}

mkdir -p "$repo/src"
printf 'new behavior\n' > "$repo/src/new.txt"

changes="$($installed/scripts/list-baseline-changes.sh --format name-status)"
printf '%s\n' "$changes" | grep -q $'^A\tsrc/new.txt$' || {
  echo "Baseline change list missing repository-root addition" >&2
  printf '%s\n' "$changes" >&2
  exit 1
}

"$installed/scripts/generate-autonomous-run-report.sh" >/dev/null
report="$installed/docs/evidence/dirty_public_activation/autonomous-run-report.md"
grep -q $'^A\tsrc/new.txt$' "$report" || {
  echo "Autonomous report did not use snapshot attribution" >&2
  exit 1
}

echo "Dirty Git public activation baseline regression passed."
