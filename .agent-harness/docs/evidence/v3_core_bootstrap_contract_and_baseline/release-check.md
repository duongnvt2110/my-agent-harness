# Required Check Evidence: release-check

task_id: v3_core_bootstrap_contract_and_baseline
check_id: release-check
type: automated
blocking: true
timeout_seconds: 900
result: pass
exit_code: 0
started_at: 2026-07-10 22:54:56 +0700
finished_at: 2026-07-10 22:55:07 +0700

## Command

```text
rtk ./scripts/harness.sh release-check
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
Release gate passed.
```
