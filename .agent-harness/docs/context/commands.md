# Commands

## Update History

Updated: 2026-07-15 21:40

Common harness commands:

- `rtk ./harness.sh next`
- `rtk ./scripts/create-active-plan.sh <task_id> "<title>"`
- `rtk ./scripts/approve-plan.sh`
- `rtk ./harness.sh verify`
- `rtk ./harness.sh finalize`
- `rtk ./harness.sh score`
- `rtk ./harness.sh release-check`
- `rtk ./scripts/context.sh pack --task <task_id> --budget 5000`
- `rtk ./scripts/adr.sh select <task_id> ADR-0001 ADR-0002`

One-file intake and specification lock:

- `rtk ./harness.sh intake create REQUEST.json PACKAGE.json`
- `rtk ./harness.sh understand PACKAGE.json`
- `rtk ./harness.sh clarify PACKAGE.json QUESTIONS.json OUTPUT.json`
- `rtk ./harness.sh answer PACKAGE.json ANSWERS.json OUTPUT.json`
- `rtk ./harness.sh intake approve PACKAGE.json APPROVAL.json LOCKED.json`
- `rtk ./harness.sh intake verify PACKAGE.json`

Use `rtk` for repo commands by default.
