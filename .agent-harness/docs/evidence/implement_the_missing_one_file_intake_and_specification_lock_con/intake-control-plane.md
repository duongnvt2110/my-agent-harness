# One-File Intake Control Plane

## Implemented

Added `scripts/intake-control.sh` and routed the public v3 commands through
the harness:

- `intake create` creates one canonical `CHANGE_PACKAGE`.
- `understand` validates required business, architecture, scope, source, and
  verification sections and reports readiness.
- `clarify` records blocking questions in a new immutable package.
- `answer` records human answers and reopens readiness evaluation.
- `intake approve` requires explicit human approval and creates an immutable
  `SPEC_LOCKED` package.
- `intake verify` validates package integrity and approval binding.

## Boundaries

- Human approval occurs only at specification lock.
- The package supports sources such as text, files, images, diagrams, MCP
  results, and external references through typed source records.
- Package hashes make every package version tamper-evident.
- Existing v3 execution, remediation, recovery, verification, and finalization
  paths remain unchanged.
- Pause, resume, and rollback remain outside this autonomous v3 control plane.

## Test result

`test_intake_control_plane.sh` passes the create, understand, clarify, answer,
approve, verify, and immutable-output workflow.
