#!/usr/bin/env bash
set -euo pipefail
grep -q '"decision": "ALLOW"' <(scripts/budget-guard.sh tokens 1 10 20 30 normal)
grep -q '"decision": "WARN"' <(scripts/budget-guard.sh tokens 10 10 20 30 normal)
grep -q '"decision": "PAUSE"' <(scripts/budget-guard.sh tokens 20 10 20 30 normal)
grep -q '"decision": "DENY"' <(scripts/budget-guard.sh tokens 30 10 20 30 normal)
if scripts/budget-guard.sh tokens 10 30 20 40 normal >/dev/null 2>&1; then exit 1; fi
echo "Budget guard regression passed."
