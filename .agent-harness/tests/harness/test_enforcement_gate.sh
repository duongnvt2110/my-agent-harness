#!/usr/bin/env bash
set -euo pipefail
scripts/enforcement-gate.sh high_risk mutation ENFORCED worktree >/dev/null
if scripts/enforcement-gate.sh high_risk mutation AUDIT_ONLY worktree >/dev/null 2>&1; then exit 1; fi
if scripts/enforcement-gate.sh high_risk mutation ENFORCED sandbox >/dev/null 2>&1; then exit 1; fi
scripts/enforcement-gate.sh tiny inspection AUDIT_ONLY '' >/dev/null
if scripts/enforcement-gate.sh normal mutation ENFORCED worktree,unknown >/dev/null 2>&1; then exit 1; fi
echo "Enforcement gate regression passed."
