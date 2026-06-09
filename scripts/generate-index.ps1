#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Generate the cross-repo workspace discovery index.
  Writes to Vault/studios/Studio_Hub/discovery-index.md (or -OutputPath if specified).

.USAGE
  pwsh Studio_Hub/scripts/generate-index.ps1
  pwsh Studio_Hub/scripts/generate-index.ps1 -OutputPath path/to/output.md
  pwsh Studio_Hub/scripts/generate-index.ps1 -Quiet          # suppress progress output

.OUTPUT
  Vault/studios/Studio_Hub/discovery-index.md
#>

param(
    [string]$OutputPath = '',
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root       = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent  # C:\Git
$studiosDir = Join-Path $root 'Studios'
$vaultDir   = Join-Path $root 'Vault'

function Resolve-WorkspaceEntryPath([string]$name) {
    if ($name -eq 'Vault') {
        return $vaultDir
    }
    return Join-Path $studiosDir $name
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $root 'Vault' 'studios' 'Studio_Hub' 'discovery-index.md'
}

function Log([string]$msg) { if (-not $Quiet) { Write-Host $msg } }

Log "`n=== Discovery Index Generator ==="

$lines = [System.Collections.Generic.List[string]]::new()
$ts    = (Get-Date -Format 'yyyy-MM-dd')
$lines.Add("# Workspace Discovery Index")
$lines.Add("_Generated: $ts · Source: Studio_Hub/scripts/generate-index.ps1_")
$lines.Add("")

# ── Studios ───────────────────────────────────────────────────────────────────
Log "Scanning studios..."
$lines.Add("## Studios")
$lines.Add("")
$lines.Add("| ID | Name | Entry | Status |")
$lines.Add("|----|------|-------|--------|")

$studios     = @('AnimationStudio','ResearchStudio','Studio_Hub','Vault')
$manifestRel = 'agent-context/plugins/hub/manifest.md'
foreach ($s in $studios) {
    $workspacePath = Resolve-WorkspaceEntryPath $s
    $agentsPath = Join-Path $workspacePath 'AGENTS.md'
    $status     = if (Test-Path $agentsPath) { 'Active' } else { 'Entry missing' }
    $entryRel   = if ($s -eq 'Vault') { 'Vault/AGENTS.md' } else { "Studios/$s/AGENTS.md" }
    # Read studio_id from manifest if available, else derive from folder name
    $manifestPath = Join-Path $workspacePath $manifestRel
    $id = $s.ToLower() -replace '_','-'
    if (Test-Path $manifestPath) {
        $mContent = Get-Content $manifestPath -Raw
        if ($mContent -match '(?m)^studio_id:\s*(.+)$') { $id = $Matches[1].Trim() }
    }
    $lines.Add("| $id | $s | $entryRel | $status |")
}
$lines.Add("")

# ── Skills ────────────────────────────────────────────────────────────────────
Log "Scanning skills..."
$lines.Add("## Skills")
$lines.Add("")
$lines.Add("| Studio | Category | Skill | Path |")
$lines.Add("|--------|----------|-------|------|")

foreach ($s in $studios) {
    $workspacePath = Resolve-WorkspaceEntryPath $s
    $skillsRoot = Join-Path $workspacePath 'agent-context' 'skills'
    if (-not (Test-Path $skillsRoot)) { continue }
    Get-ChildItem -Path $skillsRoot -Recurse -Filter '*.skill.md' | Sort-Object FullName | ForEach-Object {
        $relPath  = $_.FullName.Substring($root.Length + 1).Replace('\','/')
        $category = $_.Directory.Name
        if ($category -eq 'skills') { $category = 'root' }
        $skillName = $_.BaseName -replace '\.skill$',''
        $lines.Add("| $s | $category | $skillName | $relPath |")
    }
}
$lines.Add("")

# ── Tasks ─────────────────────────────────────────────────────────────────────
Log "Scanning tasks..."
$lines.Add("## Tasks")
$lines.Add("")
$lines.Add("| Studio | Task | Path |")
$lines.Add("|--------|------|------|")

foreach ($s in $studios) {
    $workspacePath = Resolve-WorkspaceEntryPath $s
    $tasksRoot = Join-Path $workspacePath 'agent-context' 'tasks'
    if (-not (Test-Path $tasksRoot)) { continue }
    Get-ChildItem -Path $tasksRoot -Filter '*.task.md' | Sort-Object Name | ForEach-Object {
        $relPath  = $_.FullName.Substring($root.Length + 1).Replace('\','/')
        $taskName = $_.BaseName -replace '\.task$',''
        $lines.Add("| $s | $taskName | $relPath |")
    }
}
$lines.Add("")

# ── Projects ──────────────────────────────────────────────────────────────────
Log "Scanning projects (ResearchStudio)..."
$lines.Add("## Projects")
$lines.Add("")
$lines.Add("| ID | Title | Status | Path |")
$lines.Add("|----|-------|--------|------|")

$mapPath = Join-Path $vaultDir 'studios' 'ResearchStudio' 'projects' 'map.md'
if (Test-Path $mapPath) {
    $mapContent = Get-Content $mapPath
    foreach ($line in $mapContent) {
        # Match table rows: | NNN | folder | Title | Status | ... |
        if ($line -match '^\|\s*(\d{3})\s*\|\s*([^\|]+)\|\s*([^\|]+)\|\s*([^\|]+)\|') {
            $id     = $Matches[1].Trim()
            $folder = $Matches[2].Trim()
            $title  = $Matches[3].Trim()
            $status = $Matches[4].Trim()
            $path   = "Vault/studios/ResearchStudio/projects/$folder"
            $lines.Add("| $id | $title | $status | $path |")
        }
    }
}
$lines.Add("")

# ── Commissions ───────────────────────────────────────────────────────────────
Log "Scanning commissions..."
$lines.Add("## Commissions")
$lines.Add("")
$lines.Add("| ID | Title | Status | Project |")
$lines.Add("|----|-------|--------|---------|")

$commIndex = Join-Path $root 'Vault' 'commissions' 'index.md'
if (Test-Path $commIndex) {
    $commContent = Get-Content $commIndex
    foreach ($line in $commContent) {
        # Match dashboard table rows: | [cmsn-NNNN](...) | Title | studio | kind | status | priority | project | ... |
        if ($line -match '^\|\s*\[cmsn-(\d+)\]\([^\)]+\)\s*\|\s*([^\|]+)\|\s*[^\|]+\|\s*[^\|]+\|\s*([^\|]+)\|\s*[^\|]+\|\s*([^\|]*)\|') {
            $id      = "cmsn-$($Matches[1].Trim())"
            $title   = $Matches[2].Trim()
            $status  = $Matches[3].Trim()
            $project = $Matches[4].Trim()
            $lines.Add("| $id | $title | $status | $project |")
        }
    }
}
$lines.Add("")

# ── Write output ──────────────────────────────────────────────────────────────
$outputDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

$lines | Set-Content -Path $OutputPath -Encoding UTF8
Log "Written: $OutputPath"
Log ""

