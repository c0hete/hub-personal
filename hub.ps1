# File: hub.ps1
# Purpose: Master script for HubPersonal project commands
# Location: Project root (C:\Users\JoseA\Projects\hub-personal\)

param(
    [Parameter(Position=0)]
    [ValidateSet('watch', 'parse', 'update', 'status', 'help')]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$File
)

$ProjectRoot = $PSScriptRoot
$DocsPath = Join-Path $ProjectRoot "docs"
$ScriptsPath = Join-Path $DocsPath "scripts"

function Show-Help {
    Write-Host ""
    Write-Host "HubPersonal - Project Commands" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\hub.ps1 <command> [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  watch          Start file watcher (monitors app/ folder)" -ForegroundColor White
    Write-Host "  parse <file>   Parse specific file for @meta blocks" -ForegroundColor White
    Write-Host "  update         Update documentation version" -ForegroundColor White
    Write-Host "  status         Show documentation status" -ForegroundColor White
    Write-Host "  help           Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\hub.ps1 watch" -ForegroundColor DarkGray
    Write-Host "  .\hub.ps1 parse app/Models/User.php" -ForegroundColor DarkGray
    Write-Host "  .\hub.ps1 update" -ForegroundColor DarkGray
    Write-Host "  .\hub.ps1 status" -ForegroundColor DarkGray
    Write-Host ""
}

function Start-Watch {
    Write-Host "Starting watcher..." -ForegroundColor Cyan
    Set-Location $ScriptsPath
    & ".\07_WATCHER.ps1" -Path "$ProjectRoot\app" -Recursive
    Set-Location $ProjectRoot
}

function Invoke-Parse {
    param([string]$FilePath)
    
    if ([string]::IsNullOrEmpty($FilePath)) {
        Write-Host "Error: File path required" -ForegroundColor Red
        Write-Host "Usage: .\hub.ps1 parse <file>" -ForegroundColor Yellow
        return
    }
    
    $fullPath = Join-Path $ProjectRoot $FilePath
    
    if (!(Test-Path $fullPath)) {
        Write-Host "Error: File not found: $fullPath" -ForegroundColor Red
        return
    }
    
    Write-Host "Parsing: $FilePath" -ForegroundColor Cyan
    Set-Location $ScriptsPath
    & ".\08_PARSER.ps1" -File $fullPath
    Set-Location $ProjectRoot
}

function Update-Docs {
    Write-Host "Updating documentation..." -ForegroundColor Cyan
    Set-Location $ScriptsPath
    & ".\update_docs.ps1" -Update
    Set-Location $ProjectRoot
}

function Show-Status {
    Write-Host "Documentation status..." -ForegroundColor Cyan
    Set-Location $ScriptsPath
    & ".\update_docs.ps1" -Check
    Set-Location $ProjectRoot
}

# Main
switch ($Command) {
    'watch' {
        Start-Watch
    }
    'parse' {
        Invoke-Parse -FilePath $File
    }
    'update' {
        Update-Docs
    }
    'status' {
        Show-Status
    }
    'help' {
        Show-Help
    }
    default {
        Show-Help
    }
}
