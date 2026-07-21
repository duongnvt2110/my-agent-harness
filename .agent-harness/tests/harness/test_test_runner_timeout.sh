#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/tests"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
cat > "$tmp/tests/test_001_pass.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
echo ok
SH
cat > "$tmp/tests/test_002_hang.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
sleep 5
SH
chmod +x "$tmp/tests"/*.sh

set +e
HARNESS_TEST_DIR="$tmp/ignored" HARNESS_TEST_TIMEOUT_SECONDS=999 HARNESS_TEST_FILTER=does-not-match \
HARNESS_TEST_FAIL_FAST=true HARNESS_SKIP_BENCHMARK_SUITE=1 \
  bash "$harness_root/tests/harness/run_all.sh" --test-dir "$tmp/tests" --timeout 1 > "$tmp/out.txt" 2>&1
exit_code=$?
set -e

[ "$exit_code" -ne 0 ] || {
  cat "$tmp/out.txt" >&2
  echo "Expected timeout runner to fail when a test hangs" >&2
  exit 1
}
grep -q 'TIMEOUT: test_002_hang.sh' "$tmp/out.txt"
grep -q '^passed: 1$' "$tmp/out.txt"
grep -q '^timed_out: 1$' "$tmp/out.txt"

bash "$harness_root/tests/harness/run_all.sh" --test-dir "$tmp/tests" --timeout 1 --filter 'test_001_*' > "$tmp/pass.txt" 2>&1
grep -q '^passed: 1$' "$tmp/pass.txt"
grep -q '^failed: 0$' "$tmp/pass.txt"

HARNESS_TEST_DIR="$tmp/ignored" /bin/bash "$harness_root/tests/harness/run_all.sh" --test-dir "$tmp/tests" --list > "$tmp/list.txt" 2>&1
grep -qx 'test_001_pass.sh' "$tmp/list.txt"
grep -qx 'test_002_hang.sh' "$tmp/list.txt"

echo "Deterministic test runner timeout regression passed."
