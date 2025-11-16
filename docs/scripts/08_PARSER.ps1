# File: 08_PARSER.ps1
# Purpose: Parse @meta blocks from code and update MASTER.md
# Version: 1.0.0
# Protocol: 06_METADATA_PROTOCOL.md v1.0.0

<#
.SYNOPSIS
    Metadata protocol parser - Auto-update MASTER.md from code comments

.DESCRIPTION
    Extracts @meta blocks from source files, validates fields,
    executes @doc-update actions, and syncs MASTER.md automatically.

.PARAMETER File
    Source file to parse (supports PHP, Vue, JS, Blade, SQL)

.PARAMETER Validate
    Validate only, don't execute updates

.PARAMETER DryRun
    Show what would be updated without changing files

.EXAMPLE
    .\08_PARSER.ps1 -File "app/Models/User.php"
    Process single file

.EXAMPLE
    .\08_PARSER.ps1 -File "app/Models/User.php" -DryRun
    Preview changes without applying

.EXAMPLE
    .\08_PARSER.ps1 -File "app/Models/User.php" -Validate
    Validate @meta block syntax only
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# === CONFIGURATION ===

$Script:Config = @{
    MasterDoc = "01_MASTER_DOC.md"
    ContextDoc = "02_CONTEXT.md"
    UpdateScript = "update_docs.ps1"
    LogFile = "parser.log"
}

$Script:Stats = @{
    BlocksFound = 0
    BlocksValid = 0
    UpdatesExecuted = 0
    Errors = 0
}

# === COLOR OUTPUT ===

function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error-Custom { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning-Custom { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }

# === LOGGING ===

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $Script:Config.LogFile -Value $logEntry -ErrorAction SilentlyContinue
}

# === FILE VALIDATION ===

function Test-SourceFile {
    param([string]$FilePath)
    
    if (!(Test-Path $FilePath)) {
        Write-Error-Custom "File not found: $FilePath"
        Write-Log "File not found: $FilePath" "ERROR"
        return $false
    }
    
    $extension = [System.IO.Path]::GetExtension($FilePath)
    $validExtensions = @('.php', '.vue', '.js', '.blade.php', '.sql', '.ts', '.jsx', '.tsx')
    
    if ($extension -notin $validExtensions) {
        Write-Warning-Custom "Unsupported file type: $extension"
        Write-Log "Unsupported file type: $extension for file $FilePath" "WARNING"
        return $false
    }
    
    return $true
}

# === EXTRACT @META BLOCKS ===

function Get-MetaBlocks {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw
    $blocks = @()
    
    # Regex patterns for different comment styles
    $patterns = @{
        'php'   = '\/\*\*[\s\S]*?@meta-start[\s\S]*?@meta-end[\s\S]*?\*\/'
        'vue'   = '<!--[\s\S]*?@meta-start[\s\S]*?@meta-end[\s\S]*?-->'
        'js'    = '\/\*\*[\s\S]*?@meta-start[\s\S]*?@meta-end[\s\S]*?\*\/'
        'blade' = '\{\{--[\s\S]*?@meta-start[\s\S]*?@meta-end[\s\S]*?--\}\}'
        'sql'   = '--\s*@meta-start[\s\S]*?--\s*@meta-end'
    }
    
    # Determine file type
    $extension = [System.IO.Path]::GetExtension($FilePath).TrimStart('.')
    $fileType = switch ($extension) {
        'php' { 'php' }
        'vue' { 'vue' }
        { $_ -in @('js', 'jsx', 'ts', 'tsx') } { 'js' }
        'blade.php' { 'blade' }
        'sql' { 'sql' }
        default { 'php' }
    }
    
    # Extract blocks
    $pattern = $patterns[$fileType]
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $blockText = $match.Value
        $Script:Stats.BlocksFound++
        
        $block = Parse-MetaBlock -BlockText $blockText -FilePath $FilePath
        
        if ($block) {
            $blocks += $block
        }
    }
    
    return $blocks
}

# === PARSE @META BLOCK ===

function Parse-MetaBlock {
    param([string]$BlockText, [string]$FilePath)
    
    $block = @{
        Raw = $BlockText
        Session = $null
        File = $null
        Feature = $null
        Refs = @()
        Changes = $null
        DocUpdates = @()
        Tests = $null
        Valid = $false
        Errors = @()
    }
    
    # Extract @session
    if ($BlockText -match '@session:\s*(.+)') {
        $block.Session = $matches[1].Trim()
    } else {
        $block.Errors += "Missing required field: @session"
    }
    
    # Extract @file
    if ($BlockText -match '@file:\s*(.+)') {
        $block.File = $matches[1].Trim()
    } else {
        $block.Errors += "Missing required field: @file"
    }
    
    # Extract @feature (optional)
    if ($BlockText -match '@feature:\s*(.+)') {
        $block.Feature = $matches[1].Trim()
    }
    
    # Extract @refs
    if ($BlockText -match '@refs:\s*\[([^\]]+)\]') {
        $refsString = $matches[1]
        $block.Refs = $refsString -split ',\s*' | ForEach-Object { $_.Trim() }
    } else {
        $block.Errors += "Missing required field: @refs"
    }
    
    # Extract @changes
    if ($BlockText -match '@changes:\s*(.+)') {
        $block.Changes = $matches[1].Trim()
    } else {
        $block.Errors += "Missing required field: @changes"
    }
    
    # Extract @doc-update (multiple allowed)
    $updateMatches = [regex]::Matches($BlockText, '@doc-update:\s*(.+)')
    if ($updateMatches.Count -eq 0) {
        $block.Errors += "Missing required field: @doc-update"
    } else {
        foreach ($match in $updateMatches) {
            $updateLine = $match.Groups[1].Value.Trim()
            $update = Parse-DocUpdate -UpdateLine $updateLine
            
            if ($update) {
                $block.DocUpdates += $update
            } else {
                $block.Errors += "Invalid @doc-update format: $updateLine"
            }
        }
    }
    
    # Extract @tests (optional)
    if ($BlockText -match '@tests:\s*(.+)') {
        $block.Tests = $matches[1].Trim()
    }
    
    # Validate
    if ($block.Errors.Count -eq 0) {
        $block.Valid = $true
        $Script:Stats.BlocksValid++
    } else {
        $Script:Stats.Errors++
    }
    
    return $block
}

# === PARSE @DOC-UPDATE LINE ===

function Parse-DocUpdate {
    param([string]$UpdateLine)
    
    # Format: [MARKER] ACTION details
    if ($UpdateLine -match '^\[([^\]]+)\]\s+(ADD|MODIFY|DELETE|MOVE)\s+(.+)$') {
        return @{
            Marker = $matches[1].Trim()
            Action = $matches[2].Trim()
            Details = $matches[3].Trim()
        }
    }
    
    return $null
}

# === VALIDATE @META BLOCK ===

function Test-MetaBlock {
    param($Block)
    
    $valid = $true
    
    # Validate @session format (YYYY-MM-DD-NNN)
    if ($Block.Session -notmatch '^\d{4}-\d{2}-\d{2}-\d{3}$') {
        Write-Warning-Custom "Invalid @session format: $($Block.Session)"
        Write-Warning-Custom "Expected: YYYY-MM-DD-NNN (e.g., 2025-11-15-001)"
        $valid = $false
    }
    
    # Validate @file exists
    if ($Block.File -and !(Test-Path $Block.File)) {
        Write-Warning-Custom "File not found: $($Block.File)"
        $valid = $false
    }
    
    # Validate markers exist in MASTER.md
    if (Test-Path $Script:Config.MasterDoc) {
        $masterContent = Get-Content -Path $Script:Config.MasterDoc -Raw
        
        foreach ($ref in $Block.Refs) {
            if ($masterContent -notmatch "\[$ref\]") {
                Write-Warning-Custom "Marker not found in MASTER.md: [$ref]"
                $valid = $false
            }
        }
        
        foreach ($update in $Block.DocUpdates) {
            if ($masterContent -notmatch "\[$($update.Marker)\]") {
                Write-Warning-Custom "Marker not found in MASTER.md: [$($update.Marker)]"
                $valid = $false
            }
        }
    }
    
    return $valid
}

# === EXECUTE @DOC-UPDATE ===

function Invoke-DocUpdate {
    param($Update, [string]$MasterPath, [bool]$IsDryRun)
    
    if (!(Test-Path $MasterPath)) {
        Write-Error-Custom "MASTER.md not found: $MasterPath"
        return $false
    }
    
    $content = Get-Content -Path $MasterPath -Raw
    $originalContent = $content
    
    # Find marker section
    $markerPattern = "\[$($Update.Marker)\]"
    
    if ($content -notmatch $markerPattern) {
        Write-Error-Custom "Marker not found: [$($Update.Marker)]"
        return $false
    }
    
    switch ($Update.Action) {
        'ADD' {
            $content = Execute-Add -Content $content -Marker $Update.Marker -Details $Update.Details
        }
        'MODIFY' {
            $content = Execute-Modify -Content $content -Marker $Update.Marker -Details $Update.Details
        }
        'DELETE' {
            $content = Execute-Delete -Content $content -Marker $Update.Marker -Details $Update.Details
        }
        'MOVE' {
            $content = Execute-Move -Content $content -Marker $Update.Marker -Details $Update.Details
        }
        default {
            Write-Error-Custom "Unknown action: $($Update.Action)"
            return $false
        }
    }
    
    if ($content -eq $originalContent) {
        Write-Warning-Custom "No changes made for: [$($Update.Marker)] $($Update.Action)"
        return $false
    }
    
    if (!$IsDryRun) {
        Set-Content -Path $MasterPath -Value $content -NoNewline
        Write-Success "Updated [$($Update.Marker)] - $($Update.Action)"
        $Script:Stats.UpdatesExecuted++
    } else {
        Write-Info "DRY RUN: Would update [$($Update.Marker)] - $($Update.Action)"
    }
    
    return $true
}

# === ADD ACTION ===

function Execute-Add {
    param([string]$Content, [string]$Marker, [string]$Details)
    
    # Find the marker section
    $markerPattern = "(\[$Marker\][^\[]*)"
    
    if ($Content -match $markerPattern) {
        $section = $matches[1]
        
        # Find the end of the section (next marker or end of content)
        $nextMarkerPattern = "$section[\s\S]*?(?=\n\[|$)"
        
        if ($Content -match $nextMarkerPattern) {
            $fullSection = $matches[0]
            
            # Add new content before the next marker
            $newSection = $fullSection.TrimEnd() + "`n$Details`n"
            
            $Content = $Content -replace [regex]::Escape($fullSection), $newSection
        }
    }
    
    return $Content
}

# === MODIFY ACTION ===

function Execute-Modify {
    param([string]$Content, [string]$Marker, [string]$Details)
    
    # Format: old_text → new_text
    if ($Details -match '(.+?)\s*→\s*(.+)') {
        $oldText = $matches[1].Trim()
        $newText = $matches[2].Trim()
        
        # Find marker section
        $markerPattern = "\[$Marker\][\s\S]*?(?=\n\[|$)"
        
        if ($Content -match $markerPattern) {
            $section = $matches[0]
            
            if ($section -match [regex]::Escape($oldText)) {
                $newSection = $section -replace [regex]::Escape($oldText), $newText
                $Content = $Content -replace [regex]::Escape($section), $newSection
            } else {
                Write-Warning-Custom "Text not found in section: $oldText"
            }
        }
    }
    
    return $Content
}

# === DELETE ACTION ===

function Execute-Delete {
    param([string]$Content, [string]$Marker, [string]$Details)
    
    # Find marker section
    $markerPattern = "\[$Marker\][\s\S]*?(?=\n\[|$)"
    
    if ($Content -match $markerPattern) {
        $section = $matches[0]
        
        # Remove the specified text
        $escapedDetails = [regex]::Escape($Details)
        
        if ($section -match $escapedDetails) {
            # Remove the line containing the text
            $newSection = $section -replace ".*$escapedDetails.*\n?", ""
            $Content = $Content -replace [regex]::Escape($section), $newSection
        } else {
            Write-Warning-Custom "Text not found in section: $Details"
        }
    }
    
    return $Content
}

# === MOVE ACTION ===

function Execute-Move {
    param([string]$Content, [string]$Marker, [string]$Details)
    
    # Format: content TO [TARGET_MARKER]
    if ($Details -match '(.+?)\s+TO\s+\[([^\]]+)\]') {
        $textToMove = $matches[1].Trim()
        $targetMarker = $matches[2].Trim()
        
        # Delete from source
        $Content = Execute-Delete -Content $Content -Marker $Marker -Details $textToMove
        
        # Add to target
        $Content = Execute-Add -Content $Content -Marker $targetMarker -Details $textToMove
    }
    
    return $Content
}

# === PROCESS FILE ===

function Invoke-ParseFile {
    param([string]$FilePath, [bool]$ValidateOnly, [bool]$IsDryRun)
    
    Write-Info "Processing: $FilePath"
    Write-Log "Processing file: $FilePath" "INFO"
    
    # Validate file
    if (!(Test-SourceFile -FilePath $FilePath)) {
        return $false
    }
    
    # Extract @meta blocks
    $blocks = Get-MetaBlocks -FilePath $FilePath
    
    if ($blocks.Count -eq 0) {
        Write-Warning-Custom "No @meta blocks found in: $FilePath"
        Write-Log "No @meta blocks found in: $FilePath" "WARNING"
        return $false
    }
    
    Write-Info "Found $($blocks.Count) @meta block(s)"
    
    # Process each block
    foreach ($block in $blocks) {
        Write-Host "`n--- @meta Block ---" -ForegroundColor Cyan
        Write-Host "Session: $($block.Session)"
        Write-Host "File: $($block.File)"
        Write-Host "Changes: $($block.Changes)"
        Write-Host "Refs: $($block.Refs -join ', ')"
        Write-Host "Updates: $($block.DocUpdates.Count)"
        
        # Show errors if any
        if ($block.Errors.Count -gt 0) {
            Write-Host "`nValidation Errors:" -ForegroundColor Red
            foreach ($error in $block.Errors) {
                Write-Error-Custom "  $error"
            }
            continue
        }
        
        # Validate block
        if (!(Test-MetaBlock -Block $block)) {
            Write-Warning-Custom "Block validation failed"
            continue
        }
        
        if ($ValidateOnly) {
            Write-Success "Block is valid ✓"
            continue
        }
        
        # Execute updates
        Write-Host "`nExecuting updates..." -ForegroundColor Cyan
        
        foreach ($update in $block.DocUpdates) {
            Write-Info "[$($update.Marker)] $($update.Action) $($update.Details)"
            
            $success = Invoke-DocUpdate -Update $update -MasterPath $Script:Config.MasterDoc -IsDryRun $IsDryRun
            
            if (!$success) {
                Write-Warning-Custom "Update failed"
                $Script:Stats.Errors++
            }
        }
        
        # Add changelog entry (if not dry run)
        if (!$IsDryRun -and !$ValidateOnly) {
            Add-ChangelogEntry -Block $block
        }
    }
    
    return $true
}

# === ADD CHANGELOG ENTRY ===

function Add-ChangelogEntry {
    param($Block)
    
    if (!(Test-Path $Script:Config.ContextDoc)) {
        Write-Warning-Custom "CONTEXT.md not found, skipping changelog"
        return
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $entry = @"

### $timestamp - Auto-update
**Session:** $($Block.Session)
**File:** $($Block.File)
**Changes:** $($Block.Changes)
**Updates:**
"@
    
    foreach ($update in $Block.DocUpdates) {
        $entry += "`n- [$($update.Marker)] $($update.Action) $($update.Details)"
    }
    
    # Append to CONTEXT.md
    Add-Content -Path $Script:Config.ContextDoc -Value $entry
    Write-Success "Changelog entry added"
}

# === CALL UPDATE_DOCS.PS1 ===

function Invoke-UpdateDocs {
    if (!(Test-Path $Script:Config.UpdateScript)) {
        Write-Warning-Custom "update_docs.ps1 not found, skipping version bump"
        return
    }
    
    Write-Info "Calling update_docs.ps1..."
    
    try {
        & ".\$($Script:Config.UpdateScript)" -Update
        Write-Success "Documentation versioned"
    } catch {
        Write-Error-Custom "Failed to call update_docs.ps1: $_"
    }
}

# === SHOW STATISTICS ===

function Show-Statistics {
    Write-Host "`n=== Parser Statistics ===" -ForegroundColor Cyan
    Write-Host "Blocks found:    $($Script:Stats.BlocksFound)"
    Write-Host "Blocks valid:    $($Script:Stats.BlocksValid)"
    Write-Host "Updates executed: $($Script:Stats.UpdatesExecuted)"
    Write-Host "Errors:          $($Script:Stats.Errors)"
    
    if ($Script:Stats.Errors -eq 0 -and $Script:Stats.UpdatesExecuted -gt 0) {
        Write-Success "`nAll updates completed successfully!"
    } elseif ($Script:Stats.Errors -gt 0) {
        Write-Warning-Custom "`nSome updates failed. Check logs for details."
    }
}

# === MAIN EXECUTION ===

function Main {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   METADATA PROTOCOL PARSER v1.0.0      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Initialize log
    Write-Log "=== Parser session started ===" "INFO"
    Write-Log "File: $File" "INFO"
    Write-Log "Validate: $Validate" "INFO"
    Write-Log "DryRun: $DryRun" "INFO"
    
    # Process file
    $success = Invoke-ParseFile -FilePath $File -ValidateOnly:$Validate -IsDryRun:$DryRun
    
    if ($success -and !$Validate -and !$DryRun -and $Script:Stats.UpdatesExecuted -gt 0) {
        # Call update_docs.ps1 to version
        Invoke-UpdateDocs
    }
    
    # Show statistics
    Show-Statistics
    
    Write-Log "=== Parser session ended ===" "INFO"
    Write-Host ""
}

# === RUN ===

Main
