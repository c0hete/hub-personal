# File: fix_encoding.ps1
# Purpose: Fix smart quotes and encoding issues in PowerShell scripts
# Version: 1.0.0

Write-Host "=== ENCODING FIXER ===" -ForegroundColor Cyan
Write-Host ""

$files = @(
    "07_WATCHER.ps1",
    "08_PARSER.ps1"
)

$replacements = @{
    # Smart double quotes
    "`u201C" = '"'  # Left double quote
    "`u201D" = '"'  # Right double quote
    # Smart single quotes
    "`u2018" = "'"  # Left single quote
    "`u2019" = "'"  # Right single quote
    # Unicode arrows
    "`u2192" = "->" # Right arrow
    "`u21D2" = "=>" # Double arrow
    # Other Unicode
    "`u2022" = "-"  # Bullet point
}

foreach ($file in $files) {
    if (!(Test-Path $file)) {
        Write-Host "[SKIP] File not found: $file" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "[FIX] Processing: $file" -ForegroundColor Cyan
    
    # Read content
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    
    # Apply replacements
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        $content = $content -replace $old, $new
    }
    
    # Additional regex replacements for any remaining smart quotes
    $content = $content -replace '[\u201C\u201D]', '"'
    $content = $content -replace '[\u2018\u2019]', "'"
    $content = $content -replace '\u2192', '->'
    
    # Save with UTF-8 encoding (no BOM)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
    
    Write-Host "[OK] Fixed: $file" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== VERIFICATION ===" -ForegroundColor Cyan

foreach ($file in $files) {
    if (!(Test-Path $file)) { continue }
    
    $content = Get-Content -Path $file -Raw
    $hasSmartQuotes = $content -match '[\u201C\u201D\u2018\u2019]'
    
    if ($hasSmartQuotes) {
        Write-Host "[ERROR] Still has smart quotes: $file" -ForegroundColor Red
    } else {
        Write-Host "[OK] Clean: $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Done! Try running the scripts now." -ForegroundColor Green
