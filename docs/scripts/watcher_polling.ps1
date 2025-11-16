# File: docs/07_WATCHER_POLLING.ps1
# Purpose: Monitor files with polling (more reliable than FileSystemWatcher)
# Author: Jose Alvarado Mazzei + Claude
# Version: 2.0.0

param(
    [Parameter(Mandatory=$false)]
    [switch]$Start,
    
    [Parameter(Mandatory=$false)]
    [int]$Interval = 3
)

$script:Config = @{
    ProjectRoot = $null
    DocsRoot = $PSScriptRoot
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
    PollInterval = $Interval
    ParserScript = '08_PARSER.ps1'
    LogPath = 'logs/watcher.log'
    ProcessedFiles = @{}
}

function Write-WatcherLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        'INFO'    { 'White' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
    
    $logPath = Join-Path $script:Config.DocsRoot $script:Config.LogPath
    Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Initialize-Paths {
    $currentPath = $PSScriptRoot
    
    while ($currentPath -and -not (Test-Path (Join-Path $currentPath "composer.json"))) {
        $parent = Split-Path $currentPath -Parent
        if ($parent -eq $currentPath) {
            Write-WatcherLog "Could not find project root" -Level ERROR
            return $false
        }
        $currentPath = $parent
    }
    
    $script:Config.ProjectRoot = $currentPath
    
    $logsDir = Join-Path $script:Config.DocsRoot "logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    
    Write-WatcherLog "Project root: $($script:Config.ProjectRoot)" -Level INFO
    
    return $true
}

function Test-HasMetaBlock {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        return ($content -match '@meta-start')
    }
    catch {
        return $false
    }
}

function Get-FileHash {
    param([string]$FilePath)
    
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm MD5
        return $hash.Hash
    }
    catch {
        return $null
    }
}

function Process-File {
    param([string]$FilePath)
    
    $parserPath = Join-Path $script:Config.DocsRoot $script:Config.ParserScript
    
    Write-WatcherLog "Processing: $FilePath" -Level INFO
    
    $result = & $parserPath -FilePath $FilePath 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-WatcherLog "Successfully processed: $FilePath" -Level SUCCESS
        return $true
    }
    else {
        Write-WatcherLog "Failed to process: $FilePath" -Level ERROR
        return $false
    }
}

function Get-WatchedFiles {
    $files = @()
    
    foreach ($folder in $script:Config.WatchFolders) {
        $fullPath = Join-Path $script:Config.ProjectRoot $folder
        
        if (-not (Test-Path $fullPath)) {
            continue
        }
        
        foreach ($ext in $script:Config.FileExtensions) {
            $found = Get-ChildItem -Path $fullPath -Filter $ext -Recurse -File -ErrorAction SilentlyContinue
            $files += $found
        }
    }
    
    return $files
}

function Start-PollingWatcher {
    if (-not (Initialize-Paths)) {
        Write-Host "Failed to initialize. Exiting." -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  HUBPERSONAL WATCHER (POLLING MODE)" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Project Root: $($script:Config.ProjectRoot)" -ForegroundColor White
    Write-Host "Poll Interval: $($script:Config.PollInterval) seconds" -ForegroundColor Gray
    Write-Host "Monitoring: *.php, *.vue files" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-WatcherLog "Watcher started (polling mode)" -Level INFO
    
    $lastCheck = Get-Date
    
    # Initial scan
    Write-WatcherLog "Performing initial scan..." -Level INFO
    $files = Get-WatchedFiles
    
    foreach ($file in $files) {
        $hash = Get-FileHash -FilePath $file.FullName
        if ($hash) {
            $script:Config.ProcessedFiles[$file.FullName] = @{
                Hash = $hash
                LastModified = $file.LastWriteTime
            }
        }
    }
    
    Write-WatcherLog "Initial scan complete. Tracking $($script:Config.ProcessedFiles.Count) files" -Level SUCCESS
    
    # Polling loop
    try {
        while ($true) {
            Start-Sleep -Seconds $script:Config.PollInterval
            
            $files = Get-WatchedFiles
            $changedFiles = @()
            
            foreach ($file in $files) {
                $currentHash = Get-FileHash -FilePath $file.FullName
                
                if (-not $currentHash) {
                    continue
                }
                
                # New file or changed file
                if (-not $script:Config.ProcessedFiles.ContainsKey($file.FullName)) {
                    # New file
                    if (Test-HasMetaBlock -FilePath $file.FullName) {
                        $changedFiles += $file
                    }
                    
                    $script:Config.ProcessedFiles[$file.FullName] = @{
                        Hash = $currentHash
                        LastModified = $file.LastWriteTime
                    }
                }
                elseif ($script:Config.ProcessedFiles[$file.FullName].Hash -ne $currentHash) {
                    # Changed file
                    if (Test-HasMetaBlock -FilePath $file.FullName) {
                        $changedFiles += $file
                    }
                    
                    $script:Config.ProcessedFiles[$file.FullName] = @{
                        Hash = $currentHash
                        LastModified = $file.LastWriteTime
                    }
                }
            }
            
            # Process changed files
            if ($changedFiles.Count -gt 0) {
                Write-Host ""
                Write-Host "Detected $($changedFiles.Count) file(s) with @meta blocks:" -ForegroundColor Yellow
                
                foreach ($file in $changedFiles) {
                    Write-Host "  - $($file.Name)" -ForegroundColor Gray
                    Process-File -FilePath $file.FullName
                }
                
                Write-Host ""
            }
        }
    }
    finally {
        Write-WatcherLog "Watcher stopped" -Level INFO
        
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "  WATCHER STOPPED" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host ""
    }
}

$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "Shutting down watcher..." -ForegroundColor Yellow
}

if ($Start) {
    Start-PollingWatcher
}
else {
    Write-Host ""
    Write-Host "HubPersonal Watcher (Polling Mode)" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "More reliable than FileSystemWatcher for Windows + VS Code" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\07_WATCHER_POLLING.ps1 -Start              Start watcher (default: 3s interval)" -ForegroundColor White
    Write-Host "  .\07_WATCHER_POLLING.ps1 -Start -Interval 5  Start with 5s interval" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\07_WATCHER_POLLING.ps1 -Start" -ForegroundColor Gray
    Write-Host "  .\07_WATCHER_POLLING.ps1 -Start -Interval 2" -ForegroundColor Gray
    Write-Host ""
}
