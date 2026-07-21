# Required Check Evidence: adr-fixture-test

task_id: update_stale_adr_test_fixtures
check_id: adr-fixture-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-15 20:25:13 +0700
finished_at: 2026-07-15 20:25:19 +0700

## Command

```text
rtk bash tests/harness/test_context_adr_exact_match.sh && rtk bash tests/harness/test_harness_execution.sh && rtk bash tests/harness/test_mode_aware_verification.sh
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
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/context_adr_exact_match/localization.md
Created conventions: docs/evidence/context_adr_exact_match/brownfield-conventions.md
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Selected repository intelligence for: context_adr_exact_match
Created context pack: docs/evidence/context_adr_exact_match/context-pack.md
Context ADR exact-match regression passed.
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/harness_execution_temp/localization.md
Created conventions: docs/evidence/harness_execution_temp/brownfield-conventions.md
Selected repository intelligence for: harness_execution_temp
Created context pack: docs/evidence/harness_execution_temp/context-pack.md
Spec clarification checks passed.
Work alignment checks passed.
Work alignment checks passed.
Created ADR review: docs/evidence/harness_execution_temp/adr-review.md
ADR awareness checks passed.
Context pack checks passed.
Context pack checks passed.
Execution harness checks passed.
Mode-aware verification regression passed.
```
