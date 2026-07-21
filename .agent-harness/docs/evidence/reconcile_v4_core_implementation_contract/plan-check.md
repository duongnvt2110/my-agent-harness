# Required Check Evidence: plan-contract-check

task_id: reconcile_v4_core_implementation_contract
check_id: plan-contract-check
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-18 13:31:25 +0700
finished_at: 2026-07-18 13:31:26 +0700

## Command

```text
rtk rg -n 'v4-core|Context Preservation Contract|Deferred' ../my_docs/agent-harness-v4-detailed-implementation-plan.md
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
3:**Status:** Reconciled v4-core implementation contract  
5:**Target:** A provider-neutral, deterministic v4-core control system that improves repository evidence, context continuity, tool authorization, independent verification, and honest evaluation while preserving the repository-local `AUDIT_ONLY` boundary  
12:## Binding v4-core implementation contract
32:### v4-core scope
53:### Explicit v4-core exclusions
67:policy would be violated, but v4-core must not claim OS-level enforcement.
90:**Goal:** make v4-core boundaries executable before changing evidence or tools.
93:`.agent-harness/tests/harness/`, and v4-core plan/evidence documentation.
190:### Context Preservation Contract
256:The v4-core implementation should preserve those controls and add only the
265:are deferred integrations. They may consume the v4-core contracts later, but
546:> **Execution rule:** The binding v4-core slices above are the only milestones
```
