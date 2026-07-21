# BROWN-010 Repair-loop metrics in report output

Existing repair report ignores remediation attempts. Add `repair_attempts`, `last_failure_reason`, and `final_status` to the generated report.

## Agent task

Fix the existing repository without changing unrelated behavior. Keep edits inside the allowed files listed in `metadata.json`. The fail-to-pass tests describe the new required behavior. The pass-to-pass tests describe behavior that must keep working.
