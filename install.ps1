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

function Get-LocalSourceDir {
  if ($PSScriptRoot) {
    $candidate = Join-Path $PSScriptRoot "skills\product-workflow"
    if (Test-Path $candidate) {
      return $candidate
    }
  }

  return $null
}

function Get-RemoteSourceDir {
  $repoArchiveUrl = "https://github.com/chinfi-codex/ch-pd-workflow/archive/refs/heads/main.zip"
  $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ch-pd-workflow-" + [guid]::NewGuid().ToString("N"))
  $zipPath = Join-Path $tempRoot "repo.zip"
  $extractDir = Join-Path $tempRoot "repo"

  New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
  Invoke-WebRequest -Uri $repoArchiveUrl -OutFile $zipPath
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

  $sourceDir = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1 | ForEach-Object {
    Join-Path $_.FullName "skills\product-workflow"
  }

  if (-not $sourceDir -or -not (Test-Path $sourceDir)) {
    throw "Downloaded repository archive, but could not find skills\product-workflow."
  }

  return @{
    SourceDir = $sourceDir
    TempRoot = $tempRoot
  }
}

$cleanupDir = $null
$localSource = Get-LocalSourceDir

if ($localSource) {
  $sourceDir = $localSource
} else {
  $download = Get-RemoteSourceDir
  $sourceDir = $download.SourceDir
  $cleanupDir = $download.TempRoot
}

$skillsRoot = Get-CodexSkillsRoot
$targetDir = Join-Path $skillsRoot "product-workflow"

New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null

if (Test-Path $targetDir) {
  if (-not $Force) {
    Write-Host "Target already exists: $targetDir"
    Write-Host "Re-run with -Force to overwrite the installed version."
    exit 1
  }

  Remove-Item -LiteralPath $targetDir -Recurse -Force
}

Copy-Item -LiteralPath $sourceDir -Destination $targetDir -Recurse -Force

Write-Host ""
Write-Host "Installed product-workflow to:"
Write-Host $targetDir
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Open Codex and use /ceo, /feature-br, /prd, or /pd-review."
Write-Host "2. If you later modify template files in this repo, run .\sync.ps1 from the repo root."

if ($cleanupDir -and (Test-Path $cleanupDir)) {
  Remove-Item -LiteralPath $cleanupDir -Recurse -Force
}
