# Required Check Evidence: bootstrap-health

task_id: v3_core_canonical_artifact_kernel
check_id: bootstrap-health
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-11 10:33:54 +0700
finished_at: 2026-07-11 10:33:56 +0700

## Command

```text
rtk ./scripts/bootstrap-runner.sh check
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
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
bootstrap_health: pass
base_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
sandbox_profile_sha256: 42bf75b171936d560c58d87fff533c2524308209ea916bc7ee12556eb0fe9d24
bootstrap_record: /tmp/agent-harness-bootstrap-20260711103356-3376.pD0tAa/bootstrap-record.json
```
