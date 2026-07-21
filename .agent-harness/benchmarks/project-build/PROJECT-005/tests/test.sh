#!/usr/bin/env bash
set -euo pipefail
cat > result.json <<'JSON'
{"summary":{"total_score":90,"max_score":100,"result":"pass"},"benchmarks":[{"id":"BENCH-001","result":"pass","score":10,"max_score":10}]}
JSON
python3 src/benchmark_report.py result.json report.md
grep -q 'total_score: 90' report.md
grep -q '| BENCH-001 | pass | 10/10 |' report.md
