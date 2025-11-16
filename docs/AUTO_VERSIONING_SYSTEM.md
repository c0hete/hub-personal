# [SYSTEM] AUTO-VERSIONING DOCUMENTATION SYSTEM

**Version:** 1.0.0  
**Created:** 2025-11-16  
**Purpose:** Automatic synchronization between code and documentation  
**Replicability:** Can be used in any project with technical documentation

---

## [OVERVIEW] [L10]

### What is it?

A system that automatically updates technical documentation (MASTER.md) when code changes, using embedded metadata blocks in source files.

### Flow

```
Code with @meta → Save file → Parser detects → Extract @doc-update
→ Update MASTER.md → Version bump → Git commit → Done ✅
```

### Benefits

- ✅ No manual doc updates
- ✅ Code is source of truth
- ✅ Documentation always synced
- ✅ Version control automatic
- ✅ Git history preserved
- ✅ Scales to any project size

---

## [QUICK_START] [L15]

**TL;DR - Get started in 5 minutes:**

1. **Copy 3 files to your project:**
   - `06_METADATA_PROTOCOL.md`
   - `08_PARSER.ps1`
   - `update_docs.ps1`

2. **Create meta.json:**
```json
{"version": "1.0.0", "last_modified": "2025-11-16T00:00:00Z", "project_name": "YourProject"}
```

3. **Add @meta to your code:**
```php
/** @meta-start
 * @session: 2025-11-16-001
 * @file: src/Model.php
 * @refs: [DB:SCHEMA]
 * @changes: Added field
 * @doc-update: [DB:SCHEMA] ADD field_name TYPE
 * @meta-end */
```

4. **Run:** 
```powershell
.\08_PARSER.ps1 -File src/Model.php
```

Done! ✅

---

## [COMPONENTS] [L50]

### Files Required

```
docs/
├── 06_METADATA_PROTOCOL.md      # Protocol specification (820 lines)
├── 08_PARSER.ps1                # Main parser (PowerShell)
├── update_docs.ps1              # Versioning script
├── meta.json                    # Version metadata
├── 01_MASTER_DOC.md            # Target documentation
└── POWERSHELL_STANDARDS.md     # Encoding rules (optional)
```

### How They Work Together

```
[Code with @meta]
        ↓
[08_PARSER.ps1] ← reads @meta blocks
        ↓
[Validates against 06_METADATA_PROTOCOL.md]
        ↓
[Updates 01_MASTER_DOC.md]
        ↓
[update_docs.ps1] ← version bump
        ↓
[meta.json] ← stores new version
        ↓
[Git commit] (optional)
```

---

## [INSTALLATION] [L70]

### Step 1: Create Documentation Structure

```powershell
# Create docs folder
mkdir docs
cd docs

# Create required files
New-Item -ItemType File -Name "meta.json"
New-Item -ItemType File -Name "01_MASTER_DOC.md"
New-Item -ItemType File -Name "06_METADATA_PROTOCOL.md"
New-Item -ItemType File -Name "08_PARSER.ps1"
New-Item -ItemType File -Name "update_docs.ps1"
```

### Step 2: Initialize meta.json

```json
{
  "version": "1.0.0",
  "last_modified": "2025-11-16T00:00:00Z",
  "project_name": "YourProject",
  "documentation_format": "marker-based"
}
```

### Step 3: Setup MASTER.md Structure

```markdown
# [MASTER:DOC] YOUR PROJECT - TECHNICAL DOCUMENTATION

**Version:** 1.0.0  
**Last Update:** 2025-11-16

---

## [SECTION:DATABASE] [L20]

### [DB:SCHEMA_USERS] [L25]

```sql
-- Schema will be documented here
```

## [SECTION:ARCHITECTURE] [L40]

### [ARCH:FOLDERS] [L45]

```
-- Folder structure will be documented here
```
```

### Step 4: Copy Parser Scripts

**Copy these files from HubPersonal project:**

1. `08_PARSER.ps1` (full parser)
2. `update_docs.ps1` (versioning)
3. `06_METADATA_PROTOCOL.md` (specification)

**Adjust paths in scripts:**

```powershell
# In 08_PARSER.ps1, update paths:
$masterDoc = ".\01_MASTER_DOC.md"  # Your master doc name
$metaJson = ".\meta.json"
$updateScript = ".\update_docs.ps1"
```

---

## [USAGE] [L145]

### Basic Workflow

**1. Write code with @meta block:**

```php
// File: app/Models/User.php

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/User.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Added avatar field to users table
 * @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
 * @meta-end
 */

namespace App\Models;

class User extends Authenticatable
{
    protected $fillable = [
        'name',
        'email',
        'avatar',  // NEW
    ];
}
```

**2. Run parser:**

```powershell
cd docs
.\08_PARSER.ps1 -File "..\app\Models\User.php"
```

**3. Results:**

```
[OK] Processed: app/Models/User.php
   Updates: 1
   - [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
   Version: 1.0.0 -> 1.0.1
   Changelog: Updated
```

---

## [PROTOCOL] [L195]

### @meta Block Structure

```
/**
 * @meta-start
 * @session: YYYY-MM-DD-NNN          ← Session identifier
 * @file: path/to/file                ← Source file path
 * @refs: [MARKER, MARKER]            ← MASTER.md markers
 * @changes: Human description        ← What changed
 * @doc-update: [MARKER] ACTION       ← Update instruction
 * @meta-end
 */
```

### Actions Supported

| Action | Format | Example |
|--------|--------|---------|
| ADD | `[MARKER] ADD content` | `[DB:SCHEMA_USERS] ADD avatar VARCHAR(255)` |
| MODIFY | `[MARKER] MODIFY old -> new` | `[STACK:DB] MODIFY MySQL -> PostgreSQL` |
| DELETE | `[MARKER] DELETE content` | `[DB:SCHEMA_USERS] DELETE temp_field` |
| MOVE | `[SOURCE] MOVE content TO [TARGET]` | `[PRD:NOTES] MOVE feature TO [PRD:CALENDAR]` |

### Markers Format

**✅ Correct:**
```
[SECTION:SUBSECTION]
[DB:SCHEMA_USERS]
[ARCH:FOLDERS]
```

**❌ Incorrect:**
```
[DB:SCHEMA_USERS#L570]  ← NO line numbers
DB:SCHEMA_USERS         ← NO missing brackets
```

---

## [EXAMPLES] [L250]

### Example 1: Add Database Field

```php
/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/Product.php
 * @refs: [DB:SCHEMA_PRODUCTS]
 * @changes: Added price and stock fields
 * @doc-update: [DB:SCHEMA_PRODUCTS] ADD price DECIMAL(10,2) NOT NULL
 * @doc-update: [DB:SCHEMA_PRODUCTS] ADD stock INTEGER DEFAULT 0
 * @meta-end
 */
```

### Example 2: Modify Stack Decision

```php
/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: config/database.php
 * @refs: [STACK:DATABASE]
 * @changes: Switched from MySQL to PostgreSQL
 * @doc-update: [STACK:DATABASE] MODIFY MySQL 8.0 -> PostgreSQL 15
 * @meta-end
 */
```

### Example 3: Multiple Sections

```vue
<!--
@meta-start
@session: 2025-11-16-003
@file: resources/js/Pages/Dashboard.vue
@refs: [ARCH:FOLDERS, DESIGN:COMPONENTS]
@changes: Created Dashboard page with metrics
@doc-update: [ARCH:FOLDERS] ADD Dashboard.vue in resources/js/Pages/
@doc-update: [DESIGN:COMPONENTS] ADD MetricCard.vue component
@meta-end
-->
```

---

## [AUTOMATION] [L310]

### Manual Execution

```powershell
# Process single file
.\08_PARSER.ps1 -File "..\app\Models\User.php"

# Process multiple files
$files = @(
    "..\app\Models\User.php",
    "..\app\Models\Product.php"
)
foreach ($file in $files) {
    .\08_PARSER.ps1 -File $file
}
```

### File Watcher (Future)

```powershell
# 07_WATCHER.ps1 (in development)
# Automatically detects file changes and runs parser
# Currently has VSCode compatibility issues on Windows
```

### Git Integration

Parser automatically creates commits:

```
docs: Auto-update from app/Models/User.php

- [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL

Version: 1.0.0 -> 1.0.1
```

---

## [VERSIONING] [L355]

### Automatic Patch Bump

Every successful `@doc-update` triggers:

```
1.0.0 -> 1.0.1 -> 1.0.2 -> ...
```

### Manual Minor/Major

```powershell
# Minor bump (new feature)
.\update_docs.ps1 -Version Minor
# 1.0.5 -> 1.1.0

# Major bump (breaking change)
.\update_docs.ps1 -Version Major
# 1.5.3 -> 2.0.0
```

### Version Storage

```json
// meta.json
{
  "version": "1.0.5",
  "last_modified": "2025-11-16T15:30:00Z",
  "project_name": "YourProject"
}
```

---

## [VISUAL_FLOW] [L380]

```
┌─────────────────┐
│  Code with      │
│  @meta block    │
└────────┬────────┘
         │
         v
┌─────────────────┐
│  08_PARSER.ps1  │◄─── Reads 06_METADATA_PROTOCOL.md
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Validates      │
│  @meta format   │
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Updates        │
│  MASTER.md      │
└────────┬────────┘
         │
         v
┌─────────────────┐
│ update_docs.ps1 │
│ (version bump)  │
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Git commit     │
│  (optional)     │
└─────────────────┘
```

---

## [CUSTOMIZATION] [L420]

### Adapt to Your Project

**1. Change marker naming:**

```markdown
# Instead of [DB:SCHEMA_USERS]
# Use your own convention:
[DATABASE:TABLES:USERS]
[BACKEND:MODELS:USER]
```

**2. Change documentation format:**

```markdown
# marker-based (current)
## [SECTION:NAME] [L###]

# or heading-based
## Section Name
### Subsection
```

**3. Add custom actions:**

```powershell
# In 08_PARSER.ps1, add:
elseif ($action -eq "APPEND") {
    # Your logic
}
```

**4. Custom validation:**

```powershell
# In 08_PARSER.ps1, modify:
function Validate-MetaBlock {
    # Add your rules
}
```

---

## [MIGRATION] [L440]

### From Existing Project

**If you already have code without @meta:**

**Option A: Retroactive (manual)**
1. Review significant code files
2. Add @meta blocks manually
3. Run parser

**Option B: Forward-only**
1. Start using @meta from now
2. Old code stays undocumented
3. Update docs manually for old code

**Recommendation:** Option B (less work)

### From Manual Documentation

**If you have MASTER.md but no auto-sync:**

1. Keep existing MASTER.md
2. Add markers: `[SECTION:NAME]`
3. Start using @meta in new code
4. Documentation evolves automatically

---

## [TROUBLESHOOTING] [L475]

### Parser doesn't find marker

```
ERROR: Marker [DB:SCHEMA_XYZ] not found in MASTER.md
```

**Solution:**
- Open MASTER.md
- Add marker: `### [DB:SCHEMA_XYZ]`
- Re-run parser

### Invalid @meta format

```
ERROR: Missing required field @session
```

**Solution:**
- Check @meta block has all fields:
  - @session
  - @file
  - @refs
  - @changes
  - @doc-update

### Version not bumping

```
Version stays at 1.0.0
```

**Solution:**
- Check `update_docs.ps1` is in same folder
- Check `meta.json` exists
- Run manually: `.\update_docs.ps1 -Update`

### Git not committing

**Solution:**
- Git integration is optional
- Comment out git commands in parser if not wanted

---

## [BEST_PRACTICES] [L525]

### When to use @meta

**✅ Always:**
- Database schema changes
- New models/controllers
- Architecture decisions
- Stack changes
- API endpoints

**❌ Never:**
- Bug fixes (no architectural impact)
- Refactoring (same functionality)
- Comment changes
- Minor tweaks

### Quality checklist

Before adding @meta:

```
☐ @session format correct (YYYY-MM-DD-NNN)
☐ @file path relative to project root
☐ @refs markers exist in MASTER.md
☐ @changes clear and concise
☐ @doc-update syntax correct
☐ ACTION appropriate (ADD/MODIFY/DELETE/MOVE)
☐ NO line numbers in markers
```

### Keep MASTER.md organized

```markdown
# Use clear hierarchy
[SECTION:DATABASE]
  [DB:SCHEMA_USERS]
  [DB:SCHEMA_PRODUCTS]

[SECTION:ARCHITECTURE]
  [ARCH:FOLDERS]
  [ARCH:PATTERNS]
```

---

## [TESTING] [L575]

### Test basic functionality

```powershell
# 1. Create test file
echo '/** @meta-start
@session: 2025-11-16-TEST
@file: test.php
@refs: [TEST:SECTION]
@changes: Test
@doc-update: [TEST:SECTION] ADD test content
@meta-end */' > test.php

# 2. Add marker to MASTER.md
echo '### [TEST:SECTION]' >> 01_MASTER_DOC.md

# 3. Run parser
.\08_PARSER.ps1 -File test.php

# 4. Check results
# - MASTER.md should have "test content"
# - meta.json version should bump
# - Git commit created (if enabled)

# 5. Cleanup
rm test.php
```

### Test all actions

```php
// ADD
@doc-update: [TEST:SECTION] ADD new line

// MODIFY
@doc-update: [TEST:SECTION] MODIFY old text -> new text

// DELETE
@doc-update: [TEST:SECTION] DELETE unwanted line

// MOVE
@doc-update: [TEST:SECTION] MOVE content TO [TEST:OTHER]
```

---

## [FILES_REFERENCE] [L625]

### 06_METADATA_PROTOCOL.md (820 lines)

Complete specification of:
- @meta block format
- Field definitions
- Actions (ADD/MODIFY/DELETE/MOVE)
- Validation rules
- Examples
- Error handling

**Purpose:** Protocol reference

### 08_PARSER.ps1 (~200 lines)

PowerShell script that:
- Reads @meta blocks from files
- Validates format
- Finds markers in MASTER.md
- Executes updates
- Calls versioning script
- Creates git commits

**Purpose:** Main engine

### update_docs.ps1 (~100 lines)

PowerShell script that:
- Reads current version from meta.json
- Bumps version (patch/minor/major)
- Updates meta.json
- Updates MASTER.md header
- Returns new version

**Purpose:** Version management

### meta.json (simple)

```json
{
  "version": "1.0.0",
  "last_modified": "2025-11-16T00:00:00Z",
  "project_name": "ProjectName"
}
```

**Purpose:** Version storage

---

## [REPLICATION_CHECKLIST] [L685]

To replicate in another project:

```
☐ Create docs/ folder
☐ Copy 06_METADATA_PROTOCOL.md
☐ Copy 08_PARSER.ps1
☐ Copy update_docs.ps1
☐ Copy POWERSHELL_STANDARDS.md (optional)
☐ Create meta.json with version 1.0.0
☐ Create 01_MASTER_DOC.md (or your name)
☐ Add markers to MASTER.md
☐ Update paths in parser scripts
☐ Test with sample @meta block
☐ Verify version bumps
☐ Verify MASTER.md updates
☐ Configure git integration (optional)
☐ Document project-specific conventions
```

**Time to setup:** ~30 minutes

---

## [LIMITATIONS] [L715]

### Current Version (1.0)

**Works:**
- ✅ Manual parser execution
- ✅ All actions (ADD/MODIFY/DELETE/MOVE)
- ✅ Version bumping
- ✅ Git integration
- ✅ Multiple @doc-update per file

**Doesn't work:**
- ❌ Automatic file watching (VSCode incompatibility)
- ❌ Error recovery/rollback
- ❌ Detailed logging
- ❌ Bidirectional sync (MASTER → code)

### Future Enhancements (v2.0)

- Auto file watcher (fix VSCode issue)
- Full error handling with rollback
- Detailed log files (parser.log)
- Visual diff tool
- Multi-file batch processing
- Breaking change detection
- Deprecation tracking

---

## [FAQ] [L780]

**Q: Do I need PowerShell?**  
A: Yes, currently. Python/Node.js versions planned for v2.0.

**Q: Works on Linux/Mac?**  
A: With PowerShell Core, yes. Tested on Windows only.

**Q: Can I use with Python/Node projects?**  
A: Yes! Language-agnostic. Works with any text files.

**Q: How big can MASTER.md be?**  
A: Tested up to 5000 lines. No theoretical limit.

**Q: What if I mess up @meta syntax?**  
A: Parser validates and shows errors. Nothing breaks.

**Q: Can I disable git commits?**  
A: Yes, comment out git commands in 08_PARSER.ps1.

**Q: Does it work with branches?**  
A: Yes, parser runs in whatever branch you're on.

**Q: Can multiple people use it on same project?**  
A: Yes, but coordinate to avoid merge conflicts in MASTER.md.

---

## [SUPPORT] [L810]

### Documentation
- **Full protocol:** 06_METADATA_PROTOCOL.md
- **This guide:** AUTO_VERSIONING_SYSTEM.md
- **Encoding rules:** POWERSHELL_STANDARDS.md

### Common Issues

See [TROUBLESHOOTING] section

### Testing

See [TESTING] section

---

## [SUMMARY] [L830]

**In 60 seconds:**

1. System auto-updates docs from code
2. Embed @meta blocks in source files
3. Run parser: `.\08_PARSER.ps1 -File path.php`
4. MASTER.md updates automatically
5. Version bumps automatically
6. Git commits automatically (optional)
7. Replicate to any project in ~30 min

**Key principle:** Code is source of truth, docs follow automatically.

---

**[SYSTEM:END]** [L850]

**Version:** 1.0.0  
**Status:** Production-ready  
**Tested:** HubPersonal project (4 successful updates)  
**Replicable:** Yes (follow [REPLICATION_CHECKLIST])
