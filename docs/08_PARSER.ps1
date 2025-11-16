param([string]$File,[switch]$Validate,[switch]$DryRun)
$MasterDoc = "01_MASTER_DOC.md"
$UpdateScript = "update_docs.ps1"

function Write-Success { param($m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Error-Custom { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }
function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warning-Custom { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=== METADATA PARSER v1.2 ===" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $File)) {
    Write-Error-Custom "File not found: $File"
    exit 1
}

Write-Info "Processing: $File"
$content = Get-Content $File -Raw

if (!($content -match "@meta-start")) {
    Write-Warning-Custom "No @meta block found"
    exit 0
}

Write-Success "Found @meta block"

$session = if ($content -match "@session:\s*(.+)") { $matches[1].Trim() } else { $null }
$fileField = if ($content -match "@file:\s*(.+)") { $matches[1].Trim() } else { $null }
$changes = if ($content -match "@changes:\s*(.+)") { $matches[1].Trim() } else { $null }
$refs = if ($content -match "@refs:\s*\[([^\]]+)\]") { $matches[1] -split "," | ForEach-Object { $_.Trim() -replace "#L\d+", "" } } else { @() }

$docUpdates = @()
$updateMatches = [regex]::Matches($content, "@doc-update:\s*(.+)")
foreach ($match in $updateMatches) {
    $line = $match.Groups[1].Value.Trim()
    if ($line -match "^\[([^\]]+)\]\s+(ADD|MODIFY|DELETE|MOVE)\s+(.+)$") {
        $docUpdates += @{
            Marker = $matches[1].Trim() -replace "#L\d+", ""
            Action = $matches[2].Trim()
            Details = $matches[3].Trim()
        }
    }
}

Write-Host ""
Write-Host "--- @meta Block ---" -ForegroundColor Cyan
if ($session) { Write-Info "Session: $session" }
if ($fileField) { Write-Info "File: $fileField" }
if ($changes) { Write-Info "Changes: $changes" }
if ($refs.Count -gt 0) { Write-Info "Refs: $($refs -join ", ")" }
if ($docUpdates.Count -gt 0) { Write-Info "Updates: $($docUpdates.Count)" }

if (!$session -or !$fileField -or !$changes -or $refs.Count -eq 0 -or $docUpdates.Count -eq 0) {
    Write-Error-Custom "Missing required fields"
    exit 1
}

if (!($session -match "^\d{4}-\d{2}-\d{2}-\d{3}$")) {
    Write-Error-Custom "Invalid session format. Expected: YYYY-MM-DD-NNN"
    exit 1
}

Write-Host ""
Write-Success "Validation passed"

if ($Validate) {
    Write-Host ""
    Write-Info "Validate-only mode. Exiting."
    exit 0
}

if (!(Test-Path $MasterDoc)) {
    Write-Error-Custom "MASTER.md not found: $MasterDoc"
    exit 1
}

Write-Host ""
Write-Host "Executing updates..." -ForegroundColor Cyan

$masterContent = Get-Content $MasterDoc -Raw
$updatesExecuted = 0

foreach ($update in $docUpdates) {
    Write-Info "[$($update.Marker)] $($update.Action) $($update.Details)"
    
    $markerPattern = "\[$($update.Marker)\]"
    if (!($masterContent -match $markerPattern)) {
        Write-Warning-Custom "Marker not found: [$($update.Marker)]"
        continue
    }
    
    if ($update.Action -eq "ADD") {
        $sectionPattern = "(\[$($update.Marker)\][^\[]*)"
        if ($masterContent -match $sectionPattern) {
            $section = $matches[1]
            $newSection = $section.TrimEnd() + "`n$($update.Details)`n"
            $masterContent = $masterContent -replace [regex]::Escape($section), $newSection
            $updatesExecuted++
            Write-Success "Updated [$($update.Marker)]"
        }
    }
}

if ($updatesExecuted -gt 0 -and !$DryRun) {
    Set-Content -Path $MasterDoc -Value $masterContent -NoNewline
    Write-Host ""
    Write-Success "MASTER.md updated ($updatesExecuted changes)"
    
    if (Test-Path $UpdateScript) {
        Write-Info "Calling $UpdateScript..."
        & ".\$UpdateScript" -Update 2>&1 | Out-Null
        Write-Success "Documentation versioned"
    } else {
        Write-Warning-Custom "update_docs.ps1 not found - skipping versioning"
    }
    
    if (Test-Path "../.git") {
        Write-Info "Auto-committing to git..."
        Push-Location ..
        git add "docs/$MasterDoc" 2>$null
        git commit -m "docs: Auto-update from $fileField - $changes" 2>$null
        Pop-Location
        Write-Success "Git commit created"
    }
} elseif ($DryRun) {
    Write-Info "DRY RUN: Would execute $updatesExecuted updates"
}

Write-Host ""
Write-Success "Parser completed"
