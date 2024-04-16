# automatic login in case of an expired token

```shell
AADSTS50173: The provided grant has expired due to it being revoked, a fresh auth token is needed. The user might have changed or reset their password. The grant was issued on '2024-02-20T08:38:17.6250114Z' and the TokensValidFrom date (before which tokens are not valid) for this user is '2024-04-16T08:25:51.0000000Z'. Trace ID: a96434be-1833-4c6c-a8e0-5e543ad9d200 Correlation ID: e30dc732-4a5a-4cc4-894b-9145d5bc0950 Timestamp: 2024-04-16 09:18:32Z
Interactive authentication is needed. Please run:
az login --scope https://management.core.windows.net//.default
```
