# Failure Diagnosis

task_id: 2_extend_change_package_source_manifest
result: diagnosed
attempt: 1
failure_source: scope
confidence: medium
patch_allowed: true
requires_human_review: false
diagnosed_at: 2026-07-16 13:39:45 +0700
source: docs/evidence/2_extend_change_package_source_manifest/failure-packet.md

## Observation

The failure packet shows a stale harness state that needed the active
plan's file-map approvals and remediation trail to match the preserved
workspace.

## Diagnosis Summary

The active plan and the preserved dirty workspace were out of sync for
the current task's remediation trail.

## Evidence

```text
# Failure Packet

## Task ID

2_extend_change_package_source_manifest

## Failed Check

active-plan-contract

## Command

```text
./scripts/check-active-plan-contract.sh
```

## Exit Code

1

## Relevant Output

```text
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
Active plan cannot use lifecycle_phase=COMPLETED

```

## Approved Fix Scope

```text
```

## Next Allowed Action

Fix the failed check inside the approved file map, then rerun verification.
```
