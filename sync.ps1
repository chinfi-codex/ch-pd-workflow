param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-CodexSkillsRoot {
  if ($env:CODEX_HOME) {
    return Join-Path $env:CODEX_HOME "skills"
  }

  if (-not $HOME) {
    throw "Cannot resolve HOME. Set CODEX_HOME or HOME and try again."
  }

  return Join-Path $HOME ".codex\skills"
}

$repoRoot = $PSScriptRoot
$sourceDir = Join-Path $repoRoot "skills\product-workflow"
$buildScript = Join-Path $sourceDir "scripts\build-all.ps1"

if (-not (Test-Path $sourceDir)) {
  throw "Cannot find skills\product-workflow in this repository."
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw "Node.js is required to regenerate SKILL.md. Install Node.js and try again."
}

if (-not (Test-Path $buildScript)) {
  throw "Cannot find build script: $buildScript"
}

& powershell.exe -ExecutionPolicy Bypass -File $buildScript

$skillsRoot = Get-CodexSkillsRoot
$targetDir = Join-Path $skillsRoot "product-workflow"
New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null

if (Test-Path $targetDir) {
  if (-not $Force) {
    Remove-Item -LiteralPath $targetDir -Recurse -Force
  } else {
    Remove-Item -LiteralPath $targetDir -Recurse -Force
  }
}

Copy-Item -LiteralPath $sourceDir -Destination $targetDir -Recurse -Force

Write-Host ""
Write-Host "Rebuilt and synced product-workflow to:"
Write-Host $targetDir
