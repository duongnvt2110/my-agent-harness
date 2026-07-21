# Required Check Evidence: role-authority-test

task_id: remove_v3_verifier_adapter_authority
check_id: role-authority-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-15 19:39:28 +0700
finished_at: 2026-07-15 19:39:29 +0700

## Command

```text
rtk bash tests/harness/test_v3_role_authority_removal.sh
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
Recipe loader enforcement regression passed.
v3 role authority removal regression passed
```
