# Generated API Clients

This folder is generated from `api/openapi.yaml`.

Use:

```powershell
.\scripts\generate_clients.ps1
```

Outputs:

- `api/generated/mobile/connect_api_client`: Dart `dart-dio` client package for Flutter.
- `api/generated/admin/schema.d.ts`: TypeScript OpenAPI schema types for the Next.js admin.

Do not edit generated files manually. Change `api/openapi.yaml`, then regenerate.
