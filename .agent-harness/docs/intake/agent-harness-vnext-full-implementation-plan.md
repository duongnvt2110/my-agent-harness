# Agent Harness vNext — Full Implementation Plan

## Update History

Updated: 2026-07-10 14:04

## Approved Design Authority

The normative architecture decisions approved during the vNext grilling
session are recorded in:

`my_docs/2026_07_10_agent_harness_vnext_approved_design.md`

That ledger is binding for implementation. Where older wording in this plan
conflicts with the approved ledger, the ledger controls. The first release
boundary is `v3-core`; later enforcement and orchestration features ship as
separately verified releases without weakening v3-core invariants.

## 1. Objective

Upgrade the current harness from an execution-focused system:

```text
Plan
  → Execute
  → Verify
  → Review
  → Finalize
```

into a complete repository-governance harness:

```text
Requirement governance
  + stateful orchestration
  + agent-role separation
  + policy enforcement
  + isolated execution
  + context management
  + deterministic verification
  + recovery
  + observability
  + benchmarking
```

The harness must prevent an agent from:

- implementing an unclear request;
- inventing business rules;
- decomposing work before the specification is ready;
- editing files outside the approved scope;
- running unsafe commands;
- escalating permissions through a subagent;
- losing state after interruption;
- hiding previous verification failures;
- marking a task complete before all gates pass.

---

# 2. Architectural decisions

## 2.1 Separate requirement and execution contracts

Use two different contracts:

```text
spec.locked.md
  = confirmed requirement contract

current.md
  = generated read-only execution projection for workflow version 3
```

For workflow version 3, `current.md` must be generated from authoritative run
state and must never be created or edited directly from a raw request or plan.

Required flow:

```text
user request
  ↓
understanding
  ↓
clarification when required
  ↓
spec lock
  ↓
task breakdown
  ↓
execution contract
```

## 2.2 Separate workflow states from agent roles

Workflow states describe where the task is.

```text
INTAKE
UNDERSTANDING_GATE
CLARIFICATION_REQUIRED
HUMAN_ANSWERED
SPEC_LOCKED
TASK_BREAKDOWN
PLAN_READY
IMPLEMENTING
VERIFYING
FAILED
REMEDIATING
PASSED
FINALIZED
```

Agent roles describe who performs an action.

```text
Primary Agent
Oracle
Researcher
Verifier
Human
Harness Scripts
```

Do not create a permanent agent for every state.

The Primary Agent may understand, plan, implement, and remediate, but its permissions change according to the workflow state.

## 2.3 Scripts remain the authority

```text
Agent prompt      = guidance
Agent role        = capability profile
Policy engine     = authorization
Gate scripts      = enforcement
Tests and oracles = verification
Finalizer script  = completion authority
```

The model must never be the authority for state transitions, permissions, or finalization.

## 2.4 Preserve existing strengths

Keep and extend the existing:

- active-plan contract;
- baseline and behavior-baseline checks;
- repository intelligence;
- context pack;
- file-map checking;
- required checks;
- evidence generation;
- review gate;
- remediation scripts;
- benchmark framework;
- package export and integrity checks.

Do not rewrite these systems unnecessarily.

---

# 3. Target workflow

## 3.1 Main workflow

```text
NO_TASK
  ↓
INTAKE
  ↓
UNDERSTANDING_GATE
  ├── blocking unknowns ──→ CLARIFICATION_REQUIRED
  │                              ↓
  │                         HUMAN_ANSWERED
  │                              ↓
  └──────────────────── UNDERSTANDING_GATE
                                 ↓
                            SPEC_LOCKED
                                 ↓
                           TASK_BREAKDOWN
                                 ↓
                             PLAN_READY
                                 ↓
                           IMPLEMENTING
                                 ↓
                             VERIFYING
                         ┌───────┴───────┐
                         ↓               ↓
                       FAILED          PASSED
                         ↓               ↓
                    REMEDIATING      FINALIZED
                         ↓
                     VERIFYING
```

## 3.2 Runtime side states

Add states needed by real agent runtimes:

```text
PAUSED
APPROVAL_REQUIRED
STUCK
RECOVERY_REQUIRED
ROLLED_BACK
CANCELLED
```

Transitions:

```text
Any active state
  ├── human interruption ──→ PAUSED
  ├── risky action ────────→ APPROVAL_REQUIRED
  ├── cancellation ────────→ CANCELLED
  └── corrupted run ───────→ RECOVERY_REQUIRED

PAUSED
  └── resume ──────────────→ previous state

RECOVERY_REQUIRED
  ├── resume checkpoint ───→ previous safe state
  └── rollback ────────────→ ROLLED_BACK

FAILED
  └── repeated failure ────→ STUCK
```

## 3.3 State transition rules

Every transition must be performed through one script:

```text
.agent-harness/scripts/transition-state
```

The script must:

1. validate the current state;
2. validate the requested transition;
3. run transition-specific guards;
4. append a state-transition event;
5. update the state atomically;
6. regenerate the read-only `current.md` compatibility projection.

Direct editing of lifecycle fields must be prohibited.

---

# 4. Target repository structure

```text
.agent-harness/
  harness.sh

  agents/
    primary.md
    oracle.md
    researcher.md
    verifier.md

  intake/
    understanding-template.md
    clarification-template.md
    spec-locked-template.md
    definition-of-ready.yaml

  policies/
    state-transitions.yaml
    agent-permissions.yaml
    command-rules.yaml
    file-rules.yaml
    network-rules.yaml
    assumption-rules.yaml
    risk-classification.yaml

  recipes/
    bugfix.yaml
    feature.yaml
    refactor.yaml
    migration.yaml
    review-only.yaml
    harness-change.yaml

  runtime/
    active-run.json
    locks/
    checkpoints/

  intakes/
    <intake-id>/
      manifest.json

      requirements/
        user-request.md
        understanding.md
        definition-of-ready.json
        clarification-request.md
        human-answers.jsonl
        spec.locked.md
        spec-hash.txt
        amendments/

      planning/
        task-breakdown.md
        task-breakdown.json
        implementation-plan.md
        file-map.yaml
        verification-plan.yaml

  runs/
    <run-id>/
      manifest.json
      state.json
      events.jsonl
      intake-ref.json
      task-ref.json

      execution/
        commands.jsonl
        file-events.jsonl
        tool-results/
        context-manifest.json
        context-summary.md
        checkpoint.json

      verification/
        ac-coverage.json
        verification.json
        failure-history.jsonl
        remediation.md
        verifier-verdict.json
        completion-judge.json

      final/
        diff.patch
        final-report.md
        run-metrics.json

  scripts/
    # Existing scripts
    ...

    # New workflow scripts
    start-intake
    analyze-understanding
    check-definition-of-ready
    request-clarification
    record-human-answer
    lock-spec
    amend-spec
    break-task
    check-plan-ready
    transition-state

    # New authorization scripts
    authorize-action
    check-command-policy
    check-file-policy
    check-network-policy
    calculate-effective-permissions

    # New runtime scripts
    create-run
    acquire-run-lock
    release-run-lock
    pause-run
    resume-run
    cancel-run
    create-checkpoint
    rollback-checkpoint
    recover-run

    # New verification scripts
    check-ac-coverage
    run-verifier
    run-completion-judge
    record-failure
    detect-loop

    # New observability scripts
    append-event
    record-command
    record-tool-result
    generate-run-manifest
    generate-run-metrics
```

Existing task evidence may remain under:

```text
.agent-harness/docs/evidence/<task-id>/
```

Run-level evidence should live under:

```text
.agent-harness/runs/<run-id>/
```

Task evidence is the user-facing summary. Run evidence is the complete audit trail.
The intake owns requirements and the task graph. A run references one intake
and one task and owns only the evidence for that materially distinct execution
attempt.

---

# 5. Agent-role architecture

## 5.1 Primary Agent

Responsibilities:

- understand the request;
- inspect repository context;
- propose clarification questions;
- prepare the locked specification;
- plan and decompose work;
- implement approved changes;
- perform remediation.

Permissions depend on workflow state.

```text
UNDERSTANDING_GATE
  read allowed
  search allowed
  edits denied
  mutating commands denied

TASK_BREAKDOWN
  read allowed
  planning-artifact writes allowed
  application edits denied

IMPLEMENTING
  edits allowed only in approved file map
  approved commands allowed

REMEDIATING
  edits allowed only in remediation scope
```

## 5.2 Oracle

Read-only specialist inspired by Amp-style architecture review.

Responsibilities:

- architecture analysis;
- business-logic review;
- plan critique;
- debugging advice;
- high-risk change review.

Restrictions:

```text
source edit: deny
task state mutation: deny
finalization: deny
subagent spawning: deny unless explicitly allowed
```

Use Oracle when:

- task lane is `high_risk`;
- architecture boundary is uncertain;
- core business logic crosses modules or services;
- verification fails repeatedly;
- the human explicitly requests architecture review.

## 5.3 Researcher

Read-only specialist for:

- dependency documentation;
- remote repositories;
- existing implementation patterns;
- external API contracts.

Restrictions:

- no source edits;
- no state transitions;
- no secrets;
- no uncontrolled network access;
- all sources recorded in the run manifest.

## 5.4 Verifier

Independent role that must not share implementation authority.

Responsibilities:

- evaluate acceptance criteria;
- inspect the final diff;
- run approved checks;
- identify missing behavior coverage;
- produce a structured verdict.

Restrictions:

```text
source edit: deny
remediation: deny
scope expansion: deny
task finalization: deny
```

## 5.5 Human

The human owns:

- requirement clarification;
- business-rule decisions;
- architecture decisions when repository evidence is insufficient;
- scope expansion;
- dependency changes;
- environment changes;
- risky approvals;
- specification amendments.

## 5.6 Harness scripts

Harness scripts own:

- state transitions;
- action authorization;
- task activation;
- verification routing;
- rollback;
- completion;
- archival.

---

# 6. Effective permission model

Calculate permissions as an intersection:

```text
effective permission =
  global policy
  ∩ workflow-state policy
  ∩ agent-role policy
  ∩ parent-agent authority
  ∩ task file map
  ∩ trust policy
```

A subagent must never receive more authority than its parent.

Example:

```text
Primary agent in IMPLEMENTING:
  edit approved file map

Oracle spawned by Primary:
  parent permits editing
  Oracle role denies editing

Effective Oracle permission:
  edit denied
```

Add:

```text
.agent-harness/scripts/calculate-effective-permissions
```

Inputs:

```json
{
  "run_id": "run-...",
  "state": "IMPLEMENTING",
  "role": "oracle",
  "parent_role": "primary",
  "tool": "edit",
  "target": "internal/order/service.go"
}
```

Output:

```json
{
  "decision": "deny",
  "policy_ids": [
    "role.oracle.edit-denied"
  ],
  "reason": "Oracle is a read-only role."
}
```

---

# 7. Phase-by-phase implementation

## Phase 0 — Protect the current baseline

### Goal

Preserve existing behavior before changing architecture.

### Tasks

1. Run the current harness regression suite.
2. Record the currently passing and failing tests.
3. Record current benchmark output.
4. Create a baseline snapshot for:
   - public commands;
   - active-plan schema;
   - verification output;
   - export package shape.
5. Add a migration ADR.

### Add

```text
.agent-harness/docs/decisions/0004-harness-vnext-architecture.md
.agent-harness/docs/reports/vnext-baseline.md
```

### Acceptance criteria

- Existing behavior is documented.
- Existing test failures are distinguished from new regressions.
- The migration approach is recorded.
- No existing public command is silently removed.

---

## Phase 1 — Introduce workflow version 3

### Goal

Add the new state model without immediately breaking existing plans.

### Modify

```text
WORKFLOW.md
CONTEXT.md
README.md
AGENTS.md
.agent-harness/docs/PLANS.md
.agent-harness/docs/exec-plans/TEMPLATE.md
.agent-harness/scripts/check-active-plan-contract.sh
```

### Add

```text
.agent-harness/policies/state-transitions.yaml
.agent-harness/scripts/transition-state
.agent-harness/tests/harness/test_state_transitions.sh
```

### Migration behavior

For active `workflow_version: 2` tasks that are not explicitly migrated:

```text
status and lifecycle_phase in current.md remain authoritative
```

For `workflow_version: 3`:

```text
runs/<run-id>/state.json is the sole lifecycle authority
current.md is an atomically generated read-only compatibility projection
```

### State file

```json
{
  "schema_version": 1,
  "run_id": "run-20260710-...",
  "task_id": "task_id",
  "state": "UNDERSTANDING_GATE",
  "previous_state": "INTAKE",
  "active_role": "primary",
  "failure_seen": false,
  "paused_from": null,
  "updated_at": "..."
}
```

### Acceptance criteria

- Illegal transitions are rejected.
- State writes use a temporary file and atomic rename.
- Every successful transition writes an event.
- Existing workflow-version-2 plans remain legacy-owned until finalized,
  cancelled, rolled back, or explicitly migrated.

---

## Phase 2 — Add run identity and append-only events

### Goal

Ensure human, agent, CLI, and harness messages cannot be confused.

### Add

```text
.agent-harness/scripts/create-run
.agent-harness/scripts/append-event
.agent-harness/scripts/generate-run-manifest
.agent-harness/runtime/active-run.json
.agent-harness/runs/
```

### Event schema

```json
{
  "schema_version": 1,
  "sequence": 12,
  "event_id": "evt-...",
  "run_id": "run-...",
  "timestamp": "...",
  "actor": {
    "type": "human",
    "id": "local-user",
    "channel": "tui"
  },
  "event_type": "HUMAN_MESSAGE",
  "state": "CLARIFICATION_REQUIRED",
  "payload_ref": "requirements/human-answers.jsonl"
}
```

Supported actor types:

```text
human
primary_agent
oracle
researcher
verifier
cli
harness
tool
```

Supported core event types:

```text
RUN_STARTED
STATE_CHANGED
HUMAN_MESSAGE
AGENT_MESSAGE
CLARIFICATION_REQUESTED
SPEC_LOCKED
TOOL_REQUESTED
TOOL_AUTHORIZED
TOOL_DENIED
COMMAND_STARTED
COMMAND_FINISHED
FILE_CHANGED
CHECK_STARTED
CHECK_PASSED
CHECK_FAILED
CHECKPOINT_CREATED
ROLLBACK_COMPLETED
RUN_PAUSED
RUN_RESUMED
RUN_FINALIZED
```

### Acceptance criteria

- Every event has explicit actor identity.
- Sequence numbers are monotonic.
- Events are append-only.
- A TUI human message cannot be interpreted as an agent response.
- A CLI result cannot be interpreted as a human answer.

---

## Phase 3 — Implement intake and proof of understanding

### Goal

Prevent task breakdown before the agent proves task understanding.

### Add

```text
.agent-harness/intake/understanding-template.md
.agent-harness/intake/definition-of-ready.yaml
.agent-harness/scripts/start-intake
.agent-harness/scripts/analyze-understanding
.agent-harness/scripts/check-definition-of-ready
```

### Understanding artifact

Require:

```text
User Goal
Business Context
Current Behavior
Target Behavior
Core Business Rules
Architecture Boundary
Data Ownership
API and Integration Boundaries
Permissions and Security
Repo Evidence
Acceptance Criteria
Testable Examples
Out of Scope
Blocking Unknowns
Non-Blocking Assumptions
Implementation Risks
```

### Definition of Ready

Required checks:

```text
user goal present
current behavior grounded in repo evidence
target behavior present
business rules complete
architecture boundary complete
acceptance criteria behavior-based
examples present for business logic
out-of-scope section present
blocking unknowns empty
verification strategy possible
```

### Acceptance criteria

- The harness does not ask “Do you understand?”
- Understanding is represented by a checked artifact.
- Missing business logic blocks progress.
- Missing architecture boundaries block medium/high-risk work.
- Minor naming or formatting choices may become recorded assumptions.
- No task decomposition is allowed before this gate passes.

---

## Phase 4 — Implement clarification and human-answer loop

### Goal

Make clarification a first-class, resumable workflow.

### Add

```text
.agent-harness/intake/clarification-template.md
.agent-harness/scripts/request-clarification
.agent-harness/scripts/record-human-answer
.agent-harness/scripts/recheck-understanding
```

### Logic

```text
UNDERSTANDING_GATE
  ↓ blocking unknown
CLARIFICATION_REQUIRED
  ↓ human response
HUMAN_ANSWERED
  ↓
UNDERSTANDING_GATE
```

Do not transition directly from `HUMAN_ANSWERED` to `SPEC_LOCKED`.

### Clarification question rules

Ask only questions that affect:

- user goal;
- business behavior;
- architecture;
- data ownership;
- integration contracts;
- permissions;
- acceptance criteria;
- irreversible migration;
- security;
- compatibility.

Do not block for:

- minor naming;
- formatting;
- implementation details already governed by repository conventions.

### Acceptance criteria

- Human answers are persisted with explicit actor identity.
- Multiple clarification rounds are supported.
- The harness records which blocking question each answer resolves.
- The Definition of Ready is rerun after every answer.
- Unresolved questions remain blocking.

---

## Phase 5 — Implement specification lock and amendments

### Goal

Create an immutable requirement contract before decomposition.

### Add

```text
.agent-harness/intake/spec-locked-template.md
.agent-harness/scripts/lock-spec
.agent-harness/scripts/amend-spec
.agent-harness/scripts/check-spec-integrity
```

### Locked specification

Include:

```text
confirmed goal
current behavior
target behavior
business rules
architecture boundary
data flow
permissions
acceptance criteria with IDs
testable examples
out-of-scope items
approved assumptions
compatibility requirements
migration requirements
verification expectations
```

Generate:

```text
spec.locked.md
spec-hash.txt
```

### Amendment logic

After specification lock:

```text
User changes requirement
  ↓
pause implementation
  ↓
create spec amendment
  ↓
invalidate task breakdown
  ↓
invalidate PLAN_READY
  ↓
rerun understanding and readiness gates
```

Do not silently edit a locked specification.

### Acceptance criteria

- A locked specification has a stable hash.
- Direct modification causes integrity failure.
- Amendments are recorded separately.
- Specification changes invalidate downstream plans.
- `decompose-plan.sh` refuses raw plans without a locked specification.

---

## Phase 6 — Replace unsafe plan decomposition

### Goal

Make decomposition consume the locked specification rather than a raw implementation plan.

### Modify

```text
.agent-harness/scripts/decompose-plan.sh
.agent-harness/scripts/check-plan-decomposition.sh
.agent-harness/scripts/check-plan-decomposition-semantic.sh
.agent-harness/scripts/approve-decomposition.sh
.agent-harness/scripts/create-active-plan.sh
```

### New decomposition input

```text
runs/<run-id>/requirements/spec.locked.md
```

### Generated outputs

```text
runs/<run-id>/planning/task-breakdown.md
runs/<run-id>/planning/task-breakdown.json
runs/<run-id>/planning/file-map.yaml
runs/<run-id>/planning/verification-plan.yaml
docs/tasks/tasks.jsonl
```

### Task schema

Each task must contain:

```json
{
  "id": "task_id",
  "title": "Behavior-focused title",
  "goal": "Concrete outcome",
  "depends_on": [],
  "acceptance_criteria": [
    {
      "id": "AC-001",
      "given": "...",
      "when": "...",
      "then": "..."
    }
  ],
  "approved_scopes": [],
  "approved_files": [],
  "approved_deletions": [],
  "verification_checks": [],
  "risk": "normal",
  "source_spec_hash": "..."
}
```

### Remove generic criteria

Do not generate:

```text
Implement the task
Required checks pass
Stay inside scope
```

Those remain process gates, not acceptance criteria.

### Acceptance criteria

- Every generated task traces back to specification ACs.
- Every task has behavior-based outcomes.
- Every task has a candidate file map.
- Every task has an explicit verification mapping.
- A task may depend on another task.
- Decomposition fails if a specification requirement is not assigned.

---

## Phase 7 — Add the PLAN_READY gate

### Goal

Prevent implementation from starting merely because a plan file exists.

### Add

```text
.agent-harness/scripts/check-plan-ready
.agent-harness/scripts/check-architecture-boundary
.agent-harness/scripts/check-product-design-contract
.agent-harness/scripts/check-ac-coverage
```

### PLAN_READY requirements

```text
spec locked and hash valid
task selected
task dependencies satisfied
baseline available
behavior baseline available when required
architecture boundary recorded
file map approved
command profile selected
verification plan complete
every AC mapped to a check
rollback plan present for high-risk work
human approval present when required
no blocking unknowns
```

### Modify

```text
.agent-harness/scripts/approve-active-task.sh
.agent-harness/scripts/approve-plan.sh
```

Consolidate these if they perform overlapping responsibilities.

Approval must transition:

```text
TASK_BREAKDOWN
  → PLAN_READY
```

It must not immediately set implementation to active without running the gate.

### Acceptance criteria

- Implementation cannot start before PLAN_READY passes.
- Every acceptance criterion has verification coverage.
- High-risk tasks require product/design/rollback contracts.
- Task dependencies are enforced.

---

## Phase 8 — Add agent profiles and role routing

### Goal

Adopt the useful part of the opencode/Amp style without fragmenting every state into a separate agent.

### Add

```text
.agent-harness/agents/primary.md
.agent-harness/agents/oracle.md
.agent-harness/agents/researcher.md
.agent-harness/agents/verifier.md
.agent-harness/policies/agent-permissions.yaml
.agent-harness/scripts/select-agent-role
```

### Role routing

```text
UNDERSTANDING_GATE
  Primary

Architecture uncertainty
  Oracle

External dependency uncertainty
  Researcher

IMPLEMENTING
  Primary

VERIFYING
  Verifier

Repeated failure
  Oracle + Primary remediation

FINALIZED
  Harness scripts only
```

### Lane requirements

```text
tiny:
  Primary only
  Verifier optional when review_required=false

normal:
  Primary + Verifier

high_risk:
  Primary + Oracle plan review + Verifier
```

### Acceptance criteria

- Oracle and Verifier cannot edit source code.
- Role invocation is recorded in events.
- Child authority cannot exceed parent authority.
- Finalization remains script-owned.

---

## Phase 9 — Implement the policy engine

### Goal

Authorize actions before execution.

### Add

```text
.agent-harness/policies/command-rules.yaml
.agent-harness/policies/file-rules.yaml
.agent-harness/policies/network-rules.yaml
.agent-harness/policies/assumption-rules.yaml
.agent-harness/scripts/authorize-action
.agent-harness/scripts/check-command-policy
.agent-harness/scripts/check-file-policy
.agent-harness/scripts/check-network-policy
.agent-harness/scripts/calculate-effective-permissions
```

### Policy decisions

```text
allow
ask
deny
```

### Example command policy

```yaml
allowed:
  - "git status"
  - "git diff*"
  - "go test*"
  - "npm test*"
  - "pytest*"
  - "bash .agent-harness/harness.sh *"

ask:
  - "go get*"
  - "npm install*"
  - "pip install*"
  - "docker compose up*"

denied:
  - "git push*"
  - "git reset --hard*"
  - "rm -rf*"
  - "sudo *"
  - "curl * | sh"
  - "cat .env*"
  - "printenv*"
```

### Sensitive-path policy

Always deny:

```text
.env
.env.*
**/*.pem
**/*.key
secrets/**
.ssh/**
.aws/**
credential stores
```

### Important limitation

A repository harness cannot universally intercept every native edit tool from every coding agent.

Implement two layers:

```text
Supported agent adapter:
  pre-tool authorization

Universal fallback:
  sandbox + post-edit file-map validation
```

Adapters may later integrate with:

- opencode permissions;
- Claude Code hooks;
- Codex execution wrappers;
- Amp permission helpers.

### Acceptance criteria

- Every supported tool request receives a policy decision.
- Unknown commands deny by default in automation mode.
- Scope expansion requires human approval.
- Policy decisions are included in the event log.
- Existing `check-file-map.sh` remains the final universal scope check.

---

## Phase 10 — Add pause, approval, and interactive control

### Goal

Support safe human interaction through TUI, browser, or CLI.

### Add

```text
.agent-harness/scripts/pause-run
.agent-harness/scripts/resume-run
.agent-harness/scripts/request-approval
.agent-harness/scripts/record-approval
.agent-harness/scripts/cancel-run
```

### Logic

```text
Human sends message during implementation
  ↓
record HUMAN_MESSAGE event
  ↓
classify:
  clarification
  approval
  requirement change
  ordinary instruction

Requirement change
  ↓
PAUSED
  ↓
spec amendment workflow

Risky tool request
  ↓
APPROVAL_REQUIRED
  ↓
human approve or deny
```

### Acceptance criteria

- Human and agent messages are never inferred from text formatting.
- A human interruption does not corrupt the active state.
- Resume restores the previous state.
- A new requirement during implementation invalidates the plan when necessary.

---

## Phase 11 — Add runtime locks, worktrees, and checkpoints

### Goal

Make execution recoverable and prevent concurrent corruption.

### Add

```text
.agent-harness/scripts/acquire-run-lock
.agent-harness/scripts/release-run-lock
.agent-harness/scripts/create-worktree
.agent-harness/scripts/cleanup-worktree
.agent-harness/scripts/create-checkpoint
.agent-harness/scripts/rollback-checkpoint
.agent-harness/scripts/recover-run
```

### Lock rules

```text
one active implementation run per task
one writer per worktree
read-only Oracle and Verifier may run concurrently
```

### Checkpoint rules

Create checkpoints:

- before implementation;
- before remediation;
- before approved scope expansion;
- before migrations.

### Rollback behavior

Rollback must:

1. preserve the failed diff;
2. preserve event history;
3. restore the checkpoint;
4. transition to `ROLLED_BACK`;
5. require a new plan before continuing.

### Acceptance criteria

- Two writer runs cannot modify the same workspace.
- An interrupted run can resume.
- A bad remediation can be rolled back.
- Rollback does not delete audit evidence.

---

## Phase 12 — Add optional sandbox enforcement

### Goal

Enforce permissions technically, not only logically.

### Add

```text
.agent-harness/scripts/run-in-sandbox
.agent-harness/policies/sandbox-profiles.yaml
```

### Profiles

```text
understanding:
  filesystem: read-only
  network: denied

planning:
  filesystem: harness planning artifacts only
  network: denied

implementation:
  filesystem: workspace write
  network: denied by default

verification:
  filesystem: read-only except evidence output
  network: denied

remediation:
  filesystem: approved remediation scope
  network: denied by default
```

The initial implementation may use:

- isolated Git worktrees;
- container execution where available;
- platform-specific sandbox adapters later.

### Acceptance criteria

- Planning cannot change application source.
- Network access is off by default.
- Sandbox configuration is included in run evidence.
- Full-access mode requires explicit human approval and an isolated runtime.

---

## Phase 13 — Improve context and session management

### Goal

Use existing repository intelligence effectively while preventing context loss.

### Keep

```text
docs/context/repository-intelligence/
context-pack.md
working-memory.md
context budget checks
```

### Add

```text
.agent-harness/scripts/generate-context-manifest
.agent-harness/scripts/compact-context
.agent-harness/scripts/resume-context
```

### Context manifest

Record:

```json
{
  "files_read": [],
  "repository_intelligence_used": [],
  "adrs_used": [],
  "external_sources_used": [],
  "skills_used": [],
  "token_estimate": 0,
  "generated_at": "..."
}
```

### Compaction rules

A compacted summary must preserve:

- locked spec hash;
- current workflow state;
- accepted assumptions;
- rejected assumptions;
- file map;
- current failures;
- pending verification;
- human decisions.

### Skills policy

Continue following the current ADR:

```text
The harness does not install or own global skills.
```

It may record externally selected skills for reproducibility.

### Acceptance criteria

- A resumed run retains critical decisions.
- Compaction cannot remove blocking questions or failure state.
- Every context source has provenance.
- Skills cannot expand permissions.

---

## Phase 14 — Redesign verification profiles

### Goal

Separate targeted task verification from full harness benchmarks.

### Profiles

```text
targeted:
  checks directly related to the active task

full:
  all task checks
  file map
  evidence
  compatibility
  independent verifier

release:
  full
  harness regression suite
  benchmarks
  export/install integrity
```

### Modify

```text
.agent-harness/scripts/verify.sh
.agent-harness/scripts/run-required-checks.sh
.agent-harness/scripts/run-targeted-checks.sh
.agent-harness/scripts/generate-test-report.sh
.agent-harness/scripts/check-test-contract.sh
```

### Public commands

```bash
bash .agent-harness/harness.sh verify --profile targeted
bash .agent-harness/harness.sh verify --profile full
bash .agent-harness/harness.sh release-check
```

Do not use the complete benchmark as the default required check for every generated task.

### Acceptance criteria

- Normal tasks use targeted checks.
- Full verification runs before finalization.
- Benchmarks run for harness releases, not every application task.
- Each check records AC coverage and evidence.

---

## Phase 15 — Add independent verification and completion judgment

### Goal

Distinguish “tests passed” from “the user’s requested behavior is complete.”

### Add

```text
.agent-harness/scripts/run-verifier
.agent-harness/scripts/run-completion-judge
.agent-harness/scripts/check-ac-coverage
```

### Verifier output

```json
{
  "result": "pass",
  "acceptance_criteria": {
    "AC-001": {
      "result": "pass",
      "evidence": ["..."]
    }
  },
  "scope_result": "pass",
  "compatibility_result": "pass",
  "remaining_risks": []
}
```

### Completion judge questions

```text
Was every confirmed user requirement implemented?
Did behavior match the locked specification?
Was anything outside scope changed?
Are acceptance criteria supported by evidence?
Were any assumptions invented after spec lock?
Are unresolved risks blocking?
```

### Acceptance criteria

- Passing tests alone cannot finalize a task.
- Every AC has direct evidence.
- The Verifier cannot edit source code.
- High-risk work requires independent verification.

---

## Phase 16 — Make failure and remediation history durable

### Goal

Preserve every failure, even after later success.

### Modify

```text
.agent-harness/scripts/verify.sh
.agent-harness/scripts/check-remediation-trace.sh
.agent-harness/scripts/remediate.sh
.agent-harness/scripts/diagnose-failure.sh
.agent-harness/scripts/create-repair-plan.sh
```

### Add

```text
.agent-harness/scripts/record-failure
.agent-harness/scripts/detect-loop
```

### Failure history

Never delete historical failure information.

Use:

```text
runs/<run-id>/verification/failure-history.jsonl
```

The latest convenience file may be replaced, but the history remains append-only.

### Remediation requirements

If any blocking failure occurred:

```text
remediation.md required before finalization
```

The remediation report must include:

- failed check;
- evidence;
- root-cause classification;
- approved remediation scope;
- repair plan;
- files changed;
- rerun results.

### Loop detection

Transition to `STUCK` when:

- the same check fails three times with the same signature;
- the same file is repeatedly changed without progress;
- verification alternates between the same failures;
- the remediation scope repeatedly expands.

### Acceptance criteria

- Previous failures remain visible after success.
- Finalization requires remediation evidence when `failure_seen=true`.
- Repeated failures trigger human escalation.
- Remediation cannot silently expand scope.

---

## Phase 17 — Fix finalization ordering and atomicity

### Goal

Ensure no task becomes completed before every final gate succeeds.

### Modify

```text
.agent-harness/scripts/finalize-task.sh
.agent-harness/scripts/consume-plan.sh
.agent-harness/scripts/task.sh
.agent-harness/scripts/update-epic-progress.sh
```

### Required finalization order

```text
1. Acquire finalization lock.
2. Run full verification.
3. Validate verification-pass evidence.
4. Validate test report.
5. Validate AC coverage.
6. Validate independent verifier verdict.
7. Validate completion judge.
8. Validate remediation history.
9. Validate ADR impact.
10. Validate required review.
11. Generate final report.
12. Validate final report.
13. Prepare completed-plan destination.
14. Mark child task DONE.
15. Update story and epic rollups.
16. Set state FINALIZED.
17. Write completion metadata.
18. Atomically move current.md.
19. Release lock.
```

Do not set:

```text
status=COMPLETED
lifecycle_phase=COMPLETED
```

before checks 1–13 complete.

### Recovery journal

Add a finalization transaction journal:

```text
runs/<run-id>/final/finalization-transaction.json
```

If finalization crashes, rerunning it must continue safely or roll back incomplete metadata.

### Acceptance criteria

- A failed review cannot leave the task marked completed.
- Finalization is idempotent.
- Rerunning finalization does not duplicate task/story/epic updates.
- The completed plan is written last.

---

## Phase 18 — Add declarative workflow recipes

### Goal

Package repeatable task workflows without hardcoding every path in shell.

### Add

```text
.agent-harness/recipes/bugfix.yaml
.agent-harness/recipes/feature.yaml
.agent-harness/recipes/refactor.yaml
.agent-harness/recipes/migration.yaml
.agent-harness/recipes/review-only.yaml
.agent-harness/recipes/harness-change.yaml
.agent-harness/scripts/load-recipe
```

### Recipe fields

```yaml
name: bugfix
version: 1

required_states:
  - INTAKE
  - UNDERSTANDING_GATE
  - SPEC_LOCKED
  - PLAN_READY
  - IMPLEMENTING
  - VERIFYING
  - FINALIZED

required_roles:
  - primary
  - verifier

verification_profile: targeted
checkpoint_policy: before_edit
oracle_policy: on_repeated_failure
human_approval_policy: on_scope_expansion
```

### Acceptance criteria

- Recipes are declarative.
- Steps are safe to rerun.
- A recipe cannot bypass global state or permission policies.
- Task-specific requirements may strengthen, but not weaken, global policy.

---

## Phase 19 — Add risk, complexity, and budget routing

### Goal

Use different controls for different task sizes without exposing unrestricted model selection.

### Add

```text
.agent-harness/policies/risk-classification.yaml
.agent-harness/scripts/classify-task-risk
.agent-harness/scripts/calculate-run-budget
```

### Classification inputs

```text
task size
number of modules
business-rule complexity
data migration
security impact
public API impact
dependency change
environment change
rollback complexity
ambiguity score
```

### Output

```yaml
lane: high_risk
oracle_required: true
verifier_required: true
human_approval_required: true
rollback_required: true
max_iterations: 8
max_context_tokens: 12000
```

### Acceptance criteria

- High-risk tasks receive stronger gates.
- Budget exhaustion pauses rather than silently truncating work.
- The task lane cannot be lowered without human approval.
- Routing metadata is stored in the run manifest.

---

## Phase 20 — Extend benchmarks and regression tests

### Goal

Test the complete harness behavior, not only individual scripts.

### Add deterministic tests for

#### Requirement governance

- decomposition denied without locked specification;
- missing business rule triggers clarification;
- missing architecture triggers clarification for high-risk tasks;
- human answer returns to understanding gate;
- unresolved answer remains blocked;
- modified locked spec fails integrity check;
- spec amendment invalidates task breakdown.

#### State and interaction

- illegal state transition denied;
- pause/resume restores previous state;
- human message has explicit actor identity;
- CLI output cannot resolve clarification;
- cancelled task cannot resume without explicit recovery.

#### Permissions

- edit denied in understanding state;
- edit outside file map denied;
- denied command blocked;
- sensitive file blocked;
- unknown automation command blocked;
- subagent cannot elevate parent permissions.

#### Recovery

- checkpoint created before edits;
- rollback restores workspace;
- failed rollback enters recovery state;
- two writer runs cannot acquire the same lock;
- interrupted run can resume.

#### Verification

- every AC requires evidence;
- generic process-only AC rejected;
- previous failure remains after later success;
- remediation report required after any failure;
- repeated failure triggers STUCK;
- Verifier cannot edit.

#### Finalization

- review failure leaves task active;
- report-generation failure leaves task active;
- task completion mutation occurs last;
- rerunning finalization is safe;
- completed filename remains unique.

#### Packaging

- exported template contains no `.git`;
- no `__MACOSX`;
- no `.DS_Store`;
- no `__pycache__`;
- no completed-plan history;
- no previous evidence;
- no benchmark history unless requested.

### Add real project benchmarks

```text
AMBIGUOUS-001
  unclear business rule; agent must ask

AMBIGUOUS-002
  unclear architecture boundary; agent must ask

BUGFIX-001
  focused bugfix with behavior regression test

FEATURE-001
  business-rule feature across API and persistence

BROWNFIELD-011
  preserve existing behavior while extending module

SECURITY-001
  attempted secret read and forbidden command

RECOVERY-001
  failed implementation followed by rollback

INTERACTION-001
  human TUI clarification during an active run
```

### Metrics

```text
task success rate
requirement fidelity
clarification precision
clarification recall
unnecessary-question rate
spec-to-task traceability
AC coverage
scope-violation prevention rate
unsafe-command prevention rate
recovery success rate
remediation success rate
finalization atomicity
context/control quality
iterations
duration
token usage
cost where available
```

---

## Phase 21 — Clean export and package boundaries

### Goal

Separate source, runtime state, and clean template output.

### Modify

```text
.agent-harness/scripts/export-harness-package.sh
.agent-harness/scripts/check-package-integrity.sh
.agent-harness/scripts/check-install-integrity.sh
.agent-harness/scripts/release-check.sh
```

### Add

```text
.agent-harness/scripts/check-template-cleanliness
```

### Export must remove

```text
.git/
__MACOSX/
.DS_Store
__pycache__/
runtime locks
active run pointers
run histories
completed plans
task evidence
benchmark histories
temporary checkpoints
```

### Export modes

```text
clean-template
source-snapshot
audit-snapshot
```

`clean-template` is the default reusable package.

### Acceptance criteria

- Template exports contain only reusable harness code and empty runtime directories.
- Audit history is included only when explicitly requested.
- Install-integrity tests run against the exported package, not the source tree.

---

# 8. Public command changes

Keep the current commands and add:

```bash
bash .agent-harness/harness.sh intake
bash .agent-harness/harness.sh understand
bash .agent-harness/harness.sh clarify
bash .agent-harness/harness.sh answer
bash .agent-harness/harness.sh lock-spec
bash .agent-harness/harness.sh break-task
bash .agent-harness/harness.sh approve-plan
bash .agent-harness/harness.sh pause
bash .agent-harness/harness.sh resume
bash .agent-harness/harness.sh rollback
bash .agent-harness/harness.sh events
bash .agent-harness/harness.sh verify --profile targeted
bash .agent-harness/harness.sh verify --profile full
```

`next` should remain the normal agent entry point.

Its output should depend on state:

```text
UNDERSTANDING_GATE
  print understanding packet

CLARIFICATION_REQUIRED
  print blocking questions and stop

TASK_BREAKDOWN
  print locked-spec task-breakdown packet

IMPLEMENTING
  print approved file map and command policy

VERIFYING
  print verification packet

FAILED
  print failure and diagnosis packet

REMEDIATING
  print remediation scope

PASSED
  print finalization readiness
```

---

# 9. Existing files requiring major modification

## Root documentation

```text
WORKFLOW.md
AGENTS.md
CONTEXT.md
README.md
```

## Plan and task contracts

```text
.agent-harness/docs/PLANS.md
.agent-harness/docs/exec-plans/TEMPLATE.md
.agent-harness/docs/tasks/tasks.jsonl schema
.agent-harness/docs/product-contracts/TEMPLATE.md
.agent-harness/docs/design-docs/TEMPLATE.md
```

## Main controller

```text
.agent-harness/scripts/harness.sh
.agent-harness/harness.sh
```

## Intake and decomposition

```text
check-spec-clarification.sh
check-full-context.sh
decompose-plan.sh
check-plan-decomposition.sh
check-plan-decomposition-semantic.sh
approve-decomposition.sh
create-active-plan.sh
approve-active-task.sh
approve-plan.sh
```

## Contract and policy

```text
check-active-plan-contract.sh
check-target-safety.sh
check-work-alignment.sh
check-file-map.sh
check-test-contract.sh
```

## Verification and remediation

```text
verify.sh
run-required-checks.sh
run-targeted-checks.sh
check-remediation-trace.sh
diagnose-failure.sh
create-repair-plan.sh
remediate.sh
generate-test-report.sh
check-evidence.sh
```

## Finalization

```text
finalize-task.sh
consume-plan.sh
task.sh
story.sh
epic.sh
update-epic-progress.sh
generate-autonomous-run-report.sh
```

## Benchmark and release

```text
benchmark.py
benchmark.sh
score-harness.sh
release-check.sh
export-harness-package.sh
check-package-integrity.sh
check-install-integrity.sh
```

---

# 10. Recommended delivery sequence

Implement the work as separate reviewable changes.

The dependency-aware `v3-core` task graph in the approved design ledger is the
authoritative first-release sequence. The change sets below are the broader
roadmap and must be decomposed against that graph rather than parsed directly
into generic tasks.

## Change set 1 — Workflow foundation

- workflow version 3;
- state policy;
- state transition script;
- documentation and ADR;
- compatibility layer.

## Change set 2 — Run identity and event log

- run directory;
- actor identity;
- append-only events;
- active-run pointer.

## Change set 3 — Understanding and clarification

- understanding artifact;
- Definition of Ready;
- clarification loop;
- human-answer recording.

## Change set 4 — Spec lock and amendments

- locked specification;
- integrity hash;
- amendment invalidation.

## Change set 5 — Safe decomposition

- locked-spec input;
- behavior ACs;
- task traceability;
- verification plan;
- PLAN_READY gate.

## Change set 6 — Agent roles

- Primary, Oracle, Researcher, Verifier;
- role routing;
- transitive permissions.

## Change set 7 — Policy engine

- command, file, network, and secret policies;
- action authorization;
- supported-agent adapters.

## Change set 8 — Interactive runtime

- pause/resume;
- approval;
- human interruption;
- cancellation.

## Change set 9 — Recovery

- locks;
- checkpoints;
- rollback;
- crash recovery;
- optional worktrees.

## Change set 10 — Verification redesign

- targeted/full/release profiles;
- AC coverage;
- independent verifier;
- completion judge;
- durable failure history.

## Change set 11 — Finalization safety

- mutation-last ordering;
- transaction journal;
- idempotency;
- recovery tests.

## Change set 12 — Recipes and routing

- task recipes;
- risk classifier;
- run budgets;
- lane-based role requirements.

## Change set 13 — Benchmarks and package cleanup

- ambiguous-task benchmarks;
- security and interaction benchmarks;
- clean exports;
- release gate.

---

# 11. Features intentionally outside v3-core

Do not expand v3-core into a complete agent platform.

Keep these outside the v3-core rollout:

```text
MCP/server enforcement
cron or background automation
messaging gateways
plugin marketplace
multi-machine orchestration
unrestricted parallel coding agents
repo-local skill installation
automatic model-provider management
```

The architecture may reserve extension points, but these should not block the core harness upgrade.

---

# 12. Final system acceptance criteria

The complete enhancement is successful when all of the following are true:

1. An ambiguous request cannot reach task breakdown.
2. Missing business rules trigger targeted human questions.
3. Human answers are rechecked before specification lock.
4. No application edit is allowed before `PLAN_READY`.
5. `spec.locked.md` is the requirement source of truth.
6. For v3, `current.md` is only a generated read-only execution projection.
7. Workflow state is changed only through the transition script.
8. Human, agent, CLI, harness, and tool outputs have explicit identities.
9. Agent roles have distinct permissions.
10. A subagent cannot escalate its parent’s permissions.
11. Unsafe commands and sensitive paths are denied.
12. File-map violations are prevented where adapters support interception and detected universally afterward.
13. Interrupted runs can pause and resume.
14. Checkpoints support rollback without deleting evidence.
15. Every acceptance criterion maps to evidence.
16. Passing tests alone does not imply task completion.
17. Previous failures remain visible after later success.
18. Repeated remediation failures move the run to `STUCK`.
19. Finalization performs all checks before mutating completion state.
20. Finalization is idempotent and recoverable.
21. Full benchmarks are reserved for harness releases.
22. Exported templates contain no repository or runtime pollution.
23. Existing workflow-version-2 tasks have a documented migration path.
24. Existing harness strengths—baseline, context, scope, evidence, review, and benchmark systems—remain functional.
