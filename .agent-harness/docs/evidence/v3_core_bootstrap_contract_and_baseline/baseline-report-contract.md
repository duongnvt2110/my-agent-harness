# Required Check Evidence: baseline-report-contract

task_id: v3_core_bootstrap_contract_and_baseline
check_id: baseline-report-contract
type: automated
blocking: true
timeout_seconds: 180
result: pass
exit_code: 0
started_at: 2026-07-10 22:53:31 +0700
finished_at: 2026-07-10 22:53:31 +0700

## Command

```text
rtk rg -n 'workflow_version|public_cli|package_shape|known_gaps|release_invariants' docs/reports/vnext-baseline.md docs/TEST_MATRIX.md
```

## Output

```text
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LC_CTYPE = "C.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
docs/TEST_MATRIX.md:26:| ID | release_invariants | Required proof | Planned gate |
docs/reports/vnext-baseline.md:11:- workflow_version: legacy v2-compatible lifecycle; the template currently
docs/reports/vnext-baseline.md:24:public_cli:
docs/reports/vnext-baseline.md:78:package_shape:
docs/reports/vnext-baseline.md:111:release_invariants are defined in `docs/TEST_MATRIX.md`. From v3-core onward,
docs/reports/vnext-baseline.md:117:known_gaps:
```
