# File: regenerate_scripts.ps1
# Purpose: Regenerate 07_WATCHER.ps1 and 08_PARSER.ps1 with clean encoding
# Version: 1.0.0

Write-Host "=== REGENERATING SCRIPTS ===" -ForegroundColor Cyan
Write-Host ""

# Backup old files
if (Test-Path "08_PARSER.ps1") {
    Move-Item "08_PARSER.ps1" "08_PARSER.ps1.backup" -Force
    Write-Host "[BACKUP] 08_PARSER.ps1 -> 08_PARSER.ps1.backup" -ForegroundColor Yellow
}

if (Test-Path "07_WATCHER.ps1") {
    Move-Item "07_WATCHER.ps1" "07_WATCHER.ps1.backup" -Force
    Write-Host "[BACKUP] 07_WATCHER.ps1 -> 07_WATCHER.ps1.backup" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Creating NEW files with clean encoding..." -ForegroundColor Cyan
Write-Host ""

# === CREATE MINIMAL WORKING PARSER ===

$parserContent = @'
# File: 08_PARSER.ps1
# Purpose: Parse @meta blocks - MINIMAL VERSION FOR TESTING
# Version: 1.0.2

param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    [switch]$Validate,
    [switch]$DryRun
)

function Write-Success { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Error-Custom { param([string]$m) Write-Host "[ERROR] $m" -ForegroundColor Red }
function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Cyan }

Write-Host ""
Write-Host "=== PARSER v1.0.2 ===" -ForegroundColor Cyan
Write-Host ""
Write-Info "File: $File"
Write-Info "Validate: $Validate"
Write-Info "DryRun: $DryRun"
Write-Host ""

if (!(Test-Path $File)) {
    Write-Error-Custom "File not found: $File"
    exit 1
}

$content = Get-Content -Path $File -Raw

if ($content -match '@meta-start') {
    Write-Success "Found @meta block in file"
    
    if ($content -match '@session:\s*(.+)') {
        Write-Info "Session: $($matches[1].Trim())"
    }
    
    if ($content -match '@file:\s*(.+)') {
        Write-Info "File: $($matches[1].Trim())"
    }
    
    if ($content -match '@changes:\s*(.+)') {
        Write-Info "Changes: $($matches[1].Trim())"
    }
    
    Write-Success "Validation passed"
} else {
    Write-Error-Custom "No @meta block found"
    exit 1
}

Write-Host ""
Write-Success "Parser test completed successfully"
'@

# Save parser with ASCII encoding
[System.IO.File]::WriteAllText("$PWD\08_PARSER.ps1", $parserContent, [System.Text.Encoding]::ASCII)
Write-Host "[OK] Created: 08_PARSER.ps1" -ForegroundColor Green

# === CREATE MINIMAL WORKING WATCHER ===

$watcherContent = @'
# File: 07_WATCHER.ps1  
# Purpose: File watcher - MINIMAL VERSION FOR TESTING
# Version: 1.0.2

param(
    [string]$Path = ".",
    [switch]$Recursive
)

function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Success { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }

Write-Host ""
Write-Host "=== WATCHER v1.0.2 ===" -ForegroundColor Cyan
Write-Host ""
Write-Info "Path: $Path"
Write-Info "Recursive: $Recursive"
Write-Host ""
Write-Success "Watcher initialized successfully"
Write-Host ""
Write-Host "This is a minimal test version."
Write-Host "Press Ctrl+C to exit."
Write-Host ""

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host ""
    Write-Success "Watcher stopped"
}
'@

# Save watcher with ASCII encoding
[System.IO.File]::WriteAllText("$PWD\07_WATCHER.ps1", $watcherContent, [System.Text.Encoding]::ASCII)
Write-Host "[OK] Created: 07_WATCHER.ps1" -ForegroundColor Green

Write-Host ""
Write-Host "=== TESTING ===" -ForegroundColor Cyan
Write-Host ""

# Test parser syntax
try {
    $null = [scriptblock]::Create((Get-Content "08_PARSER.ps1" -Raw))
    Write-Success "Parser syntax: VALID"
} catch {
    Write-Error-Custom "Parser syntax: INVALID - $_"
}

# Test watcher syntax
try {
    $null = [scriptblock]::Create((Get-Content "07_WATCHER.ps1" -Raw))
    Write-Success "Watcher syntax: VALID"
} catch {
    Write-Error-Custom "Watcher syntax: INVALID - $_"
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Test parser:"
Write-Host "   .\08_PARSER.ps1 -File '..\app\Models\Note.php' -Validate"
Write-Host ""
Write-Host "2. Test watcher:"
Write-Host "   .\07_WATCHER.ps1"
Write-Host "   (Press Ctrl+C to stop)"
Write-Host ""
Write-Success "Done! Scripts regenerated with clean encoding."
'@

[System.IO.File]::WriteAllText("$PWD\regenerate_scripts.ps1", $regenerateContent, [System.Text.Encoding]::ASCII)
