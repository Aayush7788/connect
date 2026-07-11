# API Contract

`openapi.yaml` is the external API contract for the mobile app and admin dashboard.

Generate clients from the repository root:

```powershell
.\scripts\generate_clients.ps1
```

Tooling is pinned in:

- `api/package.json`
- `api/package-lock.json`
- `api/openapitools.json`

Generated outputs:

- `api/generated/mobile/connect_api_client`
- `api/generated/admin/schema.d.ts`

The generation script post-processes the generated Dart package SDK constraint to `>=3.8.0 <4.0.0` because the current `dart-dio` + `json_serializable` output uses null-aware collection elements. It also suppresses generated unused-import warnings inside the generated package analysis options.

Do not hand-edit generated files.
