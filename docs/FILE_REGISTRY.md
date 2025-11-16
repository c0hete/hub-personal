# FILE REGISTRY - HubPersonal Documentation

**Version:** 2.0.0 (Hybrid Approach)  
**Purpose:** Single source of truth for current valid documentation files  
**Golden Rule:** If NOT in this file = Should be deleted (see exceptions below)  
**Last Update:** 2025-11-16 16:30

---

## [ACTIVE:FILES]

### Core Documentation (Always Required)

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 00_INDEX.md | Current | ACTIVE | Navigation master | docs/ |
| 01_MASTER_DOC_v2.1.15.md | 2.1.15 | ACTIVE | Complete technical docs | docs/ |
| 03_PROMPTS_v2.3.md | 2.3 | ACTIVE | Agent behavior rules | docs/ |
| 06_METADATA_PROTOCOL.md | 1.0.0 | ACTIVE | @meta block specification | docs/ |

### Session Management

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 10_MIGRATION_2025-11-16.md | 2025-11-16 | ACTIVE | Session: Notes CRUD complete | docs/ |
| FILE_REGISTRY.md | 2.0.0 | ACTIVE | This file (version tracker) | docs/ |

### Supporting Documentation

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 11_AUTO_VERSIONING_SYSTEM.md | 1.0 | ACTIVE | Auto-versioning docs | docs/ |
| README_AUTO_VERSIONING.md | 1.0 | ACTIVE | Quick guide | docs/ |
| POWERSHELL_STANDARDS.md | 1.0 | ACTIVE | Encoding rules | docs/ |
| TEST_NOTE_EXAMPLE.md | 1.0 | ACTIVE | @meta examples | docs/ |
| FULL_PROCESS_REVIEW_2025-11-16.md | 1.0 | ACTIVE | System review & analysis | docs/ |
| ACTION_PLAN_2025-11-16.md | 1.0 | ACTIVE | Quick action items | docs/ |
| ENCODING_GUIDE.md | 1.0 | ACTIVE | PowerShell encoding reference | docs/ |
| ENCODING_QUICKFIX.md | 1.0 | ACTIVE | Quick encoding fix guide | docs/ |

### Scripts (Working)

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 08_PARSER.ps1 | 1.2 | ACTIVE | Parse @meta blocks | docs/ |
| update_docs.ps1 | 1.2 | ACTIVE | Version bumper | docs/ |
| cleanup_docs.ps1 | 1.0 | ACTIVE | Clean old files | docs/ |
| fix_encoding.ps1 | 1.0 | ACTIVE | Fix PowerShell encoding | docs/ |
| regenerate_scripts.ps1 | 1.0 | ACTIVE | Regenerate scripts | docs/ |
| verify_registry.ps1 | 1.0 | ACTIVE | Check orphan files | docs/ |

### Scripts (Experimental/Broken)

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 07_WATCHER.ps1 | 1.0 | BROKEN | Auto-detect file changes | docs/ |

---

## [DEPRECATED:FILES]

**Rule:** These files should be DELETED if found

| File | Replaced By | Date Deprecated | Reason |
|------|-------------|-----------------|--------|
| 01_MASTER_DOC.md | 01_MASTER_DOC_v2.1.15.md | 2025-11-16 | Versionado en nombre |
| 03_PROMPTS.md | 03_PROMPTS_v2.3.md | 2025-11-16 | Versionado en nombre |
| 02_CONTEXT.md | N/A | 2025-11-16 | Replaced by MASTER.md sections |
| 04_SESSION_START.md | 10_MIGRATION_*.md | 2025-11-16 | Use migration files instead |
| 05_CONTEXT_MONITOR.md | N/A | 2025-11-16 | Not used |
| 09_MIGRATION_TO_NEW_SESSION.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Outdated |
| 10_MIGRATION_NEXT_SESSION.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Incomplete |
| 10_MIGRATION_NEXT_SESSION_FINAL.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Renamed with date |
| AUTO_VERSIONING_SYSTEM.md | 11_AUTO_VERSIONING_SYSTEM.md | 2025-11-16 | No number prefix |
| FINAL_DELIVERY_2025-11-16.md | N/A | 2025-11-16 | Temporary file |
| docs (file) | N/A | 2025-11-16 | Malformed file |
| docs/scripts/ (folder) | N/A | 2025-11-16 | Duplicates in docs/ |

---

## [SYSTEM:FILES]

**Files and folders used by automation (NOT in ACTIVE but keep):**

### Always Keep

| File/Folder | Type | Purpose | Action |
|-------------|------|---------|--------|
| meta.json | System | Version tracking for automation | ✅ KEEP |
| backups/ | Folder | Automatic backups from parser | ✅ KEEP |
| logs/ | Folder | Parser execution logs | ✅ KEEP |

### Temporary (Delete After Session)

| Pattern | Example | When to Delete | Why |
|---------|---------|----------------|-----|
| cleanup_old_versions.ps1 | cleanup_old_versions.ps1 | End of session | Generated each session |
| *_DELIVERY_*.md | FINAL_DELIVERY_2025-11-16.md | After processed | Session instructions only |

---

## [GOLDEN_RULE]

### Decision Tree for ANY file

```
┌─────────────────────────────────────┐
│ Found a file in docs/ folder?      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Is it in [ACTIVE:FILES] section?   │
└──────────────┬──────────────────────┘
               │
         YES ──┴── ✅ KEEP (it's documented)
               │
         NO ───┴─▶ Continue checking...
                   │
                   ▼
┌─────────────────────────────────────┐
│ Is it in [SYSTEM:FILES] section?   │
└──────────────┬──────────────────────┘
               │
         YES ──┴── ✅ KEEP (system needs it)
               │
         NO ───┴─▶ Continue checking...
                   │
                   ▼
┌─────────────────────────────────────┐
│ Is it temporary? (matches pattern) │
│ - cleanup_old_versions.ps1          │
│ - *_DELIVERY_*.md                   │
└──────────────┬──────────────────────┘
               │
         YES ──┴── ⏰ DELETE AFTER SESSION
               │
         NO ───┴─▶ Continue checking...
                   │
                   ▼
┌─────────────────────────────────────┐
│ Is it in [DEPRECATED:FILES]?       │
└──────────────┬──────────────────────┘
               │
         YES ──┴── ❌ DELETE IMMEDIATELY
               │
         NO ───┴─▶ ❌ ORPHAN FILE - DELETE
```

### Quick Reference

| Scenario | Action |
|----------|--------|
| ✅ In ACTIVE section | Keep |
| ✅ In SYSTEM section | Keep |
| ⏰ Matches temporary pattern | Delete after session |
| ❌ In DEPRECATED section | Delete now |
| ❌ Not in any section | Delete now (orphan) |

---

## [AUTOMATION]

### Verification Script

**File:** `verify_registry.ps1`  
**Purpose:** Automatically detect orphan files

```powershell
# verify_registry.ps1
# Run: .\verify_registry.ps1
# Output: List of files not in registry (safe to delete)

# ACTIVE FILES (from registry above)
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
    "08_PARSER.ps1",
    "07_WATCHER.ps1",
    "update_docs.ps1",
    "cleanup_docs.ps1",
    "fix_encoding.ps1",
    "regenerate_scripts.ps1",
    "verify_registry.ps1"
)

# SYSTEM FILES (keep but not tracked)
$system = @(
    "meta.json"
)

# TEMPORARY PATTERNS (keep during session)
$tempPatterns = @(
    "cleanup_old_versions.ps1",
    "*_DELIVERY_*.md"
)

Write-Host "`n=== FILE REGISTRY VERIFICATION ===" -ForegroundColor Cyan
Write-Host "Checking for orphan files...`n" -ForegroundColor Gray

# Get all files
$allFiles = Get-ChildItem -File | Where-Object { 
    $_.Name -ne "verify_registry.ps1"  # Exclude this script
}

# Check each file
$orphans = @()
foreach ($file in $allFiles) {
    $fileName = $file.Name
    
    # Check if in ACTIVE
    $isActive = $fileName -in $active
    
    # Check if in SYSTEM
    $isSystem = $fileName -in $system
    
    # Check if matches temporary pattern
    $isTemp = $false
    foreach ($pattern in $tempPatterns) {
        if ($fileName -like $pattern) {
            $isTemp = $true
            break
        }
    }
    
    # If not in any category, it's an orphan
    if (-not ($isActive -or $isSystem -or $isTemp)) {
        $orphans += [PSCustomObject]@{
            Name = $fileName
            Size = "{0:N2} KB" -f ($file.Length / 1KB)
            Modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
        }
    }
}

# Display results
if ($orphans.Count -eq 0) {
    Write-Host "✅ No orphan files found!" -ForegroundColor Green
    Write-Host "All files are properly registered.`n" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Found $($orphans.Count) orphan file(s):" -ForegroundColor Yellow
    $orphans | Format-Table -AutoSize
    
    Write-Host "`nThese files are NOT in FILE_REGISTRY.md" -ForegroundColor Yellow
    Write-Host "Safe to delete unless recently created.`n" -ForegroundColor Gray
}

# Check for folders
Write-Host "=== FOLDER CHECK ===" -ForegroundColor Cyan
$folders = Get-ChildItem -Directory
if ($folders) {
    Write-Host "Folders found:" -ForegroundColor Gray
    foreach ($folder in $folders) {
        if ($folder.Name -in @("backups", "logs")) {
            Write-Host "  ✅ $($folder.Name)/ - System folder (OK)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $($folder.Name)/ - Not in registry" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No folders found." -ForegroundColor Gray
}

Write-Host ""
```

**Usage:**
```powershell
# Run verification
cd C:\Users\JoseA\Projects\hub-personal\docs
.\verify_registry.ps1

# Output shows:
# ✅ Files that are OK
# ⚠️  Orphan files (safe to delete)
```

---

## [MAINTENANCE:CHECKLIST]

### Before ending each session:

```
☐ Run verify_registry.ps1 to check for orphans
☐ Delete orphan files found (if any)
☐ Delete temporary files (cleanup_*, *_DELIVERY_*)
☐ Update FILE_REGISTRY.md if added/removed files
☐ Commit FILE_REGISTRY changes
☐ Verify Claude Project has current files
```

### Before starting new session:

```
☐ Check FILE_REGISTRY.md for active files
☐ Delete any deprecated files found
☐ Upload current files to Claude Project
☐ Paste migration file content as context
☐ Run verify_registry.ps1 to confirm clean state
```

### Weekly (During Active Development):

```
☐ Review FILE_REGISTRY accuracy
☐ Check for orphaned files (verify_registry.ps1)
☐ Validate parser logs in logs/ folder
☐ Review recent commits
☐ Clean old backups (>7 days)
```

### Monthly:

```
☐ Full documentation review
☐ Update dependencies list if changed
☐ Check marker consistency in MASTER.md
☐ Archive old sessions (if needed)
☐ Update README if workflow changed
☐ Review and update this registry structure
```

---

## [CLAUDE:PROJECT_FILES]

**Files that MUST be in Claude Project for context:**

### Required (Always - Upload Every Session)
1. 00_INDEX.md
2. 01_MASTER_DOC_v2.1.15.md (current version)
3. 03_PROMPTS_v2.3.md (current version)
4. 06_METADATA_PROTOCOL.md
5. FILE_REGISTRY.md (always latest)

### Session Specific (Update per session)
6. 10_MIGRATION_2025-11-16.md (current session)

### Optional (Nice to have)
- 11_AUTO_VERSIONING_SYSTEM.md
- FULL_PROCESS_REVIEW_2025-11-16.md

---

## [WORKFLOW:FILE_UPDATES]

### When creating new documentation file:

```powershell
# 1. Create file
New-Item "docs/12_NEW_FEATURE.md"

# 2. Add to FILE_REGISTRY.md:
#    - Add to appropriate section in [ACTIVE:FILES]
#    - Update version
#    - Add purpose

# 3. Run verification
.\verify_registry.ps1

# 4. Commit
git add docs/FILE_REGISTRY.md docs/12_NEW_FEATURE.md
git commit -m "docs: Add new feature documentation"
```

### When deprecating a file:

```powershell
# 1. Move from [ACTIVE:FILES] to [DEPRECATED:FILES]
# 2. Add deprecation date
# 3. Add reason
# 4. Note replacement (if any)

# 5. Delete actual file
Remove-Item "docs/OLD_FILE.md"

# 6. Commit
git add docs/FILE_REGISTRY.md
git add -u  # Stages deletion
git commit -m "docs: Deprecate OLD_FILE.md"
```

### When creating new migration file:

```powershell
# 1. Create with date in content, not filename
New-Item "docs/10_MIGRATION_NEXT_SESSION.md"

# 2. In FILE_REGISTRY.md:
#    - Move old migration to DEPRECATED
#    - Add new migration to ACTIVE

# 3. Delete old migration file
Remove-Item "docs/10_MIGRATION_OLD.md"

# 4. Commit
git add docs/FILE_REGISTRY.md docs/10_MIGRATION_*.md
git commit -m "docs: Update migration file for new session"
```

---

## [RULES:FILE_NAMING]

### Documentation files:
```
Format: ##_DESCRIPTIVE_NAME_v#_#_#.md

Examples:
- 00_INDEX.md (no version, always current)
- 01_MASTER_DOC_v2.1.15.md (version in filename)
- 03_PROMPTS_v2.3.md (version in filename)

Version tracking: In filename for major docs
```

### Migration files:
```
Format: 10_MIGRATION_YYYY-MM-DD.md

Examples:
- 10_MIGRATION_2025-11-16.md (current)
- 10_MIGRATION_2025-11-20.md (next)

ALWAYS include date in filename
DELETE previous migration when creating new
```

### Script files:
```
Format: ##_script_name.ps1 or script_name.ps1

Examples:
- 08_PARSER.ps1 (numbered, core)
- update_docs.ps1 (no number, utility)
- verify_registry.ps1 (no number, utility)

Version: Inside file header as comment
```

### System files:
```
Format: lowercase_with_underscores.ext

Examples:
- meta.json
- cleanup_old_versions.ps1

No version numbers (system managed)
```

---

## [BENEFITS:HYBRID_APPROACH]

### Why This System Works:

1. **Crystal Clear Rules**
   - Every file has a category
   - Decision tree eliminates confusion
   - No guessing about what to keep

2. **Automated Verification**
   - verify_registry.ps1 does the work
   - Run anytime, get instant status
   - No manual checking needed

3. **Explicit Exceptions**
   - System files documented
   - Temporary patterns defined
   - Nothing is implicit

4. **Easy Maintenance**
   - Add new file → Update ACTIVE section
   - Run verify → Confirms it's tracked
   - Delete safe → Script identifies orphans

5. **Scalable**
   - Works with 20 files or 200
   - Script handles complexity
   - Registry stays organized

6. **Future-Proof**
   - Easy to add new sections
   - Patterns accommodate growth
   - Automation prevents errors

---

## [VERSION:HISTORY]

### v2.0.0 - 2025-11-16 (HYBRID APPROACH)
**Major update:**
- Added [SYSTEM:FILES] section for exceptions
- Added [GOLDEN_RULE] decision tree
- Added [AUTOMATION] with verify_registry.ps1
- Added [BENEFITS:HYBRID_APPROACH] explanation
- Moved from simple list to comprehensive system
- Added FULL_PROCESS_REVIEW and ACTION_PLAN
- Enhanced maintenance checklists
- Improved workflows and examples

### v1.0.0 - 2025-11-16
- Initial creation
- Documented current state after Notes CRUD completion
- Established file naming rules
- Created maintenance checklist

---

## [NOTES:USAGE]

### For José:

**Daily use:**
1. Create/modify files normally
2. Run `.\verify_registry.ps1` when unsure
3. Update ACTIVE section when adding files
4. Check DEPRECATED section before deleting

**When confused about a file:**
1. Check ACTIVE section first
2. Check SYSTEM section
3. Check DEPRECATED section
4. Run verify_registry.ps1
5. If still unsure, it's probably safe to delete

**Best practice:**
- Run verify_registry.ps1 before each commit
- Update registry when adding new docs
- Clean orphans weekly
- Review monthly

### For Claude:

**When user asks about files:**
1. Reference this FILE_REGISTRY first
2. Check ACTIVE section for current state
3. Mention verify_registry.ps1 for automation
4. Update registry when creating new files
5. Add to DEPRECATED when removing files

**When creating new documentation:**
1. Add entry to ACTIVE section immediately
2. Include version, purpose, location
3. Remind user to run verify_registry.ps1
4. Update CLAUDE:PROJECT_FILES if core doc

**When deprecating files:**
1. Move from ACTIVE to DEPRECATED
2. Add reason and date
3. Note replacement if applicable
4. Remind user to delete actual file

---

## [FAQ]

### Q: How do I know if a file should be deleted?
**A:** Run `.\verify_registry.ps1` - it will tell you.

### Q: What if I find a file not in the registry?
**A:** Three options:
1. If you just created it → Add to ACTIVE section
2. If it's old and unknown → Safe to delete
3. If unsure → Run verify_registry.ps1

### Q: Should meta.json be in ACTIVE?
**A:** No, it's in SYSTEM:FILES (used by automation, not user-facing).

### Q: What about backups/ and logs/ folders?
**A:** They're in SYSTEM:FILES (keep always, managed by scripts).

### Q: How often should I run verify_registry.ps1?
**A:** 
- Before commits (to catch orphans)
- After adding files (to verify tracking)
- When confused about what to keep
- Weekly during active development

### Q: What if verify_registry.ps1 shows a file I just created?
**A:** Normal! Add it to FILE_REGISTRY.md ACTIVE section.

### Q: Can I delete files in DEPRECATED section?
**A:** YES - that's what DEPRECATED means. They should be deleted.

---

## [SUPPORT]

**If problems arise:**

1. **Orphan files appearing:**
   - Check if recently created
   - Add to ACTIVE if keeping
   - Delete if truly orphan

2. **Can't find file in registry:**
   - Search with Ctrl+F
   - Check all sections (ACTIVE, SYSTEM, DEPRECATED)
   - Run verify_registry.ps1

3. **Unsure if file is needed:**
   - Check git history: `git log --follow filename`
   - Check when last modified
   - If >30 days old and unknown → Safe to delete

4. **verify_registry.ps1 not working:**
   - Check PowerShell execution policy
   - Run from docs/ folder
   - Check script is in docs/ folder

---

**[REGISTRY:END]**

**Last verified:** 2025-11-16 16:30  
**Version:** 2.0.0 (Hybrid Approach)  
**Current session:** Notes CRUD complete (v2.1.15)  
**Next session:** Tags UI + Continue MVP development  
**Status:** Production-ready with automated verification
