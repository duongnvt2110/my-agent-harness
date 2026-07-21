#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/export"
printf 'keep me\n' > "$tmp/export/keep.txt"
./scripts/export-harness-package.sh --allow-no-git --output "$tmp/export" --zip "$tmp/template.zip" >/dev/null

for path in \
  .agent-harness \
  .agent-harness/harness.sh \
  .agent-harness/scripts \
  .agent-harness/docs \
  .agent-harness/tests \
  .agent-harness/runtime \
  .agent-harness/policies \
  .agent-harness/recipes \
  AGENTS.md \
  README.md \
  WORKFLOW.md \
  CONTEXT.md
do
  [ -e "$tmp/export/$path" ] || {
    echo "Missing exported path: $path" >&2
    exit 1
  }
done

for path in scripts docs tests; do
  [ ! -e "$tmp/export/$path" ] || {
    echo "Unexpected flattened path in export: $path" >&2
    exit 1
  }
done

(
  cd "$tmp/export"
  bash ./.agent-harness/scripts/check-package-integrity.sh --root "$tmp/export" >/dev/null
  bash ./.agent-harness/scripts/check-install-integrity.sh --root "$tmp/export" >/dev/null
  status_output="$(bash ./.agent-harness/harness.sh status)"
  grep -q '^workflow_version: v3$' <<<"$status_output"
  grep -q '^HARNESS STATUS$' <<<"$status_output"
  cd .agent-harness
  bash scripts/check-script-interface.sh >/dev/null
  bash tests/harness/run_all.sh --list >/dev/null
)

if find "$tmp/export/.agent-harness/docs/epics" -mindepth 1 -type f ! -name README.md | grep -q .; then
  echo "Clean export retained epic history" >&2
  exit 1
fi
if find "$tmp/export/.agent-harness/docs/recovery" -mindepth 1 -type f 2>/dev/null | grep -q .; then
  echo "Clean export retained recovery history" >&2
  exit 1
fi
if find "$tmp/export/.agent-harness/docs/reports" -mindepth 1 -type f ! -name README.md | grep -q .; then
  echo "Clean export retained generated reports" >&2
  exit 1
fi
if [ -e "$tmp/export/.agent-harness/policies/task-plan-exception-snapshots" ]; then
  echo "Clean export retained historical task-plan exception snapshots" >&2
  exit 1
fi
python3 - "$tmp/export/.agent-harness/policies/task-plan-exceptions.json" <<'PY_EXCEPTIONS'
import json
import pathlib
import sys
data = json.loads(pathlib.Path(sys.argv[1]).read_text())
if data.get("entries") != []:
    raise SystemExit("clean export retained task-plan exceptions")
PY_EXCEPTIONS

grep -q '^keep me$' "$tmp/export/keep.txt" || {
  echo "Export removed an existing target file" >&2
  exit 1
}
grep -q '^__MACOSX/$' "$tmp/export/.gitignore" || {
  echo "Missing __MACOSX ignore rule in exported template" >&2
  exit 1
}
grep -q '^harness-proof/$' "$tmp/export/.gitignore" || {
  echo "Missing harness-proof ignore rule in exported template" >&2
  exit 1
}
grep -q '`enforcement_mode: AUDIT_ONLY`' "$tmp/export/README.md" || {
  echo "Exported README does not declare the audit-only boundary" >&2
  exit 1
}
grep -q 'not an OS-level sandbox' "$tmp/export/README.md" || {
  echo "Exported README overstates the harness assurance boundary" >&2
  exit 1
}
python3 - "$tmp/export/manifest.json" "$tmp/export" <<'PY'
import json
import pathlib
import sys
manifest = pathlib.Path(sys.argv[1])
export_root = pathlib.Path(sys.argv[2]).resolve()
data = json.loads(manifest.read_text())
if data.get("export_root") != ".":
    raise SystemExit("clean manifest must use a portable export_root")
if str(export_root) in manifest.read_text():
    raise SystemExit("clean manifest leaked the temporary export path")
PY
echo "Export harness package regression passed."
