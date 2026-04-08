# BACKLOG-012 · `Get-CdfSecret.ps1` — fragile regex for IP extraction

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-012 |
| **Priority** | 🟡 Medium |
| **Category** | Code Quality / Robustness |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Secret/Get-CdfSecret.ps1` |

## Description

`Get-CdfSecret.ps1` extracts the caller's public IP address by parsing the Azure error message string with a regular expression. This approach is brittle:

- The error message format can change between API/SDK versions.
- It is locale-dependent (localised error messages will not match the regex).
- It fails silently if the regex does not match, producing a `$null` IP.

The module already contains `Get-CdfPublicIp`, which is the correct mechanism for retrieving the current public IP.

## Acceptance Criteria

- [ ] Replace the regex-based IP extraction with a call to `Get-CdfPublicIp`.
- [ ] Use the returned IP to call `Add-AzKeyVaultNetworkRule` proactively (before the secret fetch fails) or on retry.
- [ ] Add or update unit tests to cover the network-rule-addition flow without requiring a live Azure connection (use mocks).
