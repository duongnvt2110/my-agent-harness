# Required Check Evidence: task-benchmark

task_id: 3_verify_lifecycle_remediation_recovery_and_finalization
check_id: task-benchmark
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-16 16:54:01 +0700
finished_at: 2026-07-16 16:54:21 +0700

## Command

```text
rtk ./scripts/harness.sh benchmark --no-history --timeout 60
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
Running BENCH-003 result schema check...
Running BENCH-004 install fixture...
Running BENCH-006 context/control evaluator...
Running BENCH-007 repair-loop metrics...
Running BENCH-010 long-plan decomposition workflow...
Running BENCH-009 brownfield issue-resolution suite...
  brownfield BROWN-006...
  brownfield BROWN-007...
  brownfield BROWN-008...
  brownfield BROWN-009...
  brownfield BROWN-010...
Running BENCH-002 project-build suite...
Running BENCH-005 agent-task evaluator...
Running BENCH-001 deterministic test runner...
Running BENCH-008 history comparison...
Benchmark result: pass 140/140
JSON: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/reports/benchmark/latest.json
Markdown: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/reports/benchmark/latest.md
```
