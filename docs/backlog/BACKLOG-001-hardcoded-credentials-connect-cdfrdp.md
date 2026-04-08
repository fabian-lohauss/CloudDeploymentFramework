# BACKLOG-001 · Hardcoded credentials in `Connect-CdfRdp.ps1`

| Field        | Value |
|---|---|
| **ID**       | BACKLOG-001 |
| **Priority** | 🔴 Critical |
| **Category** | Security |
| **File**     | `src/cmdlets/CloudDeploymentFramework/Public/Rdp/Connect-CdfRdp.ps1` |

## Description

Real `TenantId`, `SubscriptionId`, and `AccountId` values (GUIDs / e-mail addresses) are hardcoded directly in the script (lines 16–18). Committing credentials or tenant identifiers to source control is a security risk and violates the principle of least exposure.

## Acceptance Criteria

- [ ] Remove all hardcoded credential/identity values from `Connect-CdfRdp.ps1`.
- [ ] Read `TenantId`, `SubscriptionId`, and `AccountId` from project configuration (e.g., `Get-CdfProject`) or accept them as mandatory parameters.
- [ ] Add a unit test (or update the existing stub) that verifies no literal GUIDs/e-mails appear in the script.
