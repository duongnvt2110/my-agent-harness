---
task_id: v3_core_bootstrap_contract_and_baseline
reviewed_at: "2026-07-10 22:52"
reviewer: "codex-exec:gpt-5.6-terra"
review_session_id: "019f4cb9-837e-7af0-a07d-9d7f09d07591"
review_mode: read_only
role_separated: true
model_independent: false
blocker_findings: 0
major_findings: 0
minor_findings: 0
blocks_completion: false
---

# Review: Protect v3-core bootstrap contract and dirty baseline

## Scope

A fresh, read-only Codex verifier session inspected the active plan, task plan,
baseline and file-map scripts, regression tests, v2 compatibility report,
release matrix, and task-local verification evidence. It did not edit files or
invoke lifecycle or finalization commands.

## Evidence

- Harness verification passed at `2026-07-10 14:57:33 +0700`.
- The full harness suite selected 35 tests, passed 35, failed 0, and timed out
  0.
- The release check passed.

## Findings

No blocker, major, or minor findings.

The verifier confirmed that dirty or unborn Git uses snapshot tracking while
clean Git preserves a validated ref path; snapshot creation and comparison
handle ignored paths, symlinks, hashing, and approved deletions symmetrically;
snapshot output rejects symlink destinations and unreadable traversal; the test
runner isolates ambient harness controls; and legacy v2 `baseline_ref` tasks
retain a validated compatibility path.

## Residual Risk

The verifier reported that the suite is environment-sanitized rather than fully
hermetic because it preserves `PATH`, `HOME`, and `TMPDIR`. The v2 baseline
report correctly states that v3 authority controls remain planned rather than
implemented.

This review is role-separated but not model-independent: the verifier was a
fresh OpenAI Codex session. A locally installed Claude CLI was probed for a
different-provider review but returned no recoverable verdict, so it is not
counted as verification evidence.
