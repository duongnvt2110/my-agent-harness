# Required Check Evidence: architecture-decision-record

task_id: record_vnext_governance_contract
check_id: architecture-decision-record
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-10 14:16:51 +0700
finished_at: 2026-07-10 14:16:52 +0700

## Command

```text
rtk rg -n 'Status: `accepted`|state.json|transition-state|current.md' docs/decisions/0004-agent-harness-vnext-authority-model.md docs/decisions/adr-index.json
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
docs/decisions/0004-agent-harness-vnext-authority-model.md:5:- Status: `accepted`
docs/decisions/0004-agent-harness-vnext-authority-model.md:14:The v2 harness stores lifecycle fields in `current.md`, and approval,
docs/decisions/0004-agent-harness-vnext-authority-model.md:25:- `runs/<run-id>/state.json` is the sole lifecycle authority.
docs/decisions/0004-agent-harness-vnext-authority-model.md:26:- `.agent-harness/scripts/transition-state` is the sole lifecycle writer.
docs/decisions/0004-agent-harness-vnext-authority-model.md:30:- `current.md` is a generated read-only execution projection, not an authority.
docs/decisions/0004-agent-harness-vnext-authority-model.md:41:- Keep `current.md` authoritative and use `state.json` as an audit cache. This
docs/decisions/0004-agent-harness-vnext-authority-model.md:65:- `current.md` remains visible to existing agents and humans, but its role
docs/decisions/adr-index.json:32:    "summary": "Makes state.json the sole v3 lifecycle authority and current.md a generated projection."
```
