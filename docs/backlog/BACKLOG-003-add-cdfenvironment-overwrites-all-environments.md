# BACKLOG-003 · `Add-CdfEnvironment.ps1` overwrites all environments

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-003 |
| **Priority** | 🟠 High |
| **Category** | Correctness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Environment/Add-CdfEnvironment.ps1` |

## Description

The current implementation assigns a brand-new hashtable to `$Config.Environment` on every call:

```powershell
$Config.Environment = @{ $Name = @{ Subscription = $Subscription } }
```

This replaces the entire `Environment` object, destroying all previously registered environments. Every subsequent call to `Add-CdfEnvironment` therefore leaves only the last-added environment in the configuration.

## Acceptance Criteria

- [ ] Merge the new entry into the existing `Environment` hashtable instead of replacing it:
  ```powershell
  if (-not $Config.Environment) { $Config.Environment = @{} }
  $Config.Environment[$Name] = @{ Subscription = $Subscription }
  ```
- [ ] Add or update a unit test that calls `Add-CdfEnvironment` twice and asserts both environments are present in the saved configuration.
