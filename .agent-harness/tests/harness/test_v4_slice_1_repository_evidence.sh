#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fixture="$tmp/fixture-repo"
mkdir -p "$fixture/.agent-harness/scripts" "$fixture/src" "$fixture/tests" "$fixture/docs"
fixture="$(cd "$fixture" && pwd -P)"
cp "$repo_root/.agent-harness/scripts/repository-intelligence.sh" "$fixture/.agent-harness/scripts/"
cp "$repo_root/.agent-harness/scripts/harness-lib.sh" "$fixture/.agent-harness/scripts/"
chmod +x "$fixture/.agent-harness/scripts/repository-intelligence.sh"

printf 'fixture source\n' > "$fixture/src/marker.txt"
printf 'fixture test\n' > "$fixture/tests/marker.txt"
printf 'must be ignored by the harness-root mistake\n' > "$fixture/.agent-harness/harness-only.txt"

(
  cd "$fixture"
  HARNESS_ROOT="$fixture/.agent-harness" \
    HARNESS_REPO_ROOT="$fixture" \
    REPO_INTELLIGENCE_ROOT="$fixture/.agent-harness/docs/context/repository-intelligence" \
    "$fixture/.agent-harness/scripts/repository-intelligence.sh" build brownfield
)

inventory="$fixture/.agent-harness/docs/context/repository-intelligence/repository-inventory.json"
profile="$fixture/.agent-harness/docs/context/repository-intelligence/repo-profile.yml"
[ -f "$inventory" ] || { echo "Missing repository inventory" >&2; exit 1; }
[ -f "$profile" ] || { echo "Missing repository profile" >&2; exit 1; }

python3 - "$inventory" "$fixture" <<'PY'
import json
import pathlib
import sys

inventory = json.loads(pathlib.Path(sys.argv[1]).read_text())
fixture = pathlib.Path(sys.argv[2]).resolve()
assert inventory["status"] == "generated", inventory
assert inventory["scan_root"] == str(fixture), inventory
paths = {entry["path"]: entry for entry in inventory["entries"]}
assert "src/marker.txt" in paths, sorted(paths)
assert paths["src/marker.txt"]["sha256"], paths["src/marker.txt"]
assert paths["src/marker.txt"]["size_bytes"] > 0, paths["src/marker.txt"]
assert ".agent-harness/harness-only.txt" in paths, sorted(paths)
PY

grep -q "scan_root: \"$fixture\"" "$profile" || {
  echo "Repository profile did not bind to the declared repository root" >&2
  exit 1
}

if rtk rg -n '^result: pass$' "$fixture/.agent-harness/docs/context/repository-intelligence" >/dev/null 2>&1; then
  echo "Generated repository evidence still claims pass" >&2
  exit 1
fi

echo "v4 Slice 1 repository evidence regression passed."
