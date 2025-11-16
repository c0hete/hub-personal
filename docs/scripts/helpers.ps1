# File: docs/profile_helpers.ps1
# Purpose: Helper functions for PowerShell profile
# Usage: Add to your $PROFILE or run: . .\profile_helpers.ps1

# ==============================================================================
# HUBPERSONAL HELPERS
# ==============================================================================

# Set project path (change this to your project location)
$global:HubPersonalRoot = "C:\Users\JoseA\Projects\hub-personal"
$global:HubPersonalDocs = "$global:HubPersonalRoot\docs"

# ------------------------------------------------------------------------------
# meta - Process file(s) with @meta blocks
# ------------------------------------------------------------------------------
function meta {
    <#
    .SYNOPSIS
        Process files with @meta blocks through the parser
    
    .PARAMETER File
        Specific file to process. If omitted, processes all recently changed files.
    
    .PARAMETER All
        Process all files with @meta blocks in the project
    
    .EXAMPLE
        meta app/Models/Note.php
        Process specific file
    
    .EXAMPLE
        meta
        Process all files changed in last 5 minutes
    
    .EXAMPLE
        meta -All
        Process all files with @meta blocks
    #>
    
    param(
        [string]$File = "",
        [switch]$All
    )
    
    $parserScript = Join-Path $global:HubPersonalDocs "08_PARSER.ps1"
    
    if (-not (Test-Path $parserScript)) {
        Write-Host "Parser not found: $parserScript" -ForegroundColor Red
        return
    }
    
    if ($File -ne "") {
        # Process specific file
        $fullPath = if ([System.IO.Path]::IsPathRooted($File)) {
            $File
        } else {
            Join-Path $global:HubPersonalRoot $File
        }
        
        if (Test-Path $fullPath) {
            & $parserScript -FilePath $fullPath
        }
        else {
            Write-Host "File not found: $fullPath" -ForegroundColor Red
        }
    }
    elseif ($All) {
        # Process all files with @meta
        Write-Host "Scanning for files with @meta blocks..." -ForegroundColor Yellow
        
        $files = Get-ChildItem -Path $global:HubPersonalRoot -Recurse -Include *.php,*.vue -File |
                 Where-Object { (Get-Content $_.FullName -Raw) -match '@meta-start' }
        
        if ($files.Count -eq 0) {
            Write-Host "No files with @meta blocks found" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Found $($files.Count) file(s) with @meta blocks" -ForegroundColor Green
        
        foreach ($f in $files) {
            Write-Host "Processing: $($f.Name)" -ForegroundColor Gray
            & $parserScript -FilePath $f.FullName
        }
    }
    else {
        # Process recently changed files
        $cutoff = (Get-Date).AddMinutes(-5)
        
        $files = Get-ChildItem -Path $global:HubPersonalRoot -Recurse -Include *.php,*.vue -File |
                 Where-Object { $_.LastWriteTime -gt $cutoff -and (Get-Content $_.FullName -Raw) -match '@meta-start' }
        
        if ($files.Count -eq 0) {
            Write-Host "No recently changed files with @meta blocks (last 5 minutes)" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Processing $($files.Count) recently changed file(s):" -ForegroundColor Green
        
        foreach ($f in $files) {
            Write-Host "  - $($f.Name)" -ForegroundColor Gray
            & $parserScript -FilePath $f.FullName
        }
    }
}

# ------------------------------------------------------------------------------
# meta-watch - Start/stop the file watcher
# ------------------------------------------------------------------------------
function meta-watch {
    <#
    .SYNOPSIS
        Start or manage the meta watcher
    
    .PARAMETER Start
        Start the watcher
    
    .PARAMETER Interval
        Poll interval in seconds (default: 3)
    
    .EXAMPLE
        meta-watch -Start
        Start watcher with 3s interval
    
    .EXAMPLE
        meta-watch -Start -Interval 5
        Start watcher with 5s interval
    #>
    
    param(
        [switch]$Start,
        [int]$Interval = 3
    )
    
    $watcherScript = Join-Path $global:HubPersonalDocs "07_WATCHER_POLLING.ps1"
    
    if (-not (Test-Path $watcherScript)) {
        Write-Host "Watcher not found: $watcherScript" -ForegroundColor Red
        return
    }
    
    if ($Start) {
        & $watcherScript -Start -Interval $Interval
    }
    else {
        & $watcherScript
    }
}

# ------------------------------------------------------------------------------
# meta-session - Manage session tracking
# ------------------------------------------------------------------------------
function meta-session {
    <#
    .SYNOPSIS
        Manage Claude conversation session tracking
    
    .PARAMETER Start
        Start new session
    
    .PARAMETER Add
        Add message to current session
    
    .PARAMETER Status
        Show current session status
    
    .PARAMETER End
        End current session
    
    .PARAMETER Summary
        Summary for -End
    
    .PARAMETER NextSteps
        Next steps for -End
    
    .EXAMPLE
        meta-session -Start
        Start tracking new session
    
    .EXAMPLE
        meta-session -Add
        Increment message counter
    
    .EXAMPLE
        meta-session -End -Summary "Created models" -NextSteps "Build controllers"
        End session with summary
    #>
    
    param(
        [switch]$Start,
        [switch]$Add,
        [switch]$Status,
        [switch]$End,
        [string]$Summary = "",
        [string]$NextSteps = ""
    )
    
    $trackerScript = Join-Path $global:HubPersonalDocs "session_tracker.ps1"
    
    if (-not (Test-Path $trackerScript)) {
        Write-Host "Session tracker not found: $trackerScript" -ForegroundColor Red
        return
    }
    
    if ($Start) {
        & $trackerScript -Start
    }
    elseif ($Add) {
        & $trackerScript -AddMessage
    }
    elseif ($Status) {
        & $trackerScript -Status
    }
    elseif ($End) {
        if ($Summary -or $NextSteps) {
            & $trackerScript -End -Summary $Summary -NextSteps $NextSteps
        }
        else {
            & $trackerScript -End
        }
    }
    else {
        & $trackerScript
    }
}

# ------------------------------------------------------------------------------
# Quick aliases
# ------------------------------------------------------------------------------
Set-Alias -Name m -Value meta
Set-Alias -Name mw -Value meta-watch
Set-Alias -Name ms -Value meta-session

# ------------------------------------------------------------------------------
# Show loaded message
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "HubPersonal helpers loaded!" -ForegroundColor Green
Write-Host "Commands available:" -ForegroundColor Yellow
Write-Host "  meta <file>         - Process file with @meta block" -ForegroundColor Gray
Write-Host "  meta                - Process recent changes" -ForegroundColor Gray
Write-Host "  meta -All           - Process all @meta files" -ForegroundColor Gray
Write-Host "  meta-watch -Start   - Start file watcher" -ForegroundColor Gray
Write-Host "  meta-session -Start - Start session tracking" -ForegroundColor Gray
Write-Host "  meta-session -Add   - Add message" -ForegroundColor Gray
Write-Host ""
Write-Host "Quick aliases: m, mw, ms" -ForegroundColor Cyan
Write-Host ""
