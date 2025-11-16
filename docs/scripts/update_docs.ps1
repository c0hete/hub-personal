# File: docs/update_docs.ps1
# Purpose: Auto-update documentation system
# Usage: .\update_docs.ps1 [-Check] [-Update] [-Version]

param(
    [switch]$Check,
    [switch]$Update,
    [switch]$Version,
    [switch]$Help
)

$DocsDir = $PSScriptRoot
if ($DocsDir -like "*scripts") {
    $DocsDir = Split-Path $DocsDir -Parent
}
$IndexFile = "$DocsDir\00_INDEX.md"
$MasterFile = "$DocsDir\01_MASTER_DOC.md"
$ContextFile = "$DocsDir\02_CONTEXT.md"
$PromptsFile = "$DocsDir\03_PROMPTS.md"
$MetaFile = "$DocsDir\meta.json"

function Write-Success {
    param([string]$Message)
    Write-Host "OK: $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-WarningMsg {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Test-Files {
    Write-Host "`nChecking files..." -ForegroundColor Cyan
    
    $missing = 0
    
    if (-not (Test-Path $IndexFile)) {
        Write-ErrorMsg "Missing: $IndexFile"
        $missing++
    } else {
        Write-Success "Found: $IndexFile"
    }
    
    if (-not (Test-Path $MasterFile)) {
        Write-ErrorMsg "Missing: $MasterFile"
        $missing++
    } else {
        Write-Success "Found: $MasterFile"
    }
    
    if (-not (Test-Path $ContextFile)) {
        Write-ErrorMsg "Missing: $ContextFile"
        $missing++
    } else {
        Write-Success "Found: $ContextFile"
    }
    
    if (-not (Test-Path $PromptsFile)) {
        Write-ErrorMsg "Missing: $PromptsFile"
        $missing++
    } else {
        Write-Success "Found: $PromptsFile"
    }
    
    if (-not (Test-Path $MetaFile)) {
        Write-ErrorMsg "Missing: $MetaFile"
        $missing++
    } else {
        Write-Success "Found: $MetaFile"
    }
    
    if ($missing -gt 0) {
        Write-ErrorMsg "Missing $missing file(s)"
        exit 1
    }
    
    Write-Success "All files present"
}

function Get-CurrentVersion {
    $meta = Get-Content $MetaFile -Raw | ConvertFrom-Json
    return $meta.version.current
}

function Update-VersionNumber {
    param([string]$VersionString)
    
    $parts = $VersionString.Split('.')
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    
    $patch++
    
    return "$major.$minor.$patch"
}

function Set-MetaVersion {
    param([string]$NewVersion)
    
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $meta = Get-Content $MetaFile -Raw | ConvertFrom-Json
    $meta.version.current = $NewVersion
    $meta.version.last_updated = $timestamp
    
    $meta | ConvertTo-Json -Depth 10 | Set-Content $MetaFile
    
    Write-Success "Updated meta.json: v$NewVersion"
}

function Get-LineCount {
    param([string]$FilePath)
    return (Get-Content $FilePath).Count
}

function Update-LineCounts {
    $masterLines = Get-LineCount $MasterFile
    
    $meta = Get-Content $MetaFile -Raw | ConvertFrom-Json
    $meta.documentation.total_lines = $masterLines
    
    $meta | ConvertTo-Json -Depth 10 | Set-Content $MetaFile
    
    Write-Success "Updated line counts: $masterLines"
}

function Add-ChangelogEntry {
    param(
        [string]$VersionNum,
        [string]$Message
    )
    
    $date = Get-Date -Format "yyyy-MM-dd"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    
    $changelogEntry = "`n### v$VersionNum - $date`n**Changes:**`n- $Message`n`n---"
    $logEntry = "`n### $timestamp`n**Action:** Documentation updated`n**Version:** v$VersionNum`n**Change:** $Message`n`n---"
    
    $content = Get-Content $ContextFile -Raw
    $content = $content -replace '(## \[CHANGELOG:MASTER\] \[L\d+\])', "`$1$changelogEntry"
    $content = $content -replace '(## \[UPDATES:LOG\] \[L\d+\])', "`$1$logEntry"
    $content | Set-Content $ContextFile -NoNewline
    
    Write-Success "Added changelog entry"
}

function Test-Changes {
    if (-not (Test-Path .git)) {
        Write-WarningMsg "Not a git repository"
        return $false
    }
    
    $gitDiff = git diff HEAD -- $MasterFile 2>$null
    
    if ([string]::IsNullOrWhiteSpace($gitDiff)) {
        Write-Success "No changes in MASTER.md"
        return $false
    } else {
        Write-WarningMsg "Changes detected in MASTER.md"
        return $true
    }
}

function Invoke-UpdateDocs {
    Write-Host "`n=== Documentation Update ===" -ForegroundColor Cyan
    Write-Host ""
    
    Test-Files
    
    Write-Host ""
    $currentVersion = Get-CurrentVersion
    Write-Host "Current version: v$currentVersion" -ForegroundColor Cyan
    
    if (-not (Test-Changes)) {
        Write-Host ""
        Write-Success "Documentation is up to date"
        exit 0
    }
    
    Write-Host ""
    $changeMessage = Read-Host "Describe the change"
    
    if ([string]::IsNullOrWhiteSpace($changeMessage)) {
        Write-ErrorMsg "Change message is required"
        exit 1
    }
    
    Write-Host ""
    $newVersion = Update-VersionNumber $currentVersion
    Write-Host "New version: v$newVersion" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Updating..." -ForegroundColor Cyan
    
    Set-MetaVersion $newVersion
    Update-LineCounts
    Add-ChangelogEntry $newVersion $changeMessage
    
    Write-Host ""
    Write-Success "Documentation updated!"
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Version: v$currentVersion -> v$newVersion"
    Write-Host "  Change: $changeMessage"
    Write-Host ""
    
    $commit = Read-Host "Commit changes? (y/N)"
    if ($commit -eq 'y' -or $commit -eq 'Y') {
        git add $DocsDir
        git commit -m "docs: v$newVersion - $changeMessage"
        Write-Success "Changes committed"
    }
}

function Show-Status {
    Write-Host "`n=== Documentation Status ===" -ForegroundColor Cyan
    Write-Host ""
    
    Test-Files
    
    Write-Host ""
    $versionNum = Get-CurrentVersion
    $masterLines = Get-LineCount $MasterFile
    $contextLines = Get-LineCount $ContextFile
    $promptsLines = Get-LineCount $PromptsFile
    
    Write-Host "Version: v$versionNum" -ForegroundColor Cyan
    Write-Host "Lines:" -ForegroundColor Cyan
    Write-Host "  MASTER:  $masterLines"
    Write-Host "  CONTEXT: $contextLines"
    Write-Host "  PROMPTS: $promptsLines"
    Write-Host ""
    
    if (Test-Changes) {
        Write-WarningMsg "Changes detected in MASTER.md"
        Write-Host "Run: .\update_docs.ps1 -Update" -ForegroundColor Yellow
    } else {
        Write-Success "Documentation is up to date"
    }
    
    Write-Host ""
}

function Invoke-VersionBump {
    $currentVersion = Get-CurrentVersion
    $newVersion = Update-VersionNumber $currentVersion
    
    Set-MetaVersion $newVersion
    
    Write-Host ""
    Write-Success "Version bumped: v$currentVersion -> v$newVersion"
    Write-Host ""
}

function Show-Help {
    Write-Host ""
    Write-Host "Usage: .\update_docs.ps1 [-Option]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Check      Check status (default)"
    Write-Host "  -Update     Update documentation"
    Write-Host "  -Version    Bump version only"
    Write-Host "  -Help       Show help"
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

if ($Update) {
    Invoke-UpdateDocs
    exit 0
}

if ($Version) {
    Invoke-VersionBump
    exit 0
}

Show-Status
