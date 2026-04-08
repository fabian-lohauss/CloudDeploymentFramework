# BACKLOG-002 · `Connect-CdfRdp.ps1` redefines `Write-CdfLog` locally

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-002 |
| **Priority** | 🔴 Critical |
| **Category** | Security / Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Rdp/Connect-CdfRdp.ps1` |

## Description

An inner `Write-CdfLog` function defined on lines 8–14 of `Connect-CdfRdp.ps1` shadows the module-level cmdlet of the same name. The local version silently drops the ADO pipeline `##[group]` log-grouping format, causing inconsistent logging behaviour and making it harder to audit pipeline output.

## Acceptance Criteria

- [ ] Remove the inner `Write-CdfLog` definition from `Connect-CdfRdp.ps1`.
- [ ] Confirm the module-level `Write-CdfLog` cmdlet is used throughout the function.
- [ ] Verify that ADO pipeline log grouping markers are correctly emitted when the script runs in a pipeline context.
