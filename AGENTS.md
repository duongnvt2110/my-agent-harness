# AGENTS.md

This is a repository-local control harness for agent-assisted development. Treat Codex as
the Worker Agent and the harness scripts as the Harness Driver and Gate Scripts.

## Required Entry Point

Before any repo edit, implementation step, verification, or finalization, run:

```bash
bash .agent-harness/harness.sh next
```

Follow the task packet it prints. Do not implement directly from chat.

Discussion Intake:

- Conversation-only planning, grilling, and clarification can continue without
  an active plan when no files are edited and no command changes repo state.
- Before implementation or persistent doc updates, create one active plan and
  capture the agreed state as a summary/report or plan update.
- Do not create one active plan per discussion question.

## Core Rules

- Use exactly one active plan: `.agent-harness/docs/exec-plans/active/current.md`.
- Do not edit files outside approved scopes or `approved_files` exceptions.
- Do not delete files outside approved scopes or `approved_deletions`.
- Do not start implementation unless the active plan allows it.
- Keep generated task artifacts under `.agent-harness/docs/` by default.
- Treat `my_docs/` as human-owned input unless the active plan explicitly
  allows selected `my_docs/` paths through `approved_files`.
- Use `rtk` for shell commands when it is installed; otherwise use `bash` or the native command directly.
- Use `.agent-harness/harness.sh` as the public command surface. Internal
  scripts are implementation details unless the task packet names them.
- Before renaming harness concepts, script commands, schema fields, or workflow
  docs, check `WORKFLOW.md` and ADRs.

## Verification

Before claiming work complete, run:

```bash
bash .agent-harness/harness.sh verify
```

Completion is script-owned:

```bash
bash .agent-harness/harness.sh finalize
```

Do not mark a task complete manually.

<!-- BEGIN AGENT-HARNESS -->
## Agent Harness

This repository uses `.agent-harness/` as the public harness namespace.
Use `bash .agent-harness/harness.sh status` to inspect the current task.
Use `bash .agent-harness/harness.sh next` to continue the active task.
<!-- END AGENT-HARNESS -->
