# BACKLOG-015 · `Deploy-CdfComponent.ps1` missing `[CmdletBinding()]`

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-015 |
| **Priority** | 🔵 Low |
| **Category** | Style / Consistency |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Component/Deploy-CdfComponent.ps1` |

## Description

Unlike all other public functions in the module, `Deploy-CdfComponent.ps1` does not declare `[CmdletBinding()]`. Without this attribute the function:

- Does not support the common `-Verbose`, `-Debug`, `-WhatIf`, or `-Confirm` parameters.
- Is not treated as an advanced function, losing features such as pipeline-by-property-name binding.

## Acceptance Criteria

- [ ] Add `[CmdletBinding()]` (and `[OutputType(...)]` if applicable) to `Deploy-CdfComponent`.
- [ ] Confirm PSScriptAnalyzer reports no new warnings.
- [ ] Confirm existing unit tests still pass.
