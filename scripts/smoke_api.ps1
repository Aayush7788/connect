param(
  [string]$BaseUrl = "http://127.0.0.1:8000"
)

$ErrorActionPreference = "Stop"

$healthUrl = "$BaseUrl/health"

try {
  $response = Invoke-RestMethod -Method Get -Uri $healthUrl -TimeoutSec 10
  Write-Host "API smoke OK: $healthUrl"
  $response
} catch {
  Write-Error "API smoke failed for $healthUrl. Start the FastAPI server first after Phase 4 creates the health endpoint."
}
