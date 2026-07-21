# Required Check Evidence: plan-check

task_id: v4_verifier_integrity_followup
check_id: plan-check
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-18 18:45:00 +0700
finished_at: 2026-07-18 18:45:01 +0700

## Command

```text
cd /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness && bash harness.sh next
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
workflow_version: v3
implementation_version: v3-core
enforcement_mode: AUDIT_ONLY
assurance_limitations: repository-local governance; OS-level isolation is outside scope
HARNESS TASK PACKET

Task ID: v4_verifier_integrity_followup
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
- docs/tasks/v4_verifier_integrity_followup/implementation-plan.md

Next allowed action:
Run rtk .agent-harness/scripts/finalize-task.sh.

Approved scopes:
- harness_core
- harness_docs
- app_tests

Approved file exceptions:
- .agent-harness/scripts/check-v4-verification.sh
- .agent-harness/tests/harness/test_v4_finalization_authority.sh

Approved deletions:
- (none)



Relevant ADRs:
- result: reviewed
- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | hash: b6cde0431dbce0fc497e3aa9eb4945e613a64752d37bbf0ed85380418c2974b5 | status: Accepted | tags: harness, v3, lifecycle, state, recovery | reason: Makes state.json the sole v3 lifecycle authority and current.md a generated projection.

Context pack:
- docs/evidence/v4_verifier_integrity_followup/context-pack.md

Working memory:
- docs/evidence/v4_verifier_integrity_followup/working-memory.md

Full context:
- docs/evidence/v4_verifier_integrity_followup/full-context.md

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
- plan-check: cd /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness && bash harness.sh next (timeout: 180)

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
