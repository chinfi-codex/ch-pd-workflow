param(
  [ValidateSet("codex", "opencode", "both")]
  [string]$Target = "codex",
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

function Get-OpenCodeSkillsRoot($repoRoot) {
  return Join-Path $repoRoot ".opencode\skills"
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

function Get-SkillDirs($rootDir) {
  return Get-ChildItem -LiteralPath $rootDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
  }
}

$cleanupDir = $null
$localSource = Get-LocalSourceDir
$repoRoot = $null

if ($localSource) {
  $sourceDir = $localSource
  $repoRoot = $PSScriptRoot
} else {
  $download = Get-RemoteSourceDir
  $sourceDir = $download.SourceDir
  $cleanupDir = $download.TempRoot
}

$skillDirs = @(Get-SkillDirs $sourceDir)

if ($skillDirs.Count -eq 0) {
  throw "No installable skills found in $sourceDir."
}

if (($Target -eq "opencode" -or $Target -eq "both") -and -not $repoRoot) {
  throw "OpenCode target requires running install.ps1 from a local repository checkout."
}

$installRoots = @()
if ($Target -eq "codex" -or $Target -eq "both") {
  $installRoots += @{
    Name = "Codex"
    Root = Get-CodexSkillsRoot
    LegacyTarget = Join-Path (Get-CodexSkillsRoot) "product-workflow"
  }
}

if ($Target -eq "opencode" -or $Target -eq "both") {
  $openCodeRoot = Get-OpenCodeSkillsRoot $repoRoot
  $installRoots += @{
    Name = "OpenCode"
    Root = $openCodeRoot
    LegacyTarget = $null
  }
}

$existingTargets = @()
foreach ($installRoot in $installRoots) {
  New-Item -ItemType Directory -Force -Path $installRoot.Root | Out-Null

  if ($installRoot.LegacyTarget -and (Test-Path -LiteralPath $installRoot.LegacyTarget)) {
    $existingTargets += $installRoot.LegacyTarget
  }

  foreach ($skillDir in $skillDirs) {
    $targetDir = Join-Path $installRoot.Root $skillDir.Name
    if (Test-Path -LiteralPath $targetDir) {
      $existingTargets += $targetDir
    }
  }
}

if ($existingTargets.Count -gt 0) {
  if (-not $Force) {
    Write-Host "Install target already exists:"
    $existingTargets | Select-Object -Unique | ForEach-Object { Write-Host " - $_" }
    Write-Host "Re-run with -Force to overwrite the installed version."
    exit 1
  }
}

foreach ($installRoot in $installRoots) {
  if ($installRoot.LegacyTarget -and (Test-Path -LiteralPath $installRoot.LegacyTarget)) {
    Remove-Item -LiteralPath $installRoot.LegacyTarget -Recurse -Force
  }

  foreach ($skillDir in $skillDirs) {
    $targetDir = Join-Path $installRoot.Root $skillDir.Name
    if (Test-Path -LiteralPath $targetDir) {
      Remove-Item -LiteralPath $targetDir -Recurse -Force
    }
    Copy-Item -LiteralPath $skillDir.FullName -Destination $targetDir -Recurse -Force
  }
}

Write-Host ""
Write-Host "Installed product-workflow skills to:"
foreach ($installRoot in $installRoots) {
  foreach ($skillDir in $skillDirs) {
    Write-Host (Join-Path $installRoot.Root $skillDir.Name)
  }
}
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Open Codex and use /ceo, /feature-br, /prd, or /pd-review."
Write-Host "2. If you later modify template files in this repo, run .\sync.ps1 from the repo root."

if ($cleanupDir -and (Test-Path $cleanupDir)) {
  Remove-Item -LiteralPath $cleanupDir -Recurse -Force
}
