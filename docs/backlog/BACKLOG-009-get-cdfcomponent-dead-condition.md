# BACKLOG-009 · `Get-CdfComponent.ps1` — dead condition in `"ByName"` branch

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-009 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Component/Get-CdfComponent.ps1` |

## Description

Inside the `"ByName"` parameter-set branch, the filter condition reads:

```powershell
if (($ComponentFolder.BaseName -eq $Name) -or [string]::IsNullOrEmpty($Name))
```

Because `$Name` is a **Mandatory** parameter in the `"ByName"` set, it can never be null or empty when this branch is reached. The `IsNullOrEmpty` sub-expression is therefore unreachable dead code that adds confusion without providing any benefit.

## Acceptance Criteria

- [ ] Remove the `[string]::IsNullOrEmpty($Name)` clause from the condition.
- [ ] Verify the simplified condition still passes all existing unit tests.
