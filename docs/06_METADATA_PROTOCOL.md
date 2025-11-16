# [PROTOCOL] METADATA DOCUMENTATION PROTOCOL

**Version:** 1.0.0  
**Created:** 2025-11-15  
**Purpose:** Auto-sync code changes → MASTER.md  
**Format:** Marker-based (NO line numbers)

---

## [OVERVIEW] [L10]

**Problem:**
- Manual doc updates = error-prone
- José as bottleneck between code and docs
- Desync between implementation and documentation

**Solution:**
- Embed @meta tags in code comments
- File watcher detects changes
- Parser extracts @doc-update instructions
- Auto-update MASTER.md
- Version and log automatically

**Flow:**
```
Code with @meta → Save file → Watcher detects → Parser extracts
→ Update MASTER → Version → Log → Done ✅
```

---

## [PROTOCOL:STRUCTURE] [L30]

### Basic Format

```php
/**
 * @meta-start
 * @session: YYYY-MM-DD-NNN
 * @file: path/to/file
 * @refs: [MARKER, MARKER, ...]
 * @changes: Human-readable description
 * @doc-update: [MARKER] ACTION details
 * @doc-update: [MARKER] ACTION details
 * @meta-end
 */
```

### Field Definitions

| Field | Required | Type | Description | Example |
|-------|----------|------|-------------|---------|
| `@session` | ✅ YES | String | Session identifier | `2025-11-15-002` |
| `@file` | ✅ YES | Path | Source file path | `app/Models/User.php` |
| `@refs` | ✅ YES | Array | MASTER.md markers | `[DB:SCHEMA_USERS, AUTH:POLICY]` |
| `@changes` | ✅ YES | Text | Human description | `Added avatar and timezone` |
| `@doc-update` | ✅ YES | Instruction | Parser command | See Actions below |

### Optional Fields

| Field | Type | Purpose | Example |
|-------|------|---------|---------|
| `@feature` | String | Feature grouping | `user-profiles` |
| `@tests` | String | Related test | `UserTest::test_avatar_upload` |

---

## [ACTIONS:ALLOWED] [L70]

### ADD
**Purpose:** Insert new content into section

**Format:**
```
@doc-update: [MARKER] ADD content here
```

**Example:**
```php
/**
 * @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
 * @doc-update: [DB:SCHEMA_USERS] ADD timezone VARCHAR(50) DEFAULT 'UTC'
 */
```

**Parser behavior:**
- Finds `[DB:SCHEMA_USERS]` section in MASTER.md
- Appends content to section
- Maintains formatting

---

### MODIFY
**Purpose:** Change existing content

**Format:**
```
@doc-update: [MARKER] MODIFY old_text -> new_text
```

**Example:**
```php
/**
 * @doc-update: [DB:SCHEMA_USERS] MODIFY points INT DEFAULT 0 -> points BIGINT DEFAULT 0
 */
```

**Parser behavior:**
- Finds `[MARKER]` section
- Searches for `old_text`
- Replaces with `new_text`
- Errors if `old_text` not found

---

### DELETE
**Purpose:** Remove content

**Format:**
```
@doc-update: [MARKER] DELETE text_to_remove
```

**Example:**
```php
/**
 * @doc-update: [DB:SCHEMA_NOTES] DELETE reminder_minutes INT NULL
 */
```

**Parser behavior:**
- Finds `[MARKER]` section
- Removes matching line/content
- Errors if not found

---

### MOVE
**Purpose:** Relocate content between sections

**Format:**
```
@doc-update: [SOURCE_MARKER] MOVE content TO [TARGET_MARKER]
```

**Example:**
```php
/**
 * @doc-update: [PRD:NOTES_SYSTEM] MOVE recurrence feature TO [PRD:CALENDAR]
 */
```

**Parser behavior:**
- Finds content in SOURCE
- Removes from SOURCE
- Adds to TARGET
- Preserves formatting

---

## [MARKERS:REFERENCE] [L155]

### Critical Rule
**NEVER use line numbers in @meta tags**

❌ BAD:
```php
@refs: [DB:SCHEMA_USERS#L570]
@doc-update: [DB:SCHEMA_USERS#L570] ADD avatar
```

✅ GOOD:
```php
@refs: [DB:SCHEMA_USERS]
@doc-update: [DB:SCHEMA_USERS] ADD avatar
```

**Reason:** Line numbers shift when MASTER.md changes

### Marker Format
```
[SECTION:SUBSECTION]
```

**Examples:**
- `[DB:SCHEMA_USERS]`
- `[PRD:NOTES_SYSTEM]`
- `[ARCH:FOLDERS]`
- `[DEPLOY:CICD]`
- `[QUICK:STACK]`

**Finding markers:**
- Open `01_MASTER_DOC.md`
- Search: `[DB:SCHEMA_USERS]` (exact match)
- Parser does same programmatically

---

## [EXAMPLES:COMPLETE] [L195]

### Example 1: Add Database Fields

```php
// File: app/Models/User.php

/**
 * @meta-start
 * @session: 2025-11-15-002
 * @file: app/Models/User.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Added avatar and timezone for user profiles
 * @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
 * @doc-update: [DB:SCHEMA_USERS] ADD timezone VARCHAR(50) DEFAULT 'UTC'
 * @tests: UserTest::test_avatar_upload
 * @meta-end
 */

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar',      // NEW
        'timezone',    // NEW
    ];
}
```

---

### Example 2: Modify Stack Decision

```php
// File: config/cache.php

/**
 * @meta-start
 * @session: 2025-11-15-003
 * @file: config/cache.php
 * @refs: [STACK:BACKEND]
 * @changes: Changed cache driver from Redis to Memcached
 * @doc-update: [STACK:BACKEND] MODIFY Cache: Redis -> Cache: Memcached
 * @meta-end
 */

return [
    'default' => env('CACHE_DRIVER', 'memcached'),
];
```

---

### Example 3: Multiple Sections

```vue
<!-- File: resources/js/Pages/Notes/Index.vue -->

<!--
@meta-start
@session: 2025-11-15-004
@file: resources/js/Pages/Notes/Index.vue
@refs: [PRD:NOTES_SYSTEM, ARCH:ROUTING, DESIGN:COMPONENTS]
@changes: Implemented notes index with filtering
@doc-update: [PRD:NOTES_SYSTEM] ADD Filter by pinned status
@doc-update: [ARCH:ROUTING] ADD Route::get('/notes/pinned')
@doc-update: [DESIGN:COMPONENTS] ADD NoteFilter.vue component
@tests: NoteTest::test_filter_pinned_notes
@meta-end
-->

<script setup>
import NoteFilter from '@/Components/NoteFilter.vue'

defineProps({
  notes: Array
})
</script>

<template>
  <NoteFilter v-model="filters" />
  <!-- ... -->
</template>
```

---

### Example 4: Delete Feature

```php
// File: app/Services/EmailService.php

/**
 * @meta-start
 * @session: 2025-11-15-005
 * @file: app/Services/EmailService.php
 * @refs: [PRD:EMAIL]
 * @changes: Removed auto-sync feature, manual only
 * @doc-update: [PRD:EMAIL] DELETE Sync: Manual or every 15 min
 * @doc-update: [PRD:EMAIL] ADD Sync: Manual only (on-demand)
 * @meta-end
 */

class EmailService
{
    // Auto-sync removed
}
```

---

## [FILE_TYPES:SUPPORT] [L305]

### PHP Files
```php
/**
 * @meta-start
 * ...
 * @meta-end
 */
```

### Vue Files
```vue
<!--
@meta-start
...
@meta-end
-->
```

### JavaScript Files
```js
/**
 * @meta-start
 * ...
 * @meta-end
 */
```

### Blade Files
```blade
{{--
@meta-start
...
@meta-end
--}}
```

### SQL/Migration Files
```sql
-- @meta-start
-- @session: 2025-11-15-006
-- @file: database/migrations/xxx.php
-- @refs: [DB:SCHEMA_USERS]
-- @changes: Added avatar column
-- @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
-- @meta-end
```

---

## [PARSER:BEHAVIOR] [L360]

### Detection Rules

1. **Find @meta blocks:**
   - Search for `@meta-start` and `@meta-end`
   - Extract all content between tags
   - Parse each field

2. **Validate fields:**
   - Required: session, file, refs, changes, doc-update
   - Format: Check syntax
   - Markers: Verify exist in MASTER.md

3. **Execute updates:**
   - For each `@doc-update` line:
     - Find marker section in MASTER.md
     - Execute ACTION (ADD/MODIFY/DELETE/MOVE)
     - Update content
     - Maintain formatting

4. **Post-update:**
   - Run `update_docs.ps1 -Update`
   - Version bump (patch)
   - Add changelog entry
   - Optional: Git commit

### Error Handling

**If marker not found:**
```
ERROR: Marker [DB:SCHEMA_XYZ] not found in MASTER.md
File: app/Models/XYZ.php
Line: 15
Action: Skip update, log error, notify José
```

**If MODIFY target not found:**
```
ERROR: Cannot find "old_text" in [DB:SCHEMA_USERS]
Action: Skip update, log error, notify José
```

**If validation fails:**
```
ERROR: Missing required field @session
File: app/Models/User.php
Action: Skip block, log error, notify José
```

### Success Output

```
[OK] Processed: app/Models/User.php
   Updates: 2
   - [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
   - [DB:SCHEMA_USERS] ADD timezone VARCHAR(50) DEFAULT 'UTC'
   Version: 2.1.0 -> 2.1.1
   Changelog: Updated
```

---

## [WORKFLOW:INTEGRATION] [L430]

### Developer Workflow (José)

```
1. Request code from Claude
   "Create User model with avatar field"

2. Claude generates code with @meta tags
   (Following this protocol)

3. José copies, pastes into file
   app/Models/User.php

4. José saves file
   Ctrl+S

5. Watcher detects change
   (Running in background)

6. Parser extracts @meta
   (Automatic)

7. MASTER.md updated
   (Automatic)

8. Version bumped
   (Automatic)

9. José continues coding
   (No manual doc work needed)
```

### Claude Workflow

```
1. Load context from SESSION_START.md
   (Every new conversation)

2. Read PROMPTS.md rules
   (Includes metadata protocol)

3. Generate code with @meta
   (For ANY file that affects MASTER.md)

4. Include complete @meta block
   - All required fields
   - Accurate @refs
   - Clear @changes
   - Precise @doc-update

5. Provide code ready to paste
   (No extra explanations unless asked)
```

---

## [RULES:CLAUDE] [L485]

### When to Add @meta

**ALWAYS add @meta when code affects:**
- Database schema
- Architecture decisions
- New features/modules
- Stack/dependency changes
- API endpoints
- Design system
- Authentication/Authorization
- Performance optimizations

**DON'T add @meta for:**
- Bug fixes (no architectural impact)
- Refactoring (same functionality)
- Tests only (unless new test strategy)
- Comments/formatting
- Minor UI tweaks

### Quality Checklist

Before generating code, verify:

```
□ @session format: YYYY-MM-DD-NNN
□ @file matches actual path
□ @refs markers exist in MASTER.md
□ @changes is clear and concise
□ @doc-update syntax correct
□ ACTION (ADD/MODIFY/DELETE/MOVE) appropriate
□ Multiple @doc-update if needed
□ NO line numbers in markers
```

---

## [VALIDATION:RULES] [L525]

### Field Formats

**@session:**
```
Pattern: YYYY-MM-DD-NNN
Valid:   2025-11-15-001
Invalid: 2025/11/15, 11-15-2025, 001
```

**@file:**
```
Pattern: relative/path/to/file.ext
Valid:   app/Models/User.php
Invalid: /app/Models/User.php, C:\app\...
```

**@refs:**
```
Pattern: [MARKER, MARKER, ...]
Valid:   [DB:SCHEMA_USERS, AUTH:POLICY]
Invalid: [DB:SCHEMA_USERS#L570], DB:SCHEMA_USERS
```

**@doc-update:**
```
Pattern: [MARKER] ACTION details
Valid:   [DB:SCHEMA_USERS] ADD avatar VARCHAR(255)
Invalid: ADD avatar, [DB:SCHEMA_USERS#L570] ADD avatar
```

### Parser Validation

```powershell
# Pseudocode
if (!Validate-Session $session) {
    throw "Invalid @session format"
}

if (!Test-Path $file) {
    throw "File not found: $file"
}

foreach ($marker in $refs) {
    if (!(Find-Marker $marker "01_MASTER_DOC.md")) {
        throw "Marker not found: $marker"
    }
}

# Execute updates only if all validations pass
```

---

## [TESTING:PROTOCOL] [L580]

### Test Case 1: Simple ADD

**Input:**
```php
/**
 * @meta-start
 * @session: 2025-11-15-TEST-001
 * @file: test/User.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Test ADD action
 * @doc-update: [DB:SCHEMA_USERS] ADD test_field VARCHAR(100)
 * @meta-end
 */
```

**Expected:**
- Find `[DB:SCHEMA_USERS]` in MASTER.md
- Append `test_field VARCHAR(100)` to schema
- Version: 2.1.0 -> 2.1.1
- Changelog entry added

### Test Case 2: Multiple Updates

**Input:**
```php
/**
 * @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255)
 * @doc-update: [DB:SCHEMA_USERS] ADD timezone VARCHAR(50)
 * @doc-update: [AUTH:POLICY] ADD avatar upload policy
 */
```

**Expected:**
- 3 separate updates executed
- All markers found
- All content added
- Single version bump
- One changelog entry with all changes

### Test Case 3: Error Handling

**Input:**
```php
/**
 * @doc-update: [INVALID:MARKER] ADD something
 */
```

**Expected:**
- Error: Marker not found
- Update skipped
- Log error
- Notify user
- No version bump

---

## [VERSION:CONTROL] [L645]

### Version Bumping

**Automatic patch bump:**
- Every successful @doc-update
- 2.1.0 -> 2.1.1 -> 2.1.2 ...

**Manual minor/major:**
- José runs: `.\update_docs.ps1 -Version Minor`
- After feature completion
- After major refactoring

### Changelog Format

```markdown
### v2.1.1 - 2025-11-15 15:30
**Auto-update from:** app/Models/User.php
**Session:** 2025-11-15-002
**Changes:**
- [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
- [DB:SCHEMA_USERS] ADD timezone VARCHAR(50) DEFAULT 'UTC'
```

---

## [MIGRATION:GUIDE] [L675]

### Existing Codebase

**If code already exists without @meta:**

1. Generate @meta retroactively:
   ```bash
   .\generate_meta.ps1 -File app/Models/User.php
   ```

2. Review and edit @meta block

3. Save file

4. Watcher picks up and processes

### New Project

**Start with @meta from day 1:**

1. Claude generates all code with @meta
2. Docs stay synced automatically
3. No retroactive work needed

---

## [FUTURE:ENHANCEMENTS] [L700]

**Possible v2.0 features:**

- `@breaking-change` tag for major updates
- `@deprecated` tag for removed features
- Auto-generate migration from schema changes
- Bidirectional sync (MASTER → code templates)
- Visual diff tool for doc changes
- Multi-file updates in one session
- Rollback capability

**Current scope:** v1.0 (this spec)

---

## [SUMMARY:QUICK] [L720]

**Protocol in 30 seconds:**

1. Add @meta block in code comments
2. Required: session, file, refs, changes, doc-update
3. Use markers only (NO line numbers)
4. Actions: ADD, MODIFY, DELETE, MOVE
5. Save file → Auto-update MASTER.md
6. Version + changelog automatic
7. Keep coding, forget manual docs

**Key principle:** Code is source of truth, docs follow.

---

## [EXAMPLES:COMMON_TASKS] [L740]

### Add New Model

```php
// File: app/Models/Category.php

/**
 * @meta-start
 * @session: 2025-11-15-010
 * @file: app/Models/Category.php
 * @refs: [DB:SCHEMA_NOTES, ARCH:FOLDERS]
 * @changes: Created Category model for note organization
 * @doc-update: [DB:SCHEMA_NOTES] ADD category_id BIGINT REFERENCES categories(id)
 * @doc-update: [ARCH:FOLDERS] ADD Category.php in app/Models/
 * @tests: CategoryTest::test_category_creation
 * @meta-end
 */
```

### Change Stack Decision

```php
// File: composer.json

/**
 * @meta-start
 * @session: 2025-11-15-011
 * @file: composer.json
 * @refs: [STACK:BACKEND]
 * @changes: Switched from Pest to PHPUnit for broader compatibility
 * @doc-update: [STACK:BACKEND] MODIFY Testing: Pest → Testing: PHPUnit
 * @meta-end
 */
```

### Add API Endpoint

```php
// File: routes/api.php

/**
 * @meta-start
 * @session: 2025-11-15-012
 * @file: routes/api.php
 * @refs: [API:STRUCTURE_ENDPOINTS]
 * @changes: Added notes export endpoint
 * @doc-update: [API:STRUCTURE_ENDPOINTS] ADD GET /api/v1/notes/export
 * @meta-end
 */

Route::get('/notes/export', [NoteController::class, 'export']);
```

### Update Design System

```vue
<!-- File: resources/js/Components/Button.vue -->

<!--
@meta-start
@session: 2025-11-15-013
@file: resources/js/Components/Button.vue
@refs: [DESIGN:COMPONENTS]
@changes: Added loading state to Button component
@doc-update: [DESIGN:COMPONENTS] ADD Button loading variant with spinner
@meta-end
-->

<template>
  <button :disabled="loading">
    <Spinner v-if="loading" />
    <slot v-else />
  </button>
</template>
```

---

**[PROTOCOL:END]** [L820]

**Version:** 1.0.0  
**Status:** Specification complete  
**Next:** Implement parser (08_PARSER.ps1)
