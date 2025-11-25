# cleanup_obsolete_docs.ps1
# Version: 1.0.0
# ENCODING: Run .\fix_encoding.ps1 -File "cleanup_obsolete_docs.ps1" before use
# Purpose: Clean obsolete documentation files

Write-Host "Starting cleanup of obsolete documentation files..." -ForegroundColor Cyan

$obsoleteFiles = @(
    "01_MASTER_DOC.md",  # Sin version
    "ACTION_PLAN_2025-11-16.md",
    "ENCODING_GUIDE.md",
    "ENCODING_QUICKFIX.md",
    "FULL_PROCESS_REVIEW_2025-11-16.md",
    "META_TAG_STANDARD.md",
    "PARSER_USAGE_GUIDE.md",
    "SESSION_CONTEXT.md",
    "package-updates.js",
    "verify_registry.ps1"
)

$kept = @(
    "README_AUTO_VERSIONING.md",  # Util para referencia
    "TEST_NOTE_EXAMPLE.md",       # Ejemplos de meta tags
    "POWERSHELL_STANDARDS.md",    # Standards necesarios
    "11_AUTO_VERSIONING_SYSTEM.md" # Sistema de versionado
)

Write-Host "`nFiles to DELETE:" -ForegroundColor Yellow
foreach ($file in $obsoleteFiles) {
    if (Test-Path $file) {
        Write-Host "  - $file" -ForegroundColor Red
    }
}

Write-Host "`nFiles to KEEP:" -ForegroundColor Green
foreach ($file in $kept) {
    if (Test-Path $file) {
        Write-Host "  + $file" -ForegroundColor Green
    }
}

Write-Host "`n"
$confirm = Read-Host "Delete obsolete files? (Y/N)"

if ($confirm -eq 'Y' -or $confirm -eq 'y') {
    $deleted = 0
    foreach ($file in $obsoleteFiles) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "Deleted: $file" -ForegroundColor Red
            $deleted++
        }
    }
    Write-Host "`nDeleted $deleted files." -ForegroundColor Green
    Write-Host "`nFinal structure (should be ~15 files):" -ForegroundColor Cyan
    Get-ChildItem -File | Select-Object Name, Length | Format-Table -AutoSize
} else {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
}
