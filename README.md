# Scratch Harness

This repository is a lightweight, repository-local control harness for
agent-assisted software work. It turns a human request into one active execution
contract, bounded file changes, required checks, evidence, review when needed,
and script-owned finalization.

## Start Here

```bash
bash .agent-harness/harness.sh next
```

Use the task packet printed by `next` as the source of truth. Do not implement
from chat alone when a repo edit is required.

## Public Commands

```bash
bash .agent-harness/harness.sh status
bash .agent-harness/harness.sh next
bash .agent-harness/harness.sh verify
bash .agent-harness/harness.sh finalize
bash .agent-harness/harness.sh test
bash .agent-harness/harness.sh benchmark --no-history
bash .agent-harness/harness.sh release-check
bash .agent-harness/harness.sh export --output /path/to/export --zip /path/to/harness.zip
```

Internal scripts under `.agent-harness/scripts/` are implementation details.
Prefer the public dispatcher above unless a task packet explicitly tells you to
run a specific internal script.

## What This Harness Checks and Gates

- one active plan: `.agent-harness/docs/exec-plans/active/current.md`
- approved scopes, file exceptions, and deletion rules
- baseline and behavior checks for brownfield work
- required check execution with evidence files
- review gate when the active plan requires review
- remediation flow after blocking verification failures
- finalization through the harness, not manual status edits

## Assurance Boundary

The shipped v3-core implementation reports `enforcement_mode: AUDIT_ONLY`. Its
driver and gate scripts reject invalid operations when they are invoked and
produce auditable evidence, but they are not an OS-level sandbox and cannot stop
a process from bypassing the harness, writing outside approved paths, or using
the network. Strong prevention requires an external execution boundary such as a
container, sandbox, CI policy, or restricted agent adapter.

## Workflow Docs

- `AGENTS.md` — agent entry rules
- `WORKFLOW.md` — lifecycle and lane rules
- `CONTEXT.md` — glossary and repo-local context
- `.agent-harness/docs/PLANS.md` — active-plan schema
- `.agent-harness/docs/TEST_MATRIX.md` — generic acceptance criteria
- `.agent-harness/docs/context/README.md` — context system

Advanced folders such as product specs, contracts, design docs, ADRs, and
repository-intelligence artifacts are lane-triggered. They are not required for
every small task.

<!-- BEGIN AGENT-HARNESS -->
## Agent Harness

This repository exposes the harness through `.agent-harness/harness.sh`.
Use `bash .agent-harness/harness.sh status` to inspect the current task.
Use `bash .agent-harness/harness.sh next` to continue the active task.
Use `bash .agent-harness/harness.sh verify` before finalization.
<!-- END AGENT-HARNESS -->

## Benchmarking

Run the built-in harness benchmark suite with:

```bash
bash .agent-harness/harness.sh benchmark --no-history
```

The benchmark suite includes project-build and brownfield fixtures. The runner
writes JSON and Markdown reports under `.agent-harness/docs/reports/benchmark/`.
Use the default command without `--no-history` only when you want to append a
historical benchmark sample.
