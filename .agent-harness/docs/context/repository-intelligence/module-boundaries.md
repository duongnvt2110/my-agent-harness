# Module Boundaries

- `scripts/` owns harness control flow and gate enforcement.
- `docs/context/repository-intelligence/` owns repository knowledge and mode classification artifacts.
- `docs/evidence/<task_id>/` owns task-local evidence and verification trails.
- `docs/exec-plans/active/current.md` is the single active task contract.
- `tests/harness/` owns regression coverage for harness behavior.
