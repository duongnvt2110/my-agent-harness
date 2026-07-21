# Required Check Evidence: slice-5-replay-evidence-test

task_id: v4_slice_5_honest_evaluation_replay_evidence
check_id: slice-5-replay-evidence-test
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-18 14:15:50 +0700
finished_at: 2026-07-18 14:15:51 +0700

## Command

```text
./tests/harness/test_v4_slice_5_replay_evidence.sh
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
v4 Slice 5 honest evaluation and replay evidence regression passed.
```
