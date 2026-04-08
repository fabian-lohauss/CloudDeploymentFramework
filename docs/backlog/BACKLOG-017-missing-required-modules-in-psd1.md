# BACKLOG-017 · No `RequiredModules` declared in `.psd1`

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-017 |
| **Priority** | 🔵 Low |
| **Category** | Style / Consistency |
| **File**     | `src/cmdlets/CloudDeploymentFramework/CloudDeploymentFramework.psd1` |

## Description

The module depends on several Az PowerShell modules (`Az.Accounts`, `Az.KeyVault`, `Az.Resources`, `Az.Compute`, `Az.Network`, `Az.Storage`) but none of them are listed in the `RequiredModules` field of the manifest. As a result:

- The module imports without error even when the required Az modules are absent.
- Runtime failures occur later with confusing error messages instead of a clear "missing dependency" error at import time.
- Tools like `Find-Module` and `Install-Module` cannot automatically resolve the dependency graph.

## Acceptance Criteria

- [ ] Add all required Az module names (and minimum required versions) to the `RequiredModules` array in `CloudDeploymentFramework.psd1`.
- [ ] Verify the module still loads correctly in a clean environment where those modules are present.
- [ ] Document the minimum supported Az module versions in the project README.
