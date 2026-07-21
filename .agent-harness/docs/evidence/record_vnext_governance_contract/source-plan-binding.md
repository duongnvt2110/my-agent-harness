# Required Check Evidence: source-plan-binding

task_id: record_vnext_governance_contract
check_id: source-plan-binding
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-10 14:16:50 +0700
finished_at: 2026-07-10 14:16:51 +0700

## Command

```text
rtk rg -n 'Approved Design Authority|2026_07_10_agent_harness_vnext_approved_design.md|v3-core' ../my_docs/agent-harness-vnext-full-implementation-plan.md
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
7:## Approved Design Authority
12:`my_docs/2026_07_10_agent_harness_vnext_approved_design.md`
16:boundary is `v3-core`; later enforcement and orchestration features ship as
17:separately verified releases without weakening v3-core invariants.
2194:The dependency-aware `v3-core` task graph in the approved design ledger is the
2293:# 11. Features intentionally outside v3-core
2295:Do not expand v3-core into a complete agent platform.
2297:Keep these outside the v3-core rollout:
```
