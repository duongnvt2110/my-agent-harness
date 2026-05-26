#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

matrix="docs/TEST_MATRIX.md"
[ -f "$matrix" ] || fail "Missing test matrix: $matrix"

if grep -Eq 'AC-PDF|PDF splitter|example blog|blog-website' "$matrix"; then
  fail "Test matrix contains product/example-specific rows"
fi

lane="$(fm_value "$PLAN_PATH" "lane")"
if [ "$lane" = "normal" ] || [ "$lane" = "high_risk" ]; then
  [ "$(fm_list_count "$PLAN_PATH" "test_matrix_refs")" -gt 0 ] || fail "$lane lane requires test_matrix_refs"
fi

while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  grep -q "| $ref |" "$matrix" || fail "test_matrix_refs entry not found in $matrix: $ref"
done < <(fm_list "$PLAN_PATH" "test_matrix_refs")

echo "Test matrix checks passed."

