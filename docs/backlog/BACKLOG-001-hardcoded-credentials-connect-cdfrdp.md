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

- [x] Remove all hardcoded credential/identity values from `Connect-CdfRdp.ps1`.
- [x] Read `TenantId`, `SubscriptionId`, and `AccountId` from project configuration (e.g., `Get-CdfProject`) or accept them as mandatory parameters.
- [x] Add a unit test (or update the existing stub) that verifies no literal GUIDs/e-mails appear in the script.

## Resolution

Replaced the three hardcoded literals (`TenantId`, `SubscriptionId`, `AccountId`) with mandatory
`[string]` parameters on `Connect-CdfRdp`. Callers are now responsible for supplying these values
(e.g. by reading them from `Get-CdfProject` output or from a secrets store).

A new unit test `src/cmdlets/UnitTests/Rdp/Connect-CdfRdp.Tests.ps1` asserts that the source file
contains no GUID patterns or e-mail addresses.
