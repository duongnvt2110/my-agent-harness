# Required Check Evidence: plan-check

task_id: implement_release_invariants
check_id: plan-check
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-11 16:54:16 +0700
finished_at: 2026-07-11 16:54:18 +0700

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

Task ID: implement_release_invariants
Status: VERIFIED
Lifecycle phase: REVIEW
Lane: high_risk
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
- not yet consumed

Next allowed action:
Prepare review evidence and wait for the review gate.

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
- id: ADR-0001 | path: docs/decisions/0001-define-scratch-harness-lifecycle-terminology.md | status: Accepted | reason: Release lifecycle terms remain canonical.
- id: ADR-0003 | path: docs/decisions/0003-brownfield-agent-ready-execution-harness.md | status: Accepted | reason: Release evidence remains repository-governed.

Context pack:
- docs/evidence/implement_release_invariants/context-pack.md

Working memory:
- docs/evidence/implement_release_invariants/working-memory.md

Full context:
- docs/evidence/implement_release_invariants/full-context.md

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
