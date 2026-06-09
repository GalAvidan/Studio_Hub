#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Hub contract full check — sources resolve + discovery-index drift + lint summary.
  Runs on push / PR. Includes all fast-check assertions plus deeper validation.

.USAGE
  pwsh Studio_Hub/scripts/validate-full.ps1
  Run from the workspace root (C:\Git).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root        = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent  # C:\Git
$studiosDir  = Join-Path $root 'Studios'
$vaultDir    = Join-Path $root 'Vault'
$studios     = @('AnimationStudio','ResearchStudio','Vault','Studio_Hub')
$manifestRel = 'agent-context/plugins/hub/manifest.md'
$errors      = [System.Collections.Generic.List[string]]::new()
$warnings    = [System.Collections.Generic.List[string]]::new()
$infos       = [System.Collections.Generic.List[string]]::new()

function Resolve-WorkspaceEntryPath([string]$name) {
    if ($name -eq 'Vault') {
        return $vaultDir
    }
    return Join-Path $studiosDir $name
}

Write-Host "`n=== Hub Contract — Full Check ===" -ForegroundColor Cyan

# ── Include fast checks ───────────────────────────────────────────────────────
& (Join-Path $PSScriptRoot 'validate-fast.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nFull check aborted — fast check failed first" -ForegroundColor Red
    exit 1
}

# ── BLOCK: every manifest source_path resolves ───────────────────────────────
foreach ($studio in $studios) {
    $basePath = Resolve-WorkspaceEntryPath $studio
    $manifestPath = Join-Path $basePath $manifestRel
    if (-not (Test-Path $manifestPath)) { continue }

    $content = Get-Content $manifestPath -Raw
    $sourcePaths = [regex]::Matches($content, '(?m)^\s+source_path:\s+(.+)$') |
        ForEach-Object { $_.Groups[1].Value.Trim() }

    foreach ($sp in $sourcePaths) {
        $resolved = Join-Path $root $sp
        if (-not (Test-Path $resolved)) {
            $errors.Add("SOURCE_UNREADABLE in $studio/$manifestRel — source_path '$sp' does not resolve to an existing path")
        }
    }
}

# ── BLOCK: discovery-index drift ─────────────────────────────────────────────
$indexScript    = Join-Path $PSScriptRoot 'generate-index.ps1'
$committedIndex = Join-Path $vaultDir 'studios' 'Studio_Hub' 'discovery-index.md'

if ((Test-Path $indexScript) -and (Test-Path $committedIndex)) {
    $tempIndex = Join-Path ([System.IO.Path]::GetTempPath()) 'discovery-index-check.md'
    & $indexScript -OutputPath $tempIndex -Quiet
    $committedHash = (Get-FileHash $committedIndex -Algorithm SHA256).Hash
    $freshHash     = (Get-FileHash $tempIndex     -Algorithm SHA256).Hash
    if ($committedHash -ne $freshHash) {
        $errors.Add("INDEX_DRIFT: Vault/studios/Studio_Hub/discovery-index.md is out of date. Run 'pwsh Studio_Hub/scripts/generate-index.ps1' and commit.")
    }
    Remove-Item $tempIndex -ErrorAction SilentlyContinue
} elseif (-not (Test-Path $indexScript)) {
    $warnings.Add("generate-index.ps1 not found — skipping index drift check")
} elseif (-not (Test-Path $committedIndex)) {
    $warnings.Add("discovery-index.md not committed yet — skipping drift check. Run generate-index.ps1 and commit.")
}

# ── WARN: binary files staged without LFS pointer ────────────────────────────
$vaultPath = $vaultDir
if (Test-Path (Join-Path $vaultPath '.git')) {
    $stagedBinaries = git -C $vaultPath diff --cached --name-only 2>$null |
        Where-Object { $_ -match '\.(mp4|webm|wav|mp3|aif|pdf|png|jpg|jpeg|gif)$' }
    foreach ($bin in $stagedBinaries) {
        $fullPath = Join-Path $vaultPath $bin
        if ((Test-Path $fullPath) -and (Get-Item $fullPath).Length -gt 1MB) {
            $warnings.Add("LARGE_BINARY_NO_LFS: Vault/$bin is > 1MB and staged — ensure LFS is set up in Vault/.gitattributes")
        }
    }
}

# ── INFO: casing nits ─────────────────────────────────────────────────────────
$casingNits = @('bot.md','context.md','readme.md')
foreach ($studio in $studios) {
    $basePath = Resolve-WorkspaceEntryPath $studio
    foreach ($nit in $casingNits) {
        $nitPath = Join-Path $basePath $nit
        if (Test-Path $nitPath) {
            $infos.Add("CASING_NIT: $studio/$nit — consider uppercase (BOT.md / CONTEXT.md / README.md)")
        }
    }
}

# ── Summary ──────────────────────────────────────────────────────────────────
if ($infos.Count -gt 0) {
    Write-Host "`nINFO:" -ForegroundColor DarkGray
    $infos | ForEach-Object { Write-Host "  INFO: $_" -ForegroundColor DarkGray }
}

if ($warnings.Count -gt 0) {
    Write-Host "`nWARNINGS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  WARN: $_" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "`nFAILURES:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  FAIL: $_" -ForegroundColor Red }
    Write-Host "`nFull check FAILED ($($errors.Count) error(s))" -ForegroundColor Red
    exit 1
}

Write-Host "`nFull check PASSED" -ForegroundColor Green
exit 0

