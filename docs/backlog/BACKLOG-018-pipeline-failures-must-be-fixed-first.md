# BACKLOG-018 · Pipeline failures must always be checked and fixed first

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-018 |
| **Priority** | 🌐 Global |
| **Category** | Process |
| **File**     | N/A (repository-wide) |

## Description

The CI/CD pipeline (GitHub Actions) must be monitored continuously. Any build, lint, or test
failure in the pipeline must be investigated and resolved **before** other backlog items are
picked up. Leaving a broken pipeline unattended means all subsequent changes are validated
against an unreliable baseline, which can mask regressions or ship known-broken code.

This is a standing, global process requirement — it is never "done" but must be respected at
all times during development.

## Acceptance Criteria

- [ ] Before starting work on any backlog item, check the most recent pipeline run for failures.
- [ ] If the pipeline is failing, identify the root cause before taking on other work.
- [ ] All pipeline failures are fixed (or have a documented, accepted workaround) before new
      feature or fix work is merged.
- [ ] Pipeline status is re-checked after every merge to confirm it remains green.
