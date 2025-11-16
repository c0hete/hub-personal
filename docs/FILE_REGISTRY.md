# FILE REGISTRY - HubPersonal Documentation

**Purpose:** Single source of truth for current valid documentation files  
**Rule:** When creating new version, DELETE old version and UPDATE this registry  
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
| FILE_REGISTRY.md | Current | ACTIVE | This file (version tracker) | docs/ |

### Supporting Documentation

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 11_AUTO_VERSIONING_SYSTEM.md | 1.0 | ACTIVE | Auto-versioning docs | docs/ |
| README_AUTO_VERSIONING.md | 1.0 | ACTIVE | Quick guide | docs/ |
| POWERSHELL_STANDARDS.md | 1.0 | ACTIVE | Encoding rules | docs/ |
| TEST_NOTE_EXAMPLE.md | 1.0 | ACTIVE | @meta examples | docs/ |

### Scripts (Working)

| File | Version | Status | Purpose | Location |
|------|---------|--------|---------|----------|
| 08_PARSER.ps1 | 1.2 | ACTIVE | Parse @meta blocks | docs/ |
| update_docs.ps1 | 1.2 | ACTIVE | Version bumper | docs/ |
| cleanup_docs.ps1 | 1.0 | ACTIVE | Clean old files | docs/ |
| fix_encoding.ps1 | 1.0 | ACTIVE | Fix PowerShell encoding | docs/ |
| regenerate_scripts.ps1 | 1.0 | ACTIVE | Regenerate scripts | docs/ |

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
| 09_MIGRATION_TO_NEW_SESSION.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Outdated |
| 10_MIGRATION_NEXT_SESSION.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Incomplete |
| 10_MIGRATION_NEXT_SESSION_FINAL.md | 10_MIGRATION_2025-11-16.md | 2025-11-16 | Renamed with date |
| AUTO_VERSIONING_SYSTEM.md | 11_AUTO_VERSIONING_SYSTEM.md | 2025-11-16 | No number prefix |
| docs (file) | N/A | 2025-11-16 | Malformed file |
| docs/scripts/ (folder) | N/A | 2025-11-16 | Duplicates in docs/ |

---

## [CLAUDE:PROJECT_FILES]

**Files that MUST be in Claude Project for context:**

### Required (Always)
1. 00_INDEX.md
2. 01_MASTER_DOC_v2.1.15.md (current version)
3. 03_PROMPTS_v2.3.md (current version)
4. 06_METADATA_PROTOCOL.md

### Session Specific (Update per session)
5. 10_MIGRATION_2025-11-16.md (current session)
6. FILE_REGISTRY.md (always upload latest)

### Optional (Nice to have)
- 11_AUTO_VERSIONING_SYSTEM.md

---

## [WORKFLOW:FILE_UPDATES]

### When creating new migration file:

```powershell
# 1. Create new file with descriptive name
New-Item "docs/10_MIGRATION_NEXT_SESSION_FINAL.md"

# 2. Delete old migration file
Remove-Item "docs/10_MIGRATION_NEXT_SESSION.md"

# 3. Update this registry
# Edit FILE_REGISTRY.md:
# - Mark old file as DEPRECATED
# - Add new file to ACTIVE
# - Update CLAUDE:PROJECT_FILES section

# 4. Commit
git add docs/FILE_REGISTRY.md
git commit -m "docs: Update FILE_REGISTRY after migration file rotation"
```

### When updating core docs:

```powershell
# 1. Update file (e.g., 01_MASTER_DOC.md)
# 2. Update version in meta.json
# 3. Update this registry:
#    - Update version column
#    - Update last update date
# 4. Commit together
```

---

## [RULES:FILE_NAMING]

### Migration files:
```
Format: 10_MIGRATION_NEXT_SESSION_[DESCRIPTOR].md
Examples:
- 10_MIGRATION_NEXT_SESSION_FINAL.md (current)
- 10_MIGRATION_TAGS_FEATURE.md (if we start tags next)

ALWAYS include date in content, not filename
DELETE previous migration file when creating new
```

### Documentation files:
```
Format: ##_DESCRIPTIVE_NAME.md
Examples:
- 00_INDEX.md (no version, always current)
- 01_MASTER_DOC.md (version in meta.json)
- 03_PROMPTS.md (version in file header)

Version tracking: Inside file or meta.json
```

### Script files:
```
Format: ##_script_name.ps1
Examples:
- 08_PARSER.ps1
- update_docs.ps1

Version: Inside file header as comment
```

---

## [MAINTENANCE:CHECKLIST]

**Before ending each session:**

- [ ] Create new migration file if needed
- [ ] Delete old migration file
- [ ] Update FILE_REGISTRY.md
- [ ] Update meta.json if docs changed
- [ ] Commit FILE_REGISTRY changes
- [ ] Verify Claude Project has current files

**Before starting new session:**

- [ ] Check FILE_REGISTRY.md for active files
- [ ] Delete any deprecated files found
- [ ] Upload current files to Claude Project
- [ ] Paste migration file content as context

---

## [REVIEW:SCHEDULE]

**Next full review:** When starting next session

**Review checklist:**
1. Are all ACTIVE files actually needed?
2. Are DEPRECATED files actually deleted?
3. Is version tracking accurate?
4. Are Claude Project files up to date?
5. Is documentation coherent?
6. Can automation be optimized?

---

## [VERSION:HISTORY]

### v1.0.0 - 2025-11-16
- Initial creation
- Documented current state after Notes CRUD completion
- Established file naming rules
- Created maintenance checklist

---

## [NOTES:USAGE]

**For Jose:**
- Check this file FIRST when unsure which file to use
- Before uploading to Claude, verify against ACTIVE section
- If file not listed here, it's probably wrong/old

**For Claude:**
- Reference this file when asked "which file should I use?"
- When creating new files, update this registry
- When deprecating files, add to DEPRECATED section
- Remind Jose to delete deprecated files

---

**[REGISTRY:END]**

Last verified: 2025-11-16 16:30
Current session: Notes CRUD complete (v2.1.15)
Next session: Tags UI + Full process review
