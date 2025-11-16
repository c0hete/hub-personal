# File: docs/07_WATCHER.ps1
# Purpose: Monitor code files for @meta blocks and trigger parser
# Author: Jose Alvarado Mazzei + Claude
# Version: 1.0.0

<#
.SYNOPSIS
    File system watcher for HubPersonal project - detects @meta blocks and triggers auto-updates

.DESCRIPTION
    Monitors specified folders for file changes (*.php, *.vue)
    Detects @meta blocks in saved files
    Debounces rapid saves (2 second window)
    Calls parser to auto-update MASTER.md
    Logs all activity

.PARAMETER Start
    Start the file watcher

.PARAMETER Stop
    Stop the file watcher (Ctrl+C)

.PARAMETER Config
    Show current configuration

.EXAMPLE
    .\07_WATCHER.ps1 -Start
    Starts watching for file changes

.EXAMPLE
    .\07_WATCHER.ps1 -Config
    Shows current configuration
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Start,
    
    [Parameter(Mandatory=$false)]
    [switch]$Config
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$script:WatcherConfig = @{
    ProjectRoot = $null
    WatchFolders = @(
        'app',
        'database/migrations',
        'database/seeders',
        'config',
        'routes',
        'resources/js/Pages',
        'resources/js/Components'
    )
    FileExtensions = @('*.php', '*.vue')
    DebounceMs = 2000
    GitAutoCommit = $true
    GitAutoPush = $false
    LogLevel = 'INFO'
    LogPath = 'logs/watcher.log'
    ErrorLogPath = 'logs/parser-errors.log'
    ShowConsoleNotifications = $true
    ShowToastNotifications = $false
    ParserScript = '08_PARSER.ps1'
}

# ============================================================================
# GLOBAL STATE
# ============================================================================

$script:Watchers = @()
$script:LastChange = @{}
$script:ProcessingQueue = @{}
$script:IsRunning = $false

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-WatcherLog {
    param(
        [string]$Message,
        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $levels = @{ 'DEBUG'=0; 'INFO'=1; 'WARN'=2; 'ERROR'=3 }
    $configLevel = $levels[$script:WatcherConfig.LogLevel]
    $messageLevel = $levels[$Level]
    
    if ($messageLevel -ge $configLevel) {
        switch ($Level) {
            'DEBUG' { Write-Host $logMessage -ForegroundColor Gray }
            'INFO'  { Write-Host $logMessage -ForegroundColor White }
            'WARN'  { Write-Host $logMessage -ForegroundColor Yellow }
            'ERROR' { Write-Host $logMessage -ForegroundColor Red }
        }
        
        $logPath = Join-Path $script:DocsRoot $script:WatcherConfig.LogPath
        Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
    }
}

function Initialize-Paths {
    $currentPath = $PSScriptRoot
    
    while ($currentPath -and -not (Test-Path (Join-Path $currentPath "composer.json"))) {
        $parent = Split-Path $currentPath -Parent
        if ($parent -eq $currentPath) {
            Write-WatcherLog "Could not find project root (no composer.json found)" -Level ERROR
            return $false
        }
        $currentPath = $parent
    }
    
    $script:ProjectRoot = $currentPath
    $script:DocsRoot = $PSScriptRoot
    
    $logsDir = Join-Path $script:DocsRoot "logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
        Write-WatcherLog "Created logs directory: $logsDir" -Level INFO
    }
    
    Write-WatcherLog "Project root: $script:ProjectRoot" -Level DEBUG
    Write-WatcherLog "Docs root: $script:DocsRoot" -Level DEBUG
    
    return $true
}

function Show-Configuration {
    Write-Host ""
    Write-Host "=== WATCHER CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host "Project Root: $($script:ProjectRoot)" -ForegroundColor White
    Write-Host "Docs Root: $($script:DocsRoot)" -ForegroundColor White
    Write-Host ""
    Write-Host "Watch Folders:" -ForegroundColor Yellow
    $script:WatcherConfig.WatchFolders | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "File Extensions:" -ForegroundColor Yellow
    $script:WatcherConfig.FileExtensions | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Settings:" -ForegroundColor Yellow
    Write-Host "  Debounce: $($script:WatcherConfig.DebounceMs)ms" -ForegroundColor Gray
    Write-Host "  Log Level: $($script:WatcherConfig.LogLevel)" -ForegroundColor Gray
    Write-Host "  Git Auto-Commit: $($script:WatcherConfig.GitAutoCommit)" -ForegroundColor Gray
    Write-Host "  Git Auto-Push: $($script:WatcherConfig.GitAutoPush)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# META BLOCK DETECTION
# ============================================================================

function Test-HasMetaBlock {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        
        if ($content -match '@meta-start') {
            Write-WatcherLog "Found @meta block in: $FilePath" -Level DEBUG
            return $true
        }
        
        return $false
    }
    catch {
        Write-WatcherLog "Error reading file: $FilePath - $_" -Level ERROR
        return $false
    }
}

# ============================================================================
# DEBOUNCE LOGIC
# ============================================================================

function Start-DebouncedParse {
    param([string]$FilePath)
    
    $now = Get-Date
    
    if ($script:ProcessingQueue.ContainsKey($FilePath)) {
        Write-WatcherLog "Already queued: $FilePath" -Level DEBUG
        return
    }
    
    if ($script:LastChange.ContainsKey($FilePath)) {
        $timeSinceLastChange = ($now - $script:LastChange[$FilePath]).TotalMilliseconds
        
        if ($timeSinceLastChange -lt $script:WatcherConfig.DebounceMs) {
            Write-WatcherLog "Debouncing: $FilePath ($([int]$timeSinceLastChange)ms since last change)" -Level DEBUG
            return
        }
    }
    
    $script:LastChange[$FilePath] = $now
    $script:ProcessingQueue[$FilePath] = $now
    
    Write-WatcherLog "Queued for parsing: $FilePath" -Level INFO
    
    Start-Job -ScriptBlock {
        param($FilePath, $DebounceMs, $DocsRoot, $ParserScript)
        
        Start-Sleep -Milliseconds $DebounceMs
        
        $parserPath = Join-Path $DocsRoot $ParserScript
        & $parserPath -FilePath $FilePath
        
    } -ArgumentList $FilePath, $script:WatcherConfig.DebounceMs, $script:DocsRoot, $script:WatcherConfig.ParserScript | Out-Null
    
    Start-Job -ScriptBlock {
        param($FilePath, $DebounceMs, $ProcessingQueue)
        
        Start-Sleep -Milliseconds ($DebounceMs + 1000)
        $ProcessingQueue.Remove($FilePath)
        
    } -ArgumentList $FilePath, $script:WatcherConfig.DebounceMs, $script:ProcessingQueue | Out-Null
}

# ============================================================================
# FILE SYSTEM EVENT HANDLERS
# ============================================================================

function Register-FileSystemWatcher {
    param([string]$FolderPath)
    
    if (-not (Test-Path $FolderPath)) {
        Write-WatcherLog "Folder not found, skipping: $FolderPath" -Level WARN
        return $null
    }
    
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $FolderPath
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName,LastWrite'
    
    $action = {
        param($source, $e)
        
        $filePath = $e.FullPath
        $changeType = $e.ChangeType
        
        $extension = [System.IO.Path]::GetExtension($filePath)
        $matchesExtension = $false
        
        foreach ($pattern in $script:WatcherConfig.FileExtensions) {
            $regex = $pattern -replace '\*', '.*' -replace '\.', '\.'
            if ($extension -match $regex) {
                $matchesExtension = $true
                break
            }
        }
        
        if (-not $matchesExtension) {
            return
        }
        
        Write-WatcherLog "Detected: $changeType - $filePath" -Level DEBUG
        
        Start-Sleep -Milliseconds 100
        
        if (Test-HasMetaBlock -FilePath $filePath) {
            Write-WatcherLog "File has @meta block, triggering parser..." -Level INFO
            Start-DebouncedParse -FilePath $filePath
        }
        else {
            Write-WatcherLog "No @meta block found, skipping: $filePath" -Level DEBUG
        }
    }
    
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action | Out-Null
    
    Write-WatcherLog "Watching: $FolderPath" -Level INFO
    
    return $watcher
}

# ============================================================================
# WATCHER LIFECYCLE
# ============================================================================

function Start-Watcher {
    if ($script:IsRunning) {
        Write-WatcherLog "Watcher is already running" -Level WARN
        return
    }
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  HUBPERSONAL FILE WATCHER STARTED" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Initialize-Paths)) {
        Write-Host "Failed to initialize paths. Exiting." -ForegroundColor Red
        return
    }
    
    Show-Configuration
    
    foreach ($folder in $script:WatcherConfig.WatchFolders) {
        $fullPath = Join-Path $script:ProjectRoot $folder
        $watcher = Register-FileSystemWatcher -FolderPath $fullPath
        
        if ($watcher) {
            $script:Watchers += $watcher
        }
    }
    
    if ($script:Watchers.Count -eq 0) {
        Write-WatcherLog "No watchers registered. Check folder paths." -Level ERROR
        return
    }
    
    $script:IsRunning = $true
    
    Write-Host "Watching $($script:Watchers.Count) folders for @meta blocks" -ForegroundColor Green
    Write-Host "Monitoring extensions: $($script:WatcherConfig.FileExtensions -join ', ')" -ForegroundColor Gray
    Write-Host "Debounce: $($script:WatcherConfig.DebounceMs)ms" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-WatcherLog "Watcher started successfully" -Level INFO
    
    try {
        while ($script:IsRunning) {
            Start-Sleep -Seconds 1
            Get-Job -State Completed | Remove-Job
        }
    }
    finally {
        Stop-Watcher
    }
}

function Stop-Watcher {
    if (-not $script:IsRunning) {
        return
    }
    
    Write-Host ""
    Write-Host ""
    Write-Host "Stopping watcher..." -ForegroundColor Yellow
    
    foreach ($watcher in $script:Watchers) {
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
    }
    
    Get-EventSubscriber | Where-Object { $_.SourceObject -is [System.IO.FileSystemWatcher] } | Unregister-Event
    
    Get-Job | Stop-Job
    Get-Job | Remove-Job
    
    $script:Watchers = @()
    $script:IsRunning = $false
    
    Write-WatcherLog "Watcher stopped" -Level INFO
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  HUBPERSONAL FILE WATCHER STOPPED" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Stop-Watcher
}

if ($Config) {
    if (-not (Initialize-Paths)) {
        Write-Host "Failed to initialize paths." -ForegroundColor Red
        exit 1
    }
    Show-Configuration
    exit 0
}

if ($Start) {
    Start-Watcher
}
else {
    Write-Host ""
    Write-Host "HubPersonal File Watcher" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\07_WATCHER.ps1 -Start     Start watching for file changes" -ForegroundColor Gray
    Write-Host "  .\07_WATCHER.ps1 -Config    Show current configuration" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\07_WATCHER.ps1 -Start" -ForegroundColor Gray
    Write-Host ""
}
