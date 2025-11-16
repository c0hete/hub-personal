# File: docs/08_PARSER.ps1
# Purpose: Parse @meta blocks and auto-update MASTER.md
# Author: Jose Alvarado Mazzei + Claude
# Version: 1.0.0

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$script:ParserConfig = @{
    StrictValidation = $true
    AllowOptionalFields = $true
    CacheMaster = $true
    CacheDurationMinutes = 5
    BackupBeforeUpdate = $true
    BackupPath = 'backups'
    MaxBackups = 10
    LogLevel = 'INFO'
    LogPath = 'logs/parser.log'
    ErrorLogPath = 'logs/parser-errors.log'
    UpdateScript = 'update_docs.ps1'
    MasterDoc = '01_MASTER_DOC.md'
}

$script:DocsRoot = $PSScriptRoot
$script:MasterCache = $null
$script:MasterCacheTime = $null

function Write-ParserLog {
    param(
        [string]$Message,
        [string]$File = "",
        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fileTag = if ($File) { "[$File]" } else { "" }
    $logMessage = "[$timestamp] $fileTag [$Level] $Message"
    
    $levels = @{ 'DEBUG'=0; 'INFO'=1; 'WARN'=2; 'ERROR'=3; 'SUCCESS'=1 }
    $configLevel = $levels[$script:ParserConfig.LogLevel]
    $messageLevel = $levels[$Level]
    
    if ($messageLevel -ge $configLevel) {
        $color = switch ($Level) {
            'DEBUG'   { 'Gray' }
            'INFO'    { 'White' }
            'WARN'    { 'Yellow' }
            'ERROR'   { 'Red' }
            'SUCCESS' { 'Green' }
        }
        Write-Host $logMessage -ForegroundColor $color
        
        $logPath = if ($Level -eq 'ERROR') {
            Join-Path $script:DocsRoot $script:ParserConfig.ErrorLogPath
        } else {
            Join-Path $script:DocsRoot $script:ParserConfig.LogPath
        }
        
        Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
    }
}

function Get-MetaBlock {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        
        $pattern = '(?s)@meta-start(.*?)@meta-end'
        
        if ($content -match $pattern) {
            $metaContent = $matches[1]
            
            Write-ParserLog "Extracted @meta block" -File $FilePath -Level DEBUG
            
            return @{
                Success = $true
                Content = $metaContent
                FilePath = $FilePath
            }
        }
        else {
            Write-ParserLog "No @meta block found" -File $FilePath -Level WARN
            return @{ Success = $false; Error = "No @meta block found" }
        }
    }
    catch {
        Write-ParserLog "Failed to read file: $_" -File $FilePath -Level ERROR
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Parse-MetaContent {
    param([string]$Content)
    
    $meta = @{
        Session = $null
        Type = $null
        File = $null
        Feature = $null
        Refs = @()
        Changes = $null
        DocUpdates = @()
        Tests = @()
    }
    
    $lines = $content -split "`n"
    
    foreach ($line in $lines) {
        $line = $line.Trim()
        
        if ($line -match '^\s*\*?\s*@session:\s*(.+)$') {
            $meta.Session = $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@type:\s*(.+)$') {
            $meta.Type = $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@file:\s*(.+)$') {
            $meta.File = $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@feature:\s*(.+)$') {
            $meta.Feature = $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@refs:\s*(.+)$') {
            $refsText = $matches[1].Trim()
            $meta.Refs = [regex]::Matches($refsText, '\[([^\]]+)\]') | ForEach-Object { $_.Groups[1].Value }
        }
        elseif ($line -match '^\s*\*?\s*@changes:\s*(.+)$') {
            $meta.Changes = $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@doc-update:\s*(.+)$') {
            $meta.DocUpdates += $matches[1].Trim()
        }
        elseif ($line -match '^\s*\*?\s*@tests:\s*(.+)$') {
            $testsText = $matches[1].Trim()
            $meta.Tests = $testsText -split ',\s*'
        }
    }
    
    return $meta
}

function Test-MetaBlock {
    param($Meta)
    
    $errors = @()
    
    if (-not $Meta.Session) {
        $errors += "Missing required field: @session"
    }
    elseif ($Meta.Session -notmatch '^\d{4}-\d{2}-\d{2}-\d{3}$') {
        $errors += "Invalid @session format (expected: YYYY-MM-DD-NNN)"
    }
    
    if (-not $Meta.File) {
        $errors += "Missing required field: @file"
    }
    
    if (-not $Meta.Changes) {
        $errors += "Missing required field: @changes"
    }
    
    $validTypes = @(
        'model', 'migration', 'controller', 'service', 'repository',
        'request', 'resource', 'middleware', 'command', 'job',
        'event', 'listener', 'observer', 'policy', 'rule',
        'component', 'page', 'composable', 'store',
        'config', 'route', 'env', 'test'
    )
    
    if ($Meta.Type -and $Meta.Type -notin $validTypes) {
        $errors += "Invalid @type: $($Meta.Type)"
    }
    
    if ($Meta.Type -and $Meta.DocUpdates.Count -eq 0 -and $script:ParserConfig.StrictValidation) {
        $errors += "Code files should have @doc-update"
    }
    
    return @{
        IsValid = ($errors.Count -eq 0)
        Errors = $errors
    }
}

function Get-MasterContent {
    if ($script:ParserConfig.CacheMaster -and $script:MasterCache) {
        $cacheAge = (Get-Date) - $script:MasterCacheTime
        
        if ($cacheAge.TotalMinutes -lt $script:ParserConfig.CacheDurationMinutes) {
            Write-ParserLog "Using cached MASTER.md" -Level DEBUG
            return $script:MasterCache
        }
    }
    
    $masterPath = Join-Path $script:DocsRoot $script:ParserConfig.MasterDoc
    
    if (-not (Test-Path $masterPath)) {
        Write-ParserLog "MASTER.md not found: $masterPath" -Level ERROR
        return $null
    }
    
    $content = Get-Content -Path $masterPath -Raw
    
    $script:MasterCache = $content
    $script:MasterCacheTime = Get-Date
    
    Write-ParserLog "Loaded MASTER.md" -Level DEBUG
    
    return $content
}

function Find-MarkerLocation {
    param(
        [string]$Content,
        [string]$Marker
    )
    
    $markerName = $marker -replace '#.*$', ''
    
    $lines = $content -split "`n"
    $lineNumber = 0
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "\[$markerName\]") {
            $lineNumber = $i + 1
            break
        }
    }
    
    if ($lineNumber -eq 0) {
        return $null
    }
    
    return @{
        Marker = $markerName
        LineNumber = $lineNumber
        LineIndex = $lineNumber - 1
    }
}

function Backup-Master {
    if (-not $script:ParserConfig.BackupBeforeUpdate) {
        return $true
    }
    
    $masterPath = Join-Path $script:DocsRoot $script:ParserConfig.MasterDoc
    $backupDir = Join-Path $script:DocsRoot $script:ParserConfig.BackupPath
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "MASTER_$timestamp.md"
    $backupPath = Join-Path $backupDir $backupFile
    
    try {
        Copy-Item -Path $masterPath -Destination $backupPath -Force
        Write-ParserLog "Created backup: $backupFile" -Level DEBUG
        
        $backups = Get-ChildItem -Path $backupDir -Filter "MASTER_*.md" | 
                   Sort-Object LastWriteTime -Descending
        
        if ($backups.Count -gt $script:ParserConfig.MaxBackups) {
            $backups | Select-Object -Skip $script:ParserConfig.MaxBackups | Remove-Item
            Write-ParserLog "Cleaned old backups" -Level DEBUG
        }
        
        return $true
    }
    catch {
        Write-ParserLog "Failed to create backup: $_" -Level ERROR
        return $false
    }
}

function Parse-DocUpdate {
    param([string]$UpdateLine)
    
    if ($updateLine -match '^\[([^\]]+)\]\s+(\w+)\s+(.*)$') {
        return @{
            Marker = $matches[1]
            Action = $matches[2].ToUpper()
            Details = $matches[3].Trim()
        }
    }
    
    Write-ParserLog "Invalid @doc-update format: $updateLine" -Level ERROR
    return $null
}

function Apply-DocUpdate {
    param(
        [string]$Content,
        [hashtable]$Update
    )
    
    $location = Find-MarkerLocation -Content $Content -Marker $Update.Marker
    
    if (-not $location) {
        Write-ParserLog "Marker not found: $($Update.Marker)" -Level ERROR
        return $Content
    }
    
    Write-ParserLog "Found marker [$($location.Marker)] at line $($location.LineNumber)" -Level DEBUG
    
    $lines = $content -split "`n"
    $targetIndex = $location.LineIndex
    
    switch ($Update.Action) {
        'ADD' {
            $newLine = "- $($Update.Details)"
            $lines = $lines[0..$targetIndex] + $newLine + $lines[($targetIndex + 1)..($lines.Count - 1)]
            Write-ParserLog "ADD: $($Update.Details)" -Level INFO
        }
        
        'UPDATE' {
            for ($i = $targetIndex + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i].Trim()) {
                    $lines[$i] = "- $($Update.Details)"
                    Write-ParserLog "UPDATE: Line $($i + 1)" -Level INFO
                    break
                }
            }
        }
        
        'REMOVE' {
            $searchText = $Update.Details
            for ($i = $targetIndex + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match [regex]::Escape($searchText)) {
                    $lines = $lines[0..($i - 1)] + $lines[($i + 1)..($lines.Count - 1)]
                    Write-ParserLog "REMOVE: Line $($i + 1)" -Level INFO
                    break
                }
            }
        }
        
        'MARK' {
            $parts = $Update.Details -split '\s+', 2
            $feature = $parts[0]
            $status = if ($parts.Count -gt 1) { $parts[1] } else { 'DONE' }
            
            for ($i = $targetIndex + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match [regex]::Escape($feature)) {
                    $lines[$i] = $lines[$i] -replace '\[(TODO|IN_PROGRESS|DONE|BLOCKED|CANCELLED)\]', "[$status]"
                    Write-ParserLog "MARK: $feature -> $status" -Level INFO
                    break
                }
            }
        }
        
        'MOVE' {
            Write-ParserLog "MOVE action not yet implemented" -Level WARN
        }
        
        'NOTE' {
            $noteLine = "> **Note:** $($Update.Details)"
            $lines = $lines[0..$targetIndex] + $noteLine + $lines[($targetIndex + 1)..($lines.Count - 1)]
            Write-ParserLog "NOTE: Added warning" -Level INFO
        }
        
        default {
            Write-ParserLog "Unknown action: $($Update.Action)" -Level ERROR
        }
    }
    
    return ($lines -join "`n")
}

function Invoke-Parser {
    param([string]$FilePath)
    
    $fileName = Split-Path $FilePath -Leaf
    
    Write-ParserLog "Starting parser" -File $fileName -Level INFO
    Write-ParserLog "File: $FilePath" -Level DEBUG
    
    $metaBlock = Get-MetaBlock -FilePath $FilePath
    
    if (-not $metaBlock.Success) {
        Write-ParserLog $metaBlock.Error -File $fileName -Level ERROR
        return $false
    }
    
    $meta = Parse-MetaContent -Content $metaBlock.Content
    
    Write-ParserLog "Session: $($meta.Session)" -File $fileName -Level DEBUG
    Write-ParserLog "Changes: $($meta.Changes)" -File $fileName -Level DEBUG
    Write-ParserLog "Doc updates: $($meta.DocUpdates.Count)" -File $fileName -Level DEBUG
    
    $validation = Test-MetaBlock -Meta $meta
    
    if (-not $validation.IsValid) {
        Write-ParserLog "Validation failed:" -File $fileName -Level ERROR
        foreach ($error in $validation.Errors) {
            Write-ParserLog "  - $error" -File $fileName -Level ERROR
        }
        return $false
    }
    
    Write-ParserLog "Validation passed" -File $fileName -Level SUCCESS
    
    if ($meta.DocUpdates.Count -eq 0) {
        Write-ParserLog "No @doc-update directives" -File $fileName -Level INFO
        return $true
    }
    
    if ($DryRun) {
        Write-Host ""
        Write-Host "=== DRY RUN - Would apply these updates: ===" -ForegroundColor Yellow
        foreach ($update in $meta.DocUpdates) {
            Write-Host "  $update" -ForegroundColor Gray
        }
        Write-Host "=== DRY RUN COMPLETE ===" -ForegroundColor Yellow
        Write-Host ""
        return $true
    }
    
    $masterContent = Get-MasterContent
    
    if (-not $masterContent) {
        Write-ParserLog "Failed to load MASTER.md" -File $fileName -Level ERROR
        return $false
    }
    
    if (-not (Backup-Master)) {
        Write-ParserLog "Backup failed, aborting" -File $fileName -Level ERROR
        return $false
    }
    
    Write-ParserLog "Applying $($meta.DocUpdates.Count) doc update(s)" -File $fileName -Level INFO
    
    $updatedContent = $masterContent
    
    foreach ($updateLine in $meta.DocUpdates) {
        $update = Parse-DocUpdate -UpdateLine $updateLine
        
        if ($update) {
            $updatedContent = Apply-DocUpdate -Content $updatedContent -Update $update
        }
    }
    
    $masterPath = Join-Path $script:DocsRoot $script:ParserConfig.MasterDoc
    Set-Content -Path $masterPath -Value $updatedContent -NoNewline
    
    $script:MasterCache = $null
    
    Write-ParserLog "Updated MASTER.md" -File $fileName -Level SUCCESS
    
    $updateScriptPath = Join-Path $script:DocsRoot $script:ParserConfig.UpdateScript
    
    if (Test-Path $updateScriptPath) {
        Write-ParserLog "Calling update_docs.ps1..." -Level INFO
        
        & $updateScriptPath -Update 2>&1 | Out-Null
        
        Write-ParserLog "Versioning complete" -Level SUCCESS
    }
    else {
        Write-ParserLog "update_docs.ps1 not found" -Level WARN
    }
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  AUTO-UPDATE SUCCESSFUL" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "File:    $fileName" -ForegroundColor Gray
    Write-Host "Session: $($meta.Session)" -ForegroundColor Gray
    Write-Host "Updates: $($meta.DocUpdates.Count)" -ForegroundColor Gray
    Write-Host "Changes: $($meta.Changes)" -ForegroundColor Gray
    Write-Host ""
    
    return $true
}

$success = Invoke-Parser -FilePath $FilePath

if ($success) {
    exit 0
}
else {
    exit 1
}