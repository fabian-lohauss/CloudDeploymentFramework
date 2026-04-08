# BACKLOG-007 · `Deploy-CdfService.ps1` has hardcoded Azure location

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-007 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Service/Deploy-CdfService.ps1` |

## Description

The Azure deployment location is hardcoded as `"westeurope"` inside `Deploy-CdfService.ps1`. This makes the cmdlet unusable for deployments to any other Azure region and contradicts the framework's intent of supporting configurable environments.

## Acceptance Criteria

- [ ] Remove the hardcoded `-Location "westeurope"` value.
- [ ] Read the location from project or environment configuration (e.g., from the environment object returned by `Get-CdfProject` / `Add-CdfEnvironment`).
- [ ] Add an optional `Location` parameter as a fallback override.
- [ ] Update relevant unit tests to cover the location wiring.
