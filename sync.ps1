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

function Get-SkillDirs($rootDir) {
  return Get-ChildItem -LiteralPath $rootDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
  }
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
$skillDirs = @(Get-SkillDirs $sourceDir)

if ($skillDirs.Count -eq 0) {
  throw "No installable skills found in $sourceDir."
}

if (($Target -eq "opencode" -or $Target -eq "both") -and -not $repoRoot) {
  throw "OpenCode target requires running sync.ps1 from a local repository checkout."
}

if ($Target -eq "codex" -or $Target -eq "both") {
  $skillsRoots = @(
    @{
      Root = Get-CodexSkillsRoot
      LegacyTarget = Join-Path (Get-CodexSkillsRoot) "product-workflow"
    }
  )
} else {
  $skillsRoots = @()
}

if ($Target -eq "opencode" -or $Target -eq "both") {
  $skillsRoots += @{
    Root = Get-OpenCodeSkillsRoot $repoRoot
    LegacyTarget = $null
  }
}

foreach ($skillsRoot in $skillsRoots) {
  New-Item -ItemType Directory -Force -Path $skillsRoot.Root | Out-Null

  if ($skillsRoot.LegacyTarget -and (Test-Path -LiteralPath $skillsRoot.LegacyTarget)) {
    Remove-Item -LiteralPath $skillsRoot.LegacyTarget -Recurse -Force
  }

  foreach ($skillDir in $skillDirs) {
    $targetDir = Join-Path $skillsRoot.Root $skillDir.Name
    if (Test-Path -LiteralPath $targetDir) {
      Remove-Item -LiteralPath $targetDir -Recurse -Force
    }

    Copy-Item -LiteralPath $skillDir.FullName -Destination $targetDir -Recurse -Force
  }
}

Write-Host ""
Write-Host "Rebuilt and synced product-workflow skills to:"
foreach ($skillsRoot in $skillsRoots) {
  foreach ($skillDir in $skillDirs) {
    Write-Host (Join-Path $skillsRoot.Root $skillDir.Name)
  }
}
