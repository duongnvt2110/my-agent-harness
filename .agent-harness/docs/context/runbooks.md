# Runbooks

## Verify and Finalize

1. Run `rtk ./scripts/verify.sh`.
2. Inspect `docs/evidence/<task_id>/verification-pass.md`.
3. Run `rtk ./scripts/finalize-task.sh`.

## Brownfield Task Intake

1. Create or update `intake.md`.
2. Select skills or record a skill gap.
3. Review relevant ADRs.
4. Build the context pack.

## Remediation

1. Capture the failure packet.
2. Write diagnosis and repair plan.
3. Record decisions.
4. Run targeted retest.
5. Re-run full verification.
