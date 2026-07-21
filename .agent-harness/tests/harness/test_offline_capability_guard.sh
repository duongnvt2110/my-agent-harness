#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export OFFLINE_CAPABILITY_SIGNING_KEY='test-only-key'
./scripts/offline-capability issue "$tmp/cap.json" intake-1 task-1 run-1 spec-1 policy-1 workspace-1 session-1 '["inspect","record_observation"]' 600 >/dev/null
./scripts/offline-capability validate "$tmp/cap.json" run-1 spec-1 policy-1 workspace-1 session-1 inspect "$(( $(date +%s) + 10 ))" >/dev/null
if ./scripts/offline-capability validate "$tmp/cap.json" run-2 spec-1 policy-1 workspace-1 session-1 inspect "$(( $(date +%s) + 10 ))" >/dev/null 2>&1; then exit 1; fi
if ./scripts/offline-capability validate "$tmp/cap.json" run-1 spec-1 policy-1 workspace-1 session-1 finalize "$(( $(date +%s) + 10 ))" >/dev/null 2>&1; then exit 1; fi
if ./scripts/offline-capability issue "$tmp/bad.json" intake-1 task-1 run-1 spec-1 policy-1 workspace-1 session-1 '["mutate"]' 600 >/dev/null 2>&1; then exit 1; fi
echo 'Offline capability guard regression passed.'
