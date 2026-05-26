# AGENTS.md

This is a scratch harness for agent-assisted development. Treat Codex as the
Worker Agent and the harness scripts as the Harness Driver and Gate Scripts.

## Required Entry Point

Before any task action, run:

```bash
rtk ./scripts/harness.sh next
```

Follow the task packet it prints. Do not implement directly from chat.

## Core Rules

- Use exactly one active plan: `docs/exec-plans/active/current.md`.
- Do not edit files outside approved scopes or `approved_files` exceptions.
- Do not delete files outside approved scopes or `approved_deletions`.
- Do not start implementation unless the active plan allows it.
- Keep generated task artifacts under `docs/`, not `my_docs/`.
- Treat `my_docs/` as human-owned input only.
- Use `rtk` for shell commands by default.
- Before renaming harness concepts, script commands, schema fields, or workflow
  docs, check `CONTEXT.md` and ADRs.

## Verification

Before claiming work complete, run:

```bash
rtk ./scripts/verify.sh
```

Completion is script-owned:

```bash
rtk ./scripts/finalize-task.sh
```

Do not mark a task complete manually.
