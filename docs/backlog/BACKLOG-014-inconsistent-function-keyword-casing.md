# BACKLOG-014 · Inconsistent `Function` vs `function` keyword casing

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-014 |
| **Priority** | 🔵 Low |
| **Category** | Style / Consistency |
| **Files**    | `Add-CdfStorageAccountNetworkRule.ps1`, `Connect-CdfRdp.ps1`, `Write-CdfLog.ps1` (and others) |

## Description

Most source files use the lowercase `function` keyword, which is idiomatic PowerShell. A few files use the Pascal-cased `Function` keyword (e.g., `Add-CdfStorageAccountNetworkRule`, `Connect-CdfRdp`, `Write-CdfLog`). While PowerShell is case-insensitive, inconsistent casing reduces readability and makes diffs noisier.

## Acceptance Criteria

- [ ] Standardise on lowercase `function` throughout the codebase.
- [ ] Run PSScriptAnalyzer to confirm no new style warnings are introduced.
- [ ] Confirm all existing unit tests still pass after the rename.
