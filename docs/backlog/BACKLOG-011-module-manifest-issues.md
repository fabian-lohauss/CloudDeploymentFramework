# BACKLOG-011 · Module manifest (`CloudDeploymentFramework.psd1`) issues

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-011 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality |
| **File**     | `src/cmdlets/CloudDeploymentFramework/CloudDeploymentFramework.psd1` |

## Description

The module manifest has several issues that affect performance, discoverability, and correctness:

1. **`FunctionsToExport = '*'`** – wildcard export is not best practice; it forces PowerShell to load all script files to enumerate functions rather than using the manifest cache.
2. **`CmdletsToExport` lists PowerShell functions** – `CmdletsToExport` is intended for binary (C#) compiled cmdlets. PowerShell script-based functions belong in `FunctionsToExport`.
3. **Missing exports** – `Write-CdfLog`, `Test-CdfDeploymentPipeline`, and `Get-CdfPublicIp` are not listed in any export field.
4. **Typo in `Description`** – `"resouces"` should be `"resources"`.

## Acceptance Criteria

- [ ] Replace `FunctionsToExport = '*'` with an explicit list of all public functions.
- [ ] Move the entries currently in `CmdletsToExport` to `FunctionsToExport`; set `CmdletsToExport = @()`.
- [ ] Add `Write-CdfLog`, `Test-CdfDeploymentPipeline`, and `Get-CdfPublicIp` to `FunctionsToExport`.
- [ ] Fix the `"resouces"` typo in `Description`.
- [ ] Verify the module loads cleanly and all public functions are accessible after the change.
