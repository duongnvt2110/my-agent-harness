# Required Check Evidence: harness-regression-suite

task_id: v3_core_bootstrap_contract_and_baseline
check_id: harness-regression-suite
type: automated
blocking: true
timeout_seconds: 900
result: pass
exit_code: 0
started_at: 2026-07-10 22:53:31 +0700
finished_at: 2026-07-10 22:54:56 +0700

## Command

```text
rtk ./tests/harness/run_all.sh
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
Running test_baseline_contract.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Baseline contract regression passed.
Running test_behavior_baseline_approval_snapshot.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Behavior baseline approval snapshot regression passed.
Running test_behavior_baseline_brownfield_characterization.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Behavior baseline brownfield characterization regression passed.
Running test_behavior_baseline_brownfield_existing_tests.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Behavior baseline brownfield existing-tests regression passed.
Running test_behavior_baseline_greenfield_none.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Behavior baseline greenfield none regression passed.
Running test_benchmark_suite.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Running BENCH-003 result schema check...
Running BENCH-004 install fixture...
Running BENCH-006 context/control evaluator...
Running BENCH-007 repair-loop metrics...
Running BENCH-010 long-plan decomposition workflow...
Running BENCH-009 brownfield issue-resolution suite...
  brownfield BROWN-006...
  brownfield BROWN-007...
  brownfield BROWN-008...
  brownfield BROWN-009...
  brownfield BROWN-010...
Running BENCH-002 project-build suite...
Running BENCH-005 agent-task evaluator...
Running BENCH-001 deterministic test runner...
Running BENCH-008 history comparison...
Benchmark result: pass 140/140
JSON: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.h1AKXbaq/latest.json
Markdown: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.h1AKXbaq/latest.md
Benchmark suite regression passed.
Running test_brownfield_benchmark_suite.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
  brownfield BROWN-006...
  brownfield BROWN-007...
  brownfield BROWN-008...
  brownfield BROWN-009...
  brownfield BROWN-010...
Brownfield benchmark regression passed.
Running test_check_file_map_snapshot.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Check file-map snapshot regression passed.
Running test_classify_repo_brownfield.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Brownfield classification regression passed.
Running test_classify_repo_greenfield.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Greenfield classification regression passed.
Running test_classify_repo_hybrid.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Hybrid classification regression passed.
Running test_consume_plan_and_rollup.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Plan consume and roll-up regression passed.
Running test_context_adr_exact_match.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/context_adr_exact_match/localization.md
Created conventions: docs/evidence/context_adr_exact_match/brownfield-conventions.md
Selected repository intelligence for: context_adr_exact_match
Created context pack: docs/evidence/context_adr_exact_match/context-pack.md
Context ADR exact-match regression passed.
Running test_context_retrieval_quality.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/context_retrieval_quality/localization.md
Created conventions: docs/evidence/context_retrieval_quality/brownfield-conventions.md
Selected repository intelligence for: context_retrieval_quality
Created context pack: docs/evidence/context_retrieval_quality/context-pack.md
Context retrieval quality regression passed.
Running test_create_baseline_snapshot.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Create baseline snapshot regression passed.
Running test_detect_change_baseline_git.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Detect change baseline git regression passed.
Running test_detect_change_baseline_snapshot.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Detect change baseline snapshot regression passed.
Running test_dirty_git_active_plan_baseline.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Dirty Git public activation baseline regression passed.
Running test_dirty_git_baseline_snapshot.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Dirty Git baseline snapshot regression passed.
Running test_epic_story_task_lifecycle.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Task lifecycle regression passed.
Running test_export_harness_package.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Export harness package regression passed.
Running test_export_install_integrity.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Export install integrity regression passed.
Running test_failure_injection.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Failure injection regression passed.
Running test_finalize_unique_completed_file.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Finalize unique completed file regression passed.
Running test_finalize_updates_epic_progress.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Finalize epic progress regression passed.
Running test_harness_execution.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/harness_execution_temp/localization.md
Created conventions: docs/evidence/harness_execution_temp/brownfield-conventions.md
Selected repository intelligence for: harness_execution_temp
Created context pack: docs/evidence/harness_execution_temp/context-pack.md
Spec clarification checks passed.
Work alignment checks passed.
Work alignment checks passed.
ADR awareness checks passed.
Context pack checks passed.
Context pack checks passed.
Execution harness checks passed.
Running test_harness_regressions.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Merged harness package into: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.kcOc5KjR/export
Created zip archive: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.kcOc5KjR/harness-template.zip
Package integrity checks passed.
Script interface checks passed.
Template harness regression checks passed.
Running test_long_plan_workflow.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Long plan workflow regression passed.
Running test_mode_aware_context_pack.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Mode-aware context pack regression passed.
Running test_mode_aware_verification.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Mode-aware verification regression passed.
Running test_plan_decomposition.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Missing required heading '## Feature Intake' in /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.ifCWes3l/bad-current.md
Plan decomposition regression passed.
Running test_plan_decomposition_semantic.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Placeholder content must be replaced before approval: Describe the user or system problem the task solves.
Plan decomposition semantic regression passed.
Running test_repository_intelligence.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Context index written: docs/context/memory-index.json
Created localization: docs/evidence/repository_intelligence_temp/localization.md
Created conventions: docs/evidence/repository_intelligence_temp/brownfield-conventions.md
Selected repository intelligence for: repository_intelligence_temp
Created context pack: docs/evidence/repository_intelligence_temp/context-pack.md
Repository intelligence regression passed.
Running test_test_runner_timeout.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Deterministic test runner timeout regression passed.
Running test_verify_routing.sh (timeout: 120s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = "C.UTF-8",
	LC_CTYPE = "C.UTF-8",
	LC_TERMINAL = "iTerm2",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
Verification routing regression passed.

Harness test summary
started_at: 2026-07-10 22:53:32 +0700
finished_at: 2026-07-10 22:54:56 +0700
selected: 35
passed: 35
failed: 0
timed_out: 0
Harness test suite passed.
```
