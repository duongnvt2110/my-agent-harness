#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/check_file_map_snapshot' EXIT

task_id="check_file_map_snapshot"
plan="$tmp/current.md"
root="$tmp/no-git-repo"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"

cat > "$plan" <<EOF
---
task_id: $task_id
approved_scopes:
  - app_docs
  - app_source
approved_files: []
approved_deletions: []
baseline_ref: null
---
EOF

cp -R "$harness_root/tests/fixtures/baseline/no-git-repo" "$root"
PLAN_PATH="$plan" "$harness_root/scripts/detect-change-baseline.sh" --task "$task_id" --root "$root" >/dev/null

PLAN_PATH="$plan" "$harness_root/scripts/check-file-map.sh" --root "$root" >/dev/null

printf 'new file\n' > "$root/secret.txt"
set +e
PLAN_PATH="$plan" "$harness_root/scripts/check-file-map.sh" --root "$root" >/tmp/check-file-map-snapshot.out 2>&1
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "Snapshot file-map should fail for an unapproved change" >&2
  cat /tmp/check-file-map-snapshot.out >&2
  exit 1
fi

mkdir -p "$root/my_docs"
printf 'private note\n' > "$root/my_docs/note.md"
set +e
PLAN_PATH="$plan" "$harness_root/scripts/check-file-map.sh" --root "$root" >/tmp/check-file-map-my-docs.out 2>&1
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "Snapshot file-map should fail for unauthorized my_docs changes" >&2
  cat /tmp/check-file-map-my-docs.out >&2
  exit 1
fi

rm -f "$root/secret.txt"
rm -rf "$root/my_docs"
python3 - "$plan" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("approved_deletions: []", "approved_deletions:\n  - README.md")
path.write_text(text)
PY
rm "$root/README.md"
PLAN_PATH="$plan" "$harness_root/scripts/check-file-map.sh" --root "$root" >/dev/null

echo "Check file-map snapshot regression passed."
