# BACKLOG-013 · `Add-CdfComponent.ps1` — ambiguous component version selection

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-013 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality / Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Component/Add-CdfComponent.ps1` |

## Description

`Add-CdfComponent.ps1` calls `Get-CdfComponent $Name` using the `"ByName"` parameter set, which may return multiple version objects if more than one version of the component exists. The function does not handle this case and will pass an array to the downstream step that expects a single component, leading to unpredictable behaviour.

## Acceptance Criteria

- [ ] Add a mandatory (or optional with a sensible default) `Version` parameter to `Add-CdfComponent`.
- [ ] Switch the internal `Get-CdfComponent` call to the `"ByNameAndVersion"` parameter set so exactly one component is retrieved.
- [ ] Add or update unit tests to cover the case where multiple versions exist and assert the correct version is selected.
