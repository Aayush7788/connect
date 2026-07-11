$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$python = Join-Path $repoRoot ".venv\Scripts\python.exe"
$apiDir = Join-Path $repoRoot "api"
$mobileClientDir = Join-Path $apiDir "generated\mobile\connect_api_client"
$preferredJavaBin = "C:\Java\bin"

function Invoke-CheckedCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string] $FilePath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $ArgumentList
  )

  & $FilePath @ArgumentList

  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath $($ArgumentList -join ' ') exited with code $LASTEXITCODE."
  }
}

if (-not (Test-Path $python)) {
  $python = "python"
}

if (Test-Path (Join-Path $preferredJavaBin "java.exe")) {
  $env:PATH = "$preferredJavaBin;$env:PATH"
}

Invoke-CheckedCommand $python (Join-Path $PSScriptRoot "validate_openapi.py")

if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
  throw "npm.cmd is required for OpenAPI client generation."
}

Push-Location $apiDir
try {
  if (Test-Path "package-lock.json") {
    Invoke-CheckedCommand "npm.cmd" "ci" "--ignore-scripts"
  } else {
    Invoke-CheckedCommand "npm.cmd" "install" "--ignore-scripts"
  }

  Invoke-CheckedCommand "npm.cmd" "run" "generate"
}
finally {
  Pop-Location
}

if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
  throw "dart is required to prepare the generated Dart API client."
}

$generatedPubspec = Join-Path $mobileClientDir "pubspec.yaml"
$pubspecText = Get-Content -LiteralPath $generatedPubspec -Raw
$pubspecText = $pubspecText.Replace("sdk: '>=3.5.0 <4.0.0'", "sdk: '>=3.8.0 <4.0.0'")
Set-Content -LiteralPath $generatedPubspec -Value $pubspecText -Encoding utf8

$generatedAnalysisOptions = Join-Path $mobileClientDir "analysis_options.yaml"
$analysisOptionsText = Get-Content -LiteralPath $generatedAnalysisOptions -Raw
if (-not $analysisOptionsText.Contains("unused_import: ignore")) {
  $analysisOptionsText = $analysisOptionsText.Replace(
    "deprecated_member_use_from_same_package: ignore",
    "deprecated_member_use_from_same_package: ignore`n    unused_import: ignore"
  )
  Set-Content -LiteralPath $generatedAnalysisOptions -Value $analysisOptionsText -Encoding utf8
}

Push-Location $mobileClientDir
try {
  Invoke-CheckedCommand "dart" "pub" "get"
  Invoke-CheckedCommand "dart" "run" "build_runner" "build" "--delete-conflicting-outputs"
}
finally {
  Pop-Location
}

Write-Host "OpenAPI client generation complete."
Write-Host "Generated outputs:"
Write-Host "  api/generated/mobile/connect_api_client"
Write-Host "  api/generated/admin/schema.d.ts"
