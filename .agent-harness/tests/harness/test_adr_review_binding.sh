#!/usr/bin/env bash
set -euo pipefail

script="scripts/check-adr-impact.sh"
grep -q 'task_id.*does not match active task' "$script" || {
  echo "ADR impact checks must bind evidence to the active task" >&2
  exit 1
}
grep -q 'ADR review missing reviewed_at' "$script" || {
  echo "ADR impact checks must require review freshness metadata" >&2
  exit 1
}
grep -q 'ADR content hash mismatch' "$script" || {
  echo "ADR impact checks must verify content hashes" >&2
  exit 1
}
echo "ADR review binding regression passed."
