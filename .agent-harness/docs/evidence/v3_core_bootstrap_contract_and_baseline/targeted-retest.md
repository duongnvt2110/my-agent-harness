# Targeted Retest

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
exit_code: 0
started_at: 2026-07-10 14:55:50 +0700

## Command

```text
rtk ./tests/harness/run_all.sh --filter test_consume_plan_and_rollup.sh
```

## Output

```text
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
Running test_consume_plan_and_rollup.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Plan consume and roll-up regression passed.

Harness test summary
started_at: 2026-07-10 14:55:50 +0700
finished_at: 2026-07-10 14:55:50 +0700
selected: 1
passed: 1
failed: 0
timed_out: 0
Harness test suite passed.
```

## Follow Up

full_verify_command: rtk ./scripts/verify.sh
lifecycle_phase_before: DIAGNOSE
