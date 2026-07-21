# Required Check Evidence: approved-design-contract

task_id: record_vnext_governance_contract
check_id: approved-design-contract
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-10 14:16:48 +0700
finished_at: 2026-07-10 14:16:50 +0700

## Command

```text
rtk rg -n 'state.json.*sole.*authority|transition-state.*only.*writer|v3-core' ../my_docs/2026_07_10_agent_harness_vnext_approved_design.md
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
24:`runs/<run-id>/state.json` is the sole v3 lifecycle authority.
25:`transition-state` is the only lifecycle writer. `current.md` is an atomically
234:The first release is `v3-core`: immutable intake/spec authority, minimal
239:### D-030: v3-core high-risk gate
242:high-risk v3-core work is read-only. High-risk mutations, network actions,
339:| V3C-12 | v3-core release gate enforces every non-compensable invariant | V3C-00 through V3C-11 | Full lifecycle, recovery, negative-security, package, and replay matrix |
348:After v3-core, deliver separately gated releases for role adapters, isolated
352:strengthen but never weaken v3-core invariants.
```
