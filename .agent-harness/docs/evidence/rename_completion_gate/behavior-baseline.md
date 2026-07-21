# Behavior Baseline

task_id: rename_completion_gate
behavior_tracking: existing_tests
created_before_execution: true
behavior_baseline_path: docs/evidence/rename_completion_gate/behavior-baseline.md

## Existing Behavior To Preserve

- Preserve the behavior covered by the existing regression tests.

## Existing Tests

- tests/.DS_Store
- tests/fixtures/baseline/approval-snapshot/README.md
- tests/fixtures/baseline/approval-snapshot/output.json
- tests/fixtures/baseline/brownfield-no-tests/README.md
- tests/fixtures/baseline/brownfield-no-tests/src/app.txt
- tests/fixtures/baseline/brownfield-with-tests/README.md
- tests/fixtures/baseline/brownfield-with-tests/src/app.txt
- tests/fixtures/baseline/brownfield-with-tests/tests/service_test.go
- tests/fixtures/baseline/git-repo/README.md
- tests/fixtures/baseline/git-repo/src/app.txt
- tests/fixtures/baseline/greenfield/README.md
- tests/fixtures/baseline/greenfield/src/app.txt
- tests/fixtures/baseline/no-git-repo/README.md
- tests/fixtures/baseline/no-git-repo/src/app.txt
- tests/fixtures/context-retrieval/.gitkeep
- tests/fixtures/failure-injection/.gitkeep
- tests/fixtures/lifecycle/.gitkeep
- tests/fixtures/repo-modes/brownfield/.github/workflows/ci.yml
- tests/fixtures/repo-modes/brownfield/Dockerfile
- tests/fixtures/repo-modes/brownfield/cmd/server/main.go
- tests/fixtures/repo-modes/brownfield/docs/decisions/ADR-0001-brownfield-notes.md
- tests/fixtures/repo-modes/brownfield/expected-repo-profile.yml
- tests/fixtures/repo-modes/brownfield/internal/order/repository.go
- tests/fixtures/repo-modes/brownfield/internal/order/service.go
- tests/fixtures/repo-modes/brownfield/internal/order/service_test.go
- tests/fixtures/repo-modes/brownfield/migrations/001_create_orders.sql
- tests/fixtures/repo-modes/greenfield/README.md
- tests/fixtures/repo-modes/greenfield/docs/decisions/ADR-0001-initial-architecture.md
- tests/fixtures/repo-modes/greenfield/expected-repo-profile.yml
- tests/fixtures/repo-modes/hybrid/docs/decisions/ADR-0001-hybrid-note.md
- tests/fixtures/repo-modes/hybrid/docs/epics/new-worker/epic.md
- tests/fixtures/repo-modes/hybrid/expected-repo-profile.yml
- tests/fixtures/repo-modes/hybrid/internal/user/service.go
- tests/fixtures/repo-modes/hybrid/internal/user/service_test.go
- tests/fixtures/sample_harness_testing_tasks/clarifications.md
- tests/fixtures/sample_harness_testing_tasks/epic-memory.md
- tests/fixtures/sample_harness_testing_tasks/epic.md
- tests/fixtures/sample_harness_testing_tasks/integration-contract.md
- tests/fixtures/sample_harness_testing_tasks/progress.md
- tests/fixtures/sample_harness_testing_tasks/stories.jsonl
- tests/harness/run_all.sh
- tests/harness/test_ac_coverage.sh
- tests/harness/test_ac_evidence.sh
- tests/harness/test_adr_review_binding.sh
- tests/harness/test_approval.sh
- tests/harness/test_baseline_contract.sh
- tests/harness/test_behavior_baseline_approval_snapshot.sh
- tests/harness/test_behavior_baseline_brownfield_characterization.sh
- tests/harness/test_behavior_baseline_brownfield_existing_tests.sh
- tests/harness/test_behavior_baseline_greenfield_none.sh
- tests/harness/test_benchmark_suite.sh
- tests/harness/test_bootstrap_runner.sh
- tests/harness/test_brownfield_benchmark_suite.sh
- tests/harness/test_budget_guard.sh
- tests/harness/test_budget_routing.sh
- tests/harness/test_capability.sh
- tests/harness/test_check_file_map_snapshot.sh
- tests/harness/test_check_final_report.sh
- tests/harness/test_check_rollup_projection.sh
- tests/harness/test_check_test_report.sh
- tests/harness/test_checkpoint_contract.sh
- tests/harness/test_classify_repo_brownfield.sh
- tests/harness/test_classify_repo_greenfield.sh
- tests/harness/test_classify_repo_hybrid.sh
- tests/harness/test_completion_judge.sh
- tests/harness/test_consume_plan_and_rollup.sh
- tests/harness/test_context_adr_exact_match.sh
- tests/harness/test_context_retrieval_quality.sh
- tests/harness/test_create_baseline_snapshot.sh
- tests/harness/test_current_state_event_chain.sh
- tests/harness/test_current_state_validator.sh
- tests/harness/test_dependency_artifact_contract.sh
- tests/harness/test_detect_change_baseline_git.sh
- tests/harness/test_detect_change_baseline_snapshot.sh
- tests/harness/test_dirty_git_active_plan_baseline.sh
- tests/harness/test_dirty_git_baseline_snapshot.sh
- tests/harness/test_emergency_revocation.sh
- tests/harness/test_enforcement_gate.sh
- tests/harness/test_epic_story_task_lifecycle.sh
- tests/harness/test_export_harness_package.sh
- tests/harness/test_export_install_integrity.sh
- tests/harness/test_external_saga.sh
- tests/harness/test_failure_history_contract.sh
- tests/harness/test_failure_injection.sh
- tests/harness/test_finalize_unique_completed_file.sh
- tests/harness/test_finalize_updates_epic_progress.sh
- tests/harness/test_harness_execution.sh
- tests/harness/test_harness_regressions.sh
- tests/harness/test_intake_graph.sh
- tests/harness/test_long_plan_workflow.sh
- tests/harness/test_mode_aware_context_pack.sh
- tests/harness/test_mode_aware_verification.sh
- tests/harness/test_network_capability.sh
- tests/harness/test_network_request_adapter.sh
- tests/harness/test_offline_capability_guard.sh
- tests/harness/test_plan_decomposition.sh
- tests/harness/test_plan_decomposition_semantic.sh
- tests/harness/test_policy_binding_artifact.sh
- tests/harness/test_policy_risk_binding.sh
- tests/harness/test_public_cli_compatibility.sh
- tests/harness/test_recipe_loader.sh
- tests/harness/test_recover_finalization.sh
- tests/harness/test_release_attestation.sh
- tests/harness/test_release_fixture_inventory.sh
- tests/harness/test_release_invariant_fixture_gate.sh
- tests/harness/test_repository_intelligence.sh
- tests/harness/test_required_review_contract.sh
- tests/harness/test_run_events.sh
- tests/harness/test_run_successor_lineage.sh
- tests/harness/test_sandbox_adapter.sh
- tests/harness/test_spec_lock.sh
- tests/harness/test_task_plan_consistency.sh
- tests/harness/test_task_schema.sh
- tests/harness/test_template_cleanliness.sh
- tests/harness/test_test_report_contract.sh
- tests/harness/test_test_runner_timeout.sh
- tests/harness/test_transition_state_chain_guard.sh
- tests/harness/test_transition_state_validation.sh
- tests/harness/test_trusted_time.sh
- tests/harness/test_v2_v3_migration.sh
- tests/harness/test_v3_authority_exclusivity.sh
- tests/harness/test_v3_finalization_transaction.sh
- tests/harness/test_verification_pass_contract.sh
- tests/harness/test_verifier_adapter.sh
- tests/harness/test_verifier_verdict.sh
- tests/harness/test_verify_routing.sh
- tests/harness/test_workflow_dispatch.sh
- tests/harness/test_workspace_guard.sh
- tests/harness/test_worktree_integration.sh
- tests/harness/test_writer_lease.sh
- tests/test_v3_projection_replay_audit.sh

## Required Regression Checks

- Run the matching targeted tests before final verification.

## Gaps

- None.
