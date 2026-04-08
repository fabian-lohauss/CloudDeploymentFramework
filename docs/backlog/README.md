# Backlog

Findings identified by automated code-review on **2026-04-08** (branch `copilot/recommend-improvements`).

Items are grouped by severity and link to individual backlog files.

---

## 🔴 Critical — Security

No open items.

---

## 🟠 High — Correctness Bugs

| ID | Title | File |
|---|---|---|
| [BACKLOG-003](BACKLOG-003-add-cdfenvironment-overwrites-all-environments.md) | `Add-CdfEnvironment.ps1` overwrites all environments | `Environment/Add-CdfEnvironment.ps1` |
| [BACKLOG-004](BACKLOG-004-deploy-cdfstamp-hardcoded-values.md) | `Deploy-CdfStamp.ps1` is barely functional | `Stamp/Deploy-CdfStamp.ps1` |
| [BACKLOG-005](BACKLOG-005-new-cdfcomponent-never-creates-file.md) | `New-CdfComponent.ps1` never creates the component file | `Component/New-CdfComponent.ps1` |
| [BACKLOG-006](BACKLOG-006-initialize-cdfproject-missing-paths.md) | `Initialize-CdfProject.ps1` does not write `ComponentsPath`/`ServicesPath` | `Project/Initialize-CdfProject.ps1` |

---

## 🟡 Medium — Code Quality

| ID | Title | File |
|---|---|---|
| [BACKLOG-007](BACKLOG-007-deploy-cdfservice-hardcoded-location.md) | `Deploy-CdfService.ps1` has hardcoded Azure location | `Service/Deploy-CdfService.ps1` |
| [BACKLOG-008](BACKLOG-008-get-cdfcomponent-path-can-be-array.md) | `Get-CdfComponent.ps1` — `Path` property can be an array | `Component/Get-CdfComponent.ps1` |
| [BACKLOG-009](BACKLOG-009-get-cdfcomponent-dead-condition.md) | `Get-CdfComponent.ps1` — dead condition in `"ByName"` branch | `Component/Get-CdfComponent.ps1` |
| [BACKLOG-010](BACKLOG-010-test-cdfcontext-mixed-tool-usage.md) | `Test-CdfContext.ps1` — mixed Az PowerShell / Azure CLI usage | `Context/Test-CdfContext.ps1` |
| [BACKLOG-011](BACKLOG-011-module-manifest-issues.md) | Module manifest (`CloudDeploymentFramework.psd1`) issues | `CloudDeploymentFramework.psd1` |
| [BACKLOG-012](BACKLOG-012-get-cdfsecret-fragile-regex.md) | `Get-CdfSecret.ps1` — fragile regex for IP extraction | `Secret/Get-CdfSecret.ps1` |
| [BACKLOG-013](BACKLOG-013-add-cdfcomponent-ambiguous-version.md) | `Add-CdfComponent.ps1` — ambiguous component version selection | `Component/Add-CdfComponent.ps1` |

---

## 🔵 Low — Style / Consistency

| ID | Title | File |
|---|---|---|
| [BACKLOG-014](BACKLOG-014-inconsistent-function-keyword-casing.md) | Inconsistent `Function` vs `function` keyword casing | multiple |
| [BACKLOG-015](BACKLOG-015-deploy-cdfcomponent-missing-cmdletbinding.md) | `Deploy-CdfComponent.ps1` missing `[CmdletBinding()]` | `Component/Deploy-CdfComponent.ps1` |
| [BACKLOG-016](BACKLOG-016-psm1-uninitialized-accumulator.md) | `CloudDeploymentFramework.psm1` — uninitialized accumulator variable | `CloudDeploymentFramework.psm1` |
| [BACKLOG-017](BACKLOG-017-missing-required-modules-in-psd1.md) | No `RequiredModules` declared in `.psd1` | `CloudDeploymentFramework.psd1` |
