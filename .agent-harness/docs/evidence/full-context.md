# Full Context

The active implementation goal is to complete the v3 repository-local agent
harness defined by `my_docs/agent-harness-research-review-toc.md`.

The first implementation slice covers v3-only authority dispatch, canonical
state transitions, and removal of legacy v2 fallback authority. Existing
scripts and tests must be reused only after they satisfy the active v3
contract; contradictory legacy behavior must be replaced and covered by
regression tests.

