#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Hub contract fast check — manifest presence + no absolute paths.
  Runs in < 10 seconds; suitable for pre-commit.

.USAGE
  pwsh Studio_Hub/scripts/validate-fast.ps1
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

function Resolve-WorkspaceEntryPath([string]$name) {
    if ($name -eq 'Vault') {
        return $vaultDir
    }
    return Join-Path $studiosDir $name
}

Write-Host "`n=== Hub Contract — Fast Check ===" -ForegroundColor Cyan

# ── BLOCK: manifest presence ──────────────────────────────────────────────────
foreach ($studio in $studios) {
    $basePath = Resolve-WorkspaceEntryPath $studio
    $path = Join-Path $basePath $manifestRel
    if (-not (Test-Path $path)) {
        $errors.Add("MANIFEST_MISSING: $studio/$manifestRel not found")
    }
}

# ── BLOCK: no absolute paths in any manifest ─────────────────────────────────
foreach ($studio in $studios) {
    $basePath = Resolve-WorkspaceEntryPath $studio
    $path = Join-Path $basePath $manifestRel
    if (-not (Test-Path $path)) { continue }
    $content = Get-Content $path -Raw
    if ($content -match '[A-Za-z]:\\') {
        $errors.Add("ABSOLUTE_PATH in $studio/$manifestRel — contains a Windows absolute path (C:\\ etc.)")
    }
    if ($content -match '(?m)^\s+source_path:\s+/') {
        $errors.Add("ABSOLUTE_PATH in $studio/$manifestRel — contains a Unix absolute path (/...)")
    }
}

# ── BLOCK: AGENTS.md exists (uppercase) for all four studios ─────────────────
foreach ($studio in $studios) {
    $basePath = Resolve-WorkspaceEntryPath $studio
    $agentsPath = Join-Path $basePath 'AGENTS.md'
    # Vault stores AGENTS.md at repo root (C:\Git\Vault\AGENTS.md)
    if (-not (Test-Path $agentsPath)) {
        $errors.Add("AGENTS_MISSING: $studio/AGENTS.md not found")
    }
}

# ── Summary ──────────────────────────────────────────────────────────────────
if ($warnings.Count -gt 0) {
    Write-Host "`nWARNINGS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  WARN: $_" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "`nFAILURES:" -ForegroundColor Red
    $errors  | ForEach-Object { Write-Host "  FAIL: $_" -ForegroundColor Red }
    Write-Host "`nFast check FAILED ($($errors.Count) error(s))" -ForegroundColor Red
    exit 1
}

Write-Host "`nFast check PASSED — all manifests present, no absolute paths" -ForegroundColor Green
exit 0
