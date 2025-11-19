# verify_registry.ps1
# Version: 1.0.0
# Purpose: Automatically detect orphan files not in FILE_REGISTRY.md
# Usage: .\verify_registry.ps1
# Location: docs/

# ACTIVE FILES (from FILE_REGISTRY.md)
$active = @(
    "00_INDEX.md",
    "01_MASTER_DOC_v2.1.15.md",
    "03_PROMPTS_v2.3.md",
    "06_METADATA_PROTOCOL.md",
    "10_MIGRATION_2025-11-16.md",
    "FILE_REGISTRY.md",
    "11_AUTO_VERSIONING_SYSTEM.md",
    "README_AUTO_VERSIONING.md",
    "POWERSHELL_STANDARDS.md",
    "TEST_NOTE_EXAMPLE.md",
    "FULL_PROCESS_REVIEW_2025-11-16.md",
    "ACTION_PLAN_2025-11-16.md",
    "PARSER_USAGE_GUIDE.md",
    "ENCODING_GUIDE.md",        # AGREGAR
    "ENCODING_QUICKFIX.md",     # AGREGAR
    "08_PARSER.ps1",
    "07_WATCHER.ps1",
    "update_docs.ps1",
    "cleanup_docs.ps1",
    "fix_encoding.ps1",
    "regenerate_scripts.ps1",
    "verify_registry.ps1"
)

# SYSTEM FILES (keep but not tracked in ACTIVE)
$system = @(
    "meta.json"
)

# TEMPORARY PATTERNS (keep during session, delete after)
$tempPatterns = @(
    "cleanup_old_versions.ps1",
    "*_DELIVERY_*.md"
)

# DEPRECATED FILES (should be deleted)
$deprecated = @(
    "01_MASTER_DOC.md",
    "03_PROMPTS.md",
    "02_CONTEXT.md",
    "04_SESSION_START.md",
    "05_CONTEXT_MONITOR.md",
    "09_MIGRATION_TO_NEW_SESSION.md",
    "10_MIGRATION_NEXT_SESSION.md",
    "10_MIGRATION_NEXT_SESSION_FINAL.md",
    "AUTO_VERSIONING_SYSTEM.md",
    "FINAL_DELIVERY_2025-11-16.md"
)

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  FILE REGISTRY VERIFICATION v1.0.0   " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking files in: $PWD" -ForegroundColor Gray
Write-Host ""

# Get all files
$allFiles = Get-ChildItem -File | Where-Object { 
    $_.Name -ne "verify_registry.ps1"
}

# Categorize files
$orphans = @()
$temporaryFiles = @()
$deprecatedFound = @()
$activeCount = 0
$systemCount = 0

foreach ($file in $allFiles) {
    $fileName = $file.Name
    
    # Check if DEPRECATED
    if ($fileName -in $deprecated) {
        $deprecatedFound += [PSCustomObject]@{
            Name = $fileName
            Size = "{0:N2} KB" -f ($file.Length / 1KB)
            Modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            Action = "DELETE NOW"
        }
        continue
    }
    
    # Check if ACTIVE
    if ($fileName -in $active) {
        $activeCount++
        continue
    }
    
    # Check if SYSTEM
    if ($fileName -in $system) {
        $systemCount++
        continue
    }
    
    # Check if TEMPORARY
    $isTemp = $false
    foreach ($pattern in $tempPatterns) {
        if ($fileName -like $pattern) {
            $isTemp = $true
            $temporaryFiles += [PSCustomObject]@{
                Name = $fileName
                Size = "{0:N2} KB" -f ($file.Length / 1KB)
                Modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                Action = "DELETE AFTER SESSION"
            }
            break
        }
    }
    
    # If not in any category, it's an ORPHAN
    if (-not $isTemp) {
        $orphans += [PSCustomObject]@{
            Name = $fileName
            Size = "{0:N2} KB" -f ($file.Length / 1KB)
            Modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            Action = "ADD TO REGISTRY OR DELETE"
        }
    }
}

# DISPLAY SUMMARY
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[OK] ACTIVE files:     $activeCount" -ForegroundColor Green
Write-Host "[OK] SYSTEM files:     $systemCount" -ForegroundColor Green
Write-Host "[!!] TEMPORARY files:  $($temporaryFiles.Count)" -ForegroundColor Yellow
Write-Host "[XX] DEPRECATED found: $($deprecatedFound.Count)" -ForegroundColor Red
Write-Host "[??] ORPHAN files:     $($orphans.Count)" -ForegroundColor Magenta
Write-Host ""

# SHOW DEPRECATED FILES
if ($deprecatedFound.Count -gt 0) {
    Write-Host "=======================================" -ForegroundColor Red
    Write-Host "DEPRECATED FILES (Delete immediately)" -ForegroundColor Red
    Write-Host "=======================================" -ForegroundColor Red
    Write-Host ""
    
    $deprecatedFound | Format-Table -AutoSize
    
    Write-Host "These files are marked as DEPRECATED in FILE_REGISTRY.md" -ForegroundColor Red
    Write-Host "Safe to delete now." -ForegroundColor Gray
    Write-Host ""
}

# SHOW ORPHAN FILES
if ($orphans.Count -gt 0) {
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host "ORPHAN FILES (Not in registry)" -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host ""
    
    $orphans | Format-Table -AutoSize
    
    Write-Host "These files are NOT in FILE_REGISTRY.md" -ForegroundColor Yellow
    Write-Host "Actions:" -ForegroundColor Gray
    Write-Host "  1. If recently created -> Add to ACTIVE section" -ForegroundColor Gray
    Write-Host "  2. If old/unknown -> Safe to delete" -ForegroundColor Gray
    Write-Host ""
}

# SHOW TEMPORARY FILES
if ($temporaryFiles.Count -gt 0) {
    Write-Host "=======================================" -ForegroundColor Yellow
    Write-Host "TEMPORARY FILES (Delete after session)" -ForegroundColor Yellow
    Write-Host "=======================================" -ForegroundColor Yellow
    Write-Host ""
    
    $temporaryFiles | Format-Table -AutoSize
    
    Write-Host "These are temporary session files" -ForegroundColor Gray
    Write-Host "Delete at end of session." -ForegroundColor Gray
    Write-Host ""
}

# CHECK FOLDERS
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "FOLDER CHECK" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$folders = Get-ChildItem -Directory
if ($folders) {
    foreach ($folder in $folders) {
        if ($folder.Name -in @("backups", "logs")) {
            Write-Host "  [OK] $($folder.Name)/ - System folder (OK)" -ForegroundColor Green
        } else {
            Write-Host "  [??] $($folder.Name)/ - Not in registry" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  [--] No folders found" -ForegroundColor Gray
}

Write-Host ""

# FINAL STATUS
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "STATUS" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$issuesFound = $deprecatedFound.Count + $orphans.Count

if ($issuesFound -eq 0) {
    Write-Host "[OK] ALL CLEAR!" -ForegroundColor Green
    Write-Host "All files are properly registered." -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "[!!] ISSUES FOUND: $issuesFound" -ForegroundColor Yellow
    Write-Host ""
    
    if ($deprecatedFound.Count -gt 0) {
        Write-Host "  - $($deprecatedFound.Count) deprecated file(s) to delete" -ForegroundColor Red
    }
    
    if ($orphans.Count -gt 0) {
        Write-Host "  - $($orphans.Count) orphan file(s) to review" -ForegroundColor Magenta
    }
    
    Write-Host ""
    Write-Host "Recommended actions:" -ForegroundColor Yellow
    Write-Host "  1. Delete deprecated files (marked [XX])" -ForegroundColor Gray
    Write-Host "  2. Review orphan files (marked [??])" -ForegroundColor Gray
    Write-Host "  3. Add to FILE_REGISTRY.md or delete" -ForegroundColor Gray
    Write-Host "  4. Run this script again to verify" -ForegroundColor Gray
    Write-Host ""
}

# QUICK COMMANDS
if ($issuesFound -gt 0) {
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "QUICK COMMANDS" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ($deprecatedFound.Count -gt 0) {
        Write-Host "Delete deprecated files:" -ForegroundColor Yellow
        foreach ($file in $deprecatedFound) {
            Write-Host "  Remove-Item `"$($file.Name)`" -Force" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    if ($orphans.Count -gt 0) {
        Write-Host "To delete orphan files (if safe):" -ForegroundColor Yellow
        foreach ($file in $orphans) {
            Write-Host "  Remove-Item `"$($file.Name)`" -Force" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Run .\verify_registry.ps1 anytime" -ForegroundColor Gray
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
