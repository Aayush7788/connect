$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$python = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $python)) {
  $python = "python"
}

& $python (Join-Path $PSScriptRoot "validate_openapi.py")

Write-Host "OpenAPI is valid."
Write-Host "Client generation tooling is selected in Phase 3."
Write-Host "Target folders:"
Write-Host "  api/generated/mobile"
Write-Host "  api/generated/admin"
