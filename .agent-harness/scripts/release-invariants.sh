#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"
required=(tests/harness/run_all.sh tests/harness/test_transition_state_validation.sh tests/harness/test_run_events.sh tests/harness/test_v3_legacy_rejection.sh tests/harness/test_export_install_integrity.sh)
for fixture in "${required[@]}"; do [ -f "$fixture" ] || fail "missing release-blocking fixture: $fixture"; done
fixture_audit="$(bash scripts/check-release-fixtures --json)"
fixture_manifest_hash="$(python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["manifest_hash"])' <<<"$fixture_audit")"
bash tests/harness/run_all.sh
bash scripts/harness.sh benchmark --no-history --timeout 60 >/dev/null
bash scripts/export-harness-package.sh --allow-no-git --output "$(mktemp -d)/package" >/dev/null
echo "Release invariants passed. fixture_manifest_hash=$fixture_manifest_hash"
