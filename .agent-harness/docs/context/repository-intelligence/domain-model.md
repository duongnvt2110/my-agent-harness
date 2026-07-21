# Domain Model

Primary entities:

- `repo_profile`: classification and scan summary for the repository.
- `knowledge_index`: machine-readable map of reusable context docs.
- `task_mode`: change classification for the current task.
- `impact_scan`: the set of likely affected harness areas.
- `context_pack`: the task-facing summary used by execution.
- `verification_scope`: the commands and checks required to prove the task.
