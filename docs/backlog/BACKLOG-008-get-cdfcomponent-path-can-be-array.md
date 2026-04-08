# BACKLOG-008 · `Get-CdfComponent.ps1` — `Path` property can be an array

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-008 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality / Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Component/Get-CdfComponent.ps1` |

## Description

In the `"ByName"` and `"All"` parameter-set branches, the component path is assigned as:

```powershell
Path = ($VersionFolder | Get-ChildItem).FullName
```

If a version folder contains more than one file, `Path` becomes a `string[]` array rather than a single `string`. Any downstream consumer (e.g., `Deploy-CdfComponent`) that treats `Path` as a scalar string will fail or behave unpredictably.

## Acceptance Criteria

- [ ] Filter the `Get-ChildItem` result to a single `.bicep` (or primary template) file explicitly, e.g.:
  ```powershell
  Path = ($VersionFolder | Get-ChildItem -Filter '*.bicep' | Select-Object -First 1).FullName
  ```
- [ ] Decide on and document the expected file convention for a component version folder.
- [ ] Add or update unit tests with a version folder that contains multiple files to verify only the correct path is returned.
