#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/create_baseline_snapshot' EXIT

task_id="create_baseline_snapshot"
plan="$tmp/current.md"
root="$tmp/no-git-repo"

cat > "$plan" <<EOF
---
task_id: $task_id
---
EOF

cp -R tests/fixtures/baseline/no-git-repo "$root"

PLAN_PATH="$plan" ./scripts/create-baseline-snapshot.sh --task "$task_id" --root "$root" >/dev/null

[ -f "docs/evidence/$task_id/baseline-snapshot.json" ] || {
  echo "Missing baseline snapshot" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-baseline-snapshot.sh --task "$task_id" >/dev/null

tampered="$tmp/tampered-snapshot.json"
cp "docs/evidence/$task_id/baseline-snapshot.json" "$tampered"
perl -pi -e 's/("snapshot_hash"\s*:\s*")[0-9a-f]+/${1} . ("0" x 64)/e' "$tampered"
set +e
PLAN_PATH="$plan" ./scripts/check-baseline-snapshot.sh --task "$task_id" --snapshot "$tampered" >/tmp/check-baseline-tampered.out 2>&1
status=$?
set -e
[ "$status" -ne 0 ] || {
  echo "Tampered snapshot hash should be rejected" >&2
  exit 1
}

external="$tmp/external-snapshot.json"
printf 'external sentinel\n' > "$external"
destination_link="$tmp/snapshot-link.json"
ln -s "$external" "$destination_link"
set +e
PLAN_PATH="$plan" ./scripts/create-baseline-snapshot.sh \
  --task "$task_id" --root "$root" --snapshot "$destination_link" >/tmp/create-baseline-symlink.out 2>&1
status=$?
set -e
[ "$status" -ne 0 ] || {
  echo "Snapshot creation should reject a symlink destination" >&2
  exit 1
}
grep -qx 'external sentinel' "$external"

external_dir="$tmp/external-dir"
mkdir "$external_dir"
ln -s "$external_dir" "$tmp/snapshot-parent"
set +e
PLAN_PATH="$plan" ./scripts/create-baseline-snapshot.sh \
  --task "$task_id" --root "$root" --snapshot "$tmp/snapshot-parent/baseline.json" >/tmp/create-baseline-parent-symlink.out 2>&1
status=$?
set -e
[ "$status" -ne 0 ] || {
  echo "Snapshot creation should reject a symlink parent" >&2
  exit 1
}
[ ! -e "$external_dir/baseline.json" ]

mkdir "$root/unreadable"
chmod 000 "$root/unreadable"
set +e
PLAN_PATH="$plan" ./scripts/create-baseline-snapshot.sh \
  --task "$task_id" --root "$root" --snapshot "$tmp/unreadable-snapshot.json" >/tmp/create-baseline-unreadable.out 2>&1
status=$?
set -e
chmod 700 "$root/unreadable"
[ "$status" -ne 0 ] || {
  echo "Snapshot creation should fail closed on an unreadable directory" >&2
  exit 1
}

echo "Create baseline snapshot regression passed."
