# BACKLOG-006 · `Initialize-CdfProject.ps1` does not write `ComponentsPath` / `ServicesPath`

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-006 |
| **Priority** | 🟠 High |
| **Category** | Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Project/Initialize-CdfProject.ps1` |

## Description

`Initialize-CdfProject.ps1` writes the configuration as `@{ Name = $Name }`, but `Get-CdfProject.ps1` reads `$Configuration.ComponentsPath` and `$Configuration.ServicesPath` from that same object. Because those keys are never set during initialisation, any subsequent call to `Get-CdfProject` (or any cmdlet that depends on it) will receive `$null` for these paths, causing silent or hard-to-diagnose failures.

## Acceptance Criteria

- [ ] Set default values for `ComponentsPath` and `ServicesPath` during project initialisation (e.g., relative paths such as `./components` and `./services`).
- [ ] Alternatively, add fallback logic in `Get-CdfProject` so it returns sensible defaults when the keys are absent.
- [ ] Add or update unit tests to verify that a freshly initialised project has valid, non-null component and service paths.
