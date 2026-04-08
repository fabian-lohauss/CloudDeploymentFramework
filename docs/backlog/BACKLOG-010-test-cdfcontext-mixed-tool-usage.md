# BACKLOG-010 · `Test-CdfContext.ps1` — mixed Az PowerShell / Azure CLI tool usage

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-010 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality / Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Context/Test-CdfContext.ps1` |

## Description

`Test-CdfContext.ps1` calls both Az PowerShell cmdlets (`Get-AzContext`) and the Azure CLI (`az account list`). The CLI call returns an empty JSON array (not `$null`) when no account is logged in, so `$AzContextConnected` is always set to `$true` regardless of login state—making the check ineffective.

## Acceptance Criteria

- [ ] Decide on a single tool (Az PowerShell **or** Azure CLI) for context verification and use it consistently.
- [ ] If Azure CLI is retained, replace `az account list` with `az account show` and check the process exit code to determine login state.
- [ ] Add or update unit tests (using mocks) to cover the logged-in and logged-out scenarios correctly.
