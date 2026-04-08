# BACKLOG-005 · `New-CdfComponent.ps1` never creates the component file

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-005 |
| **Priority** | 🟠 High |
| **Category** | Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Component/New-CdfComponent.ps1` |

## Description

`New-CdfComponent.ps1` builds the path for the new component file and stores it in `$Properties.Path`, but **never calls `New-Item`** to actually create the file on disk. As a result, the output object advertises a path that does not exist, and any downstream cmdlet (e.g., `Deploy-CdfComponent`) that tries to access the file will fail.

## Acceptance Criteria

- [ ] After building `$Properties.Path`, call `New-Item` (or equivalent) to create the `.bicep` / `.json` stub file at that path.
- [ ] Ensure the parent directory is created first if it does not already exist.
- [ ] Add or update a unit test that verifies the file is present on the filesystem after `New-CdfComponent` returns.
