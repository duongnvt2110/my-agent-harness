# Required Check Evidence: plan-check

task_id: harden_release_bootstrap_audit
check_id: plan-check
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-12 17:18:48 +0700
finished_at: 2026-07-12 17:18:49 +0700

## Command

```text
rtk ./scripts/harness.sh next
```

## Output

```text
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LC_CTYPE = "C.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
HARNESS TASK PACKET

Task ID: harden_release_bootstrap_audit
Status: VERIFIED
Lifecycle phase: FINALIZE
Lane: tiny
Repo mode: brownfield
Task mode:
- change_type: extend_existing
- touches_existing_behavior: true
- backward_compatibility_required: true
Active plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md

Active plan lock:
- current.md exists and is authoritative.
- Do not create another active plan.
- Continue this task only until it is verified and finalized.

Implementation plan snapshot:
- docs/tasks/harden_release_bootstrap_audit/implementation-plan.md

Next allowed action:
Run rtk .agent-harness/scripts/finalize-task.sh.

Approved scopes:
- harness_core
- harness_docs
- app_tests

Approved file exceptions:
- (none)

Approved deletions:
- (none)



Relevant ADRs:
- result: reviewed
- id: ADR-0001 | path: docs/decisions/0001-define-scratch-harness-lifecycle-terminology.md | hash: fd5c24ee3bdf0e88ea6c284ff57fa3c1419d19d95a4c643288f0ba41f573d04b | status: Accepted | reason: Release bootstrap audit-only behavior and package compatibility
- id: ADR-0002 | path: docs/decisions/0002-remove-harness-skill-selection-contract.md | hash: b1d1b89c03a63245e011fa1341eb2cf8f87d302c4dd26b4483f5c664d8aa588a | status: Accepted | reason: Release bootstrap audit-only behavior and package compatibility
- id: ADR-0003 | path: docs/decisions/0003-brownfield-agent-ready-execution-harness.md | hash: aebca397534bc744062dfdc6fbc632a38d59dd0d8c4f0ed97ef40c4b7c8a39fe | status: Accepted | reason: Release bootstrap audit-only behavior and package compatibility
- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | hash: 600a0a8a52767cedcc893ad51c8fb6b9aec9b263f05d01e44f2de62cc91c2b7a | status: Accepted | reason: Release bootstrap audit-only behavior and package compatibility
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | hash: f245426bdc50e1f634cbc0b478e67ab6b75b5940571a36ac714fc53c52e70fb6 | status: Accepted | reason: Release bootstrap audit-only behavior and package compatibility

Context pack:
- docs/evidence/harden_release_bootstrap_audit/context-pack.md

Working memory:
- docs/evidence/harden_release_bootstrap_audit/working-memory.md

Full context:
- docs/evidence/harden_release_bootstrap_audit/full-context.md

Verification mode: required_checks
Testing required: true

Decision policy:
- allow_safe_revert: true
- allow_test_fix: true
- allow_source_fix: true
- allow_scope_expansion: false
- allow_dependency_change: false
- allow_environment_change: false
- allow_test_skip: false
- allow_timeout_increase: false

Required checks:
- plan-check: rtk ./scripts/harness.sh next (timeout: 180)

Do-not-read:
- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
- docs/evidence/*/test-report.md unless it belongs to this task

Forbidden:
- Do not change files outside approved scopes or approved file exceptions.
- Do not delete files outside approved scopes or approved deletions.
- Do not mark completion manually.
- Do not skip required checks.
- Do not treat direct chat as approval to bypass the harness lifecycle.
```
