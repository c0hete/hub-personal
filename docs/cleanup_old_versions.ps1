# AUTO-GENERATED: Clean old versions
# Date: 2025-11-16
# Session: Notes CRUD complete
# Based on FILE_REGISTRY.md DEPRECATED section

Write-Host "`n=== CLEANUP OLD VERSIONS ===" -ForegroundColor Cyan
Write-Host "Removing deprecated files...`n" -ForegroundColor Yellow

$oldFiles = @(
    "09_MIGRATION_TO_NEW_SESSION.md",
    "10_MIGRATION_NEXT_SESSION.md",
    "AUTO_VERSIONING_SYSTEM.md",
    "docs",
    "01_MASTER_DOC.md",
    "03_PROMPTS.md"
)

$deletedCount = 0
$notFoundCount = 0

foreach ($file in $oldFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "[DELETED] $file" -ForegroundColor Red
        $deletedCount++
    } else {
        Write-Host "[NOT FOUND] $file (already removed)" -ForegroundColor DarkGray
        $notFoundCount++
    }
}

Write-Host "`n=== CLEANUP SUMMARY ===" -ForegroundColor Cyan
Write-Host "Deleted: $deletedCount files" -ForegroundColor Red
Write-Host "Not found: $notFoundCount files" -ForegroundColor DarkGray

Write-Host "`n[OK] Cleanup complete!" -ForegroundColor Green
Write-Host "Current files now match FILE_REGISTRY.md ACTIVE section" -ForegroundColor Green

Write-Host "`nCurrent versioned files:" -ForegroundColor Cyan
Get-ChildItem -Filter "*_v*.md" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}

Get-ChildItem -Filter "10_MIGRATION_*.md" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
