# Required Check Evidence: slice-0-audit-test

task_id: v4_slice_0_contract_and_standalone_audit
check_id: slice-0-audit-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-18 13:48:42 +0700
finished_at: 2026-07-18 13:48:45 +0700

## Command

```text
./tests/harness/test_v4_slice_0_audit.sh
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
v4 Slice 0 audit regression passed.
```
