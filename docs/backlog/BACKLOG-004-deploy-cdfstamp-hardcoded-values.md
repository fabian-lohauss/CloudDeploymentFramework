# BACKLOG-004 · `Deploy-CdfStamp.ps1` is barely functional

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-004 |
| **Priority** | 🟠 High |
| **Category** | Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Stamp/Deploy-CdfStamp.ps1` |

## Description

Multiple values in `Deploy-CdfStamp.ps1` are hardcoded or unused, rendering the cmdlet non-functional in real deployments:

1. **Invalid Azure location** – location is hardcoded as `"weu"`, which is not a valid Azure region identifier. The correct value would be `"westeurope"` or, preferably, read from project/environment configuration.
2. **Hardcoded template filename** – the Bicep template is hardcoded as `"ResourceGroup.bicep"` with no path resolution, so the file will never be found unless the working directory happens to be the templates folder.
3. **`$Name` parameter is accepted but never used** – the stamp name is accepted as a mandatory parameter but not referenced anywhere in the function body.

## Acceptance Criteria

- [ ] Read the Azure location from project or environment configuration rather than hardcoding it.
- [ ] Resolve the Bicep template path relative to the stamp template folder (use `Get-CdfStampTemplate` or equivalent).
- [ ] Use the `$Name` parameter to identify the correct stamp template.
- [ ] Add or update unit tests to cover the corrected parameter wiring.
