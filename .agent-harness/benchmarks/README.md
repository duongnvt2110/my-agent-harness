# Harness Benchmark Suite

This directory contains benchmark definitions and fixture projects used by
`bash .agent-harness/harness.sh benchmark`.

The suite is intentionally dependency-light. Each project fixture is a small but
real executable project with a task spec, implementation files, and an automated
acceptance test. The benchmark runner measures whether the harness can run a
repeatable project-build suite, install itself into a fixture repository, score
agent-task success signals, score context/control signals, collect repair-loop
metrics, and compare results with benchmark history.

## Brownfield issue-resolution benchmark

The `brownfield/` track contains repo-style fixtures. Each `BROWN-xxx` task has:

- `repo/`: the intentionally broken or incomplete existing project.
- `solution/`: the expected fixed files used by the fixture validator.
- `expected.patch`: a reviewable patch from `repo/` to `solution/`.
- `task.md`: the issue-style instruction an agent should receive.
- `metadata.json`: allowed files, scoring, and test commands.
- `tests/fail_to_pass.sh`: must fail before the fix and pass after it.
- `tests/pass_to_pass.sh`: must pass after the fix to protect existing behavior.

Current brownfield tasks:

- `BROWN-006` URL shortener TTL expiration behavior.
- `BROWN-007` nested command required-flag validation.
- `BROWN-008` CLI JSON output mode.
- `BROWN-009` benchmark report history comparison.
- `BROWN-010` repair-loop metrics in report output.
