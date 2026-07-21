# Required Check Evidence: remediation-trace-test

task_id: enforce_v3_remediation_trace
check_id: remediation-trace-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-15 17:35:50 +0700
finished_at: 2026-07-15 17:35:52 +0700

## Command

```text
rtk bash tests/harness/test_remediation_trace_contract.sh
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
Remediation trace contract regression passed.
```
