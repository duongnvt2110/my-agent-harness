# Required Check Evidence: intake-backlog-report-test

task_id: filter_completed_intake_plans_from_backlog_report
check_id: intake-backlog-report-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-16 22:11:52 +0700
finished_at: 2026-07-16 22:11:53 +0700

## Command

```text
rtk bash tests/harness/test_intake_backlog_report.sh
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
Intake backlog report regression passed.
```
