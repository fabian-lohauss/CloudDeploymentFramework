# GitHub Copilot Instructions

## Repository overview

This repository contains the **CloudDeploymentFramework** — a PowerShell module for deploying Azure
resources using a structured project/stamp/service/component model.

Key paths:

| Path | Purpose |
|---|---|
| `src/cmdlets/CloudDeploymentFramework/` | PowerShell module source (`Public/` contains cmdlets) |
| `src/cmdlets/UnitTests/` | Pester unit tests (one folder per cmdlet area) |
| `src/cmdlets/nuget/` | Module publishing scripts |
| `docs/backlog/` | Structured backlog of known issues and improvements |
| `.devcontainer/custom/` | Environment setup scripts (also used by CI) |

## Language and tooling

- All source code is **PowerShell**.
- Tests are written with **Pester** (`Invoke-Pester`).
- Linting is done with **PSScriptAnalyzer** (see `.github/workflows/build.yml`).
- The module manifest is `src/cmdlets/CloudDeploymentFramework/CloudDeploymentFramework.psd1`.

## Coding conventions

- Use approved PowerShell verbs and `Cdf` noun prefix (e.g. `Get-CdfComponent`).
- Prefer `function` (lower-case) keyword for consistency with the majority of existing cmdlets.
- Every public cmdlet should have `[CmdletBinding()]` and `param()` blocks.
- Do not hardcode tenant IDs, subscription IDs, credentials, or Azure locations — read them from
  project configuration (e.g. `Get-CdfProject`) or accept them as mandatory parameters.
- Follow the existing file/folder structure: one cmdlet per `.ps1` file, placed in the matching
  subfolder under `Public/`.

## Running tests locally

```pwsh
# Install prerequisites (Pester, Az modules)
.devcontainer/custom/Install-PowerShellPrerequisites.ps1

# Run all unit tests
Invoke-Pester ./src/cmdlets/UnitTests
```

## Backlog workflow

The backlog lives in `docs/backlog/`.

- **`docs/backlog/README.md`** — master list of all open items, grouped by severity.
- Individual items are in files named `BACKLOG-NNN-<short-description>.md`.

### Before starting work

1. Read `docs/backlog/README.md` to understand open items.
2. Review the relevant individual backlog file(s) for acceptance criteria.

### After completing work

When a backlog item is fully resolved:

1. Update the individual backlog file: add a `## Resolution` section describing what was changed
   and tick all acceptance-criteria checkboxes.
2. Remove the item's row from the corresponding section table in `docs/backlog/README.md`.
3. If the fix is partial, add a note in the individual file describing what remains.

When new issues are discovered during work, create a new backlog file following the existing naming
convention (`BACKLOG-NNN-<short-description>.md`) and add a row to `docs/backlog/README.md`.
