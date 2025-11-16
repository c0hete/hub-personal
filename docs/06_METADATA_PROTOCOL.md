# [METADATA:PROTOCOL] Specification

**Version:** 1.0.0  
**Created:** 2025-11-15  
**Purpose:** Auto-sync code changes to documentation  
**Author:** JosÃ© Alvarado Mazzei + Claude

---

## [OVERVIEW] [L10]

**Problem:**
- Code changes require manual doc updates
- JosÃ© as bottleneck between Claude and MASTER.md
- Easy to forget or mis-document changes
- Desync between code and documentation

**Solution:**
- Embed metadata in code comments
- File watcher detects changes
- Parser auto-updates MASTER.md
- Version control tracks everything

**Flow:**
```
Claude generates code with @meta tags
    â†"
JosÃ© saves file
    â†"
Watcher detects @meta block
    â†"
Parser extracts + validates
    â†"
Auto-updates MASTER.md
    â†"
update_docs.ps1 versions
    â†"
Optional: git commit
```

---

## [PROTOCOL:SYNTAX] [L40]

### **Basic structure:**

```php
/**
 * @meta-start
 * @session: YYYY-MM-DD-NNN
 * @type: model|migration|controller|service|component|config|route|test
 * @file: relative/path/from/project/root.php
 * @feature: feature-name (optional)
 * @refs: [MARKER#LINE, MARKER#LINE] (optional)
 * @changes: Human-readable description of what changed
 * @doc-update: [MARKER#LINE] ACTION details (required if MASTER.md affected)
 * @tests: TestClass::test_method (optional)
 * @meta-end
 */
```

### **Field types:**

| Field | Type | Required | Format | Example |
|-------|------|----------|--------|---------|
| `@meta-start` | Delimiter | âœ… | Exact match | `@meta-start` |
| `@meta-end` | Delimiter | âœ… | Exact match | `@meta-end` |
| `@session` | String | âœ… | YYYY-MM-DD-NNN | `2025-11-15-001` |
| `@type` | Enum | âœ… (code files) | See types below | `model` |
| `@file` | String | âœ… | Relative path | `app/Models/User.php` |
| `@feature` | String | ❌ | kebab-case | `user-avatar` |
| `@refs` | Array | ❌ | [MARKER#LINE] | `[DB:SCHEMA_USERS#L570]` |
| `@changes` | String | âœ… | Free text | `Added avatar field` |
| `@doc-update` | Array | âœ… (if docs affected) | [MARKER#LINE] ACTION | See actions below |
| `@tests` | Array | ❌ | Class::method | `UserTest::test_avatar` |

---

## [TYPES:ALLOWED] [L75]

**Code types:**
- `model` - Eloquent models (app/Models)
- `migration` - Database migrations
- `controller` - HTTP controllers
- `service` - Service classes
- `repository` - Repository pattern
- `request` - Form requests
- `resource` - API resources
- `middleware` - Middleware
- `command` - Artisan commands
- `job` - Queue jobs
- `event` - Events
- `listener` - Event listeners
- `observer` - Model observers
- `policy` - Authorization policies
- `rule` - Validation rules

**Frontend types:**
- `component` - Vue components
- `page` - Inertia pages
- `composable` - Vue composables
- `store` - Pinia stores

**Config types:**
- `config` - Config files
- `route` - Route definitions
- `env` - Environment variables

**Test types:**
- `test` - Test cases

---

## [ACTIONS:ALLOWED] [L115]

### **ADD** - Add new content

```php
@doc-update: [DB:SCHEMA_USERS#L570] ADD avatar:string(nullable), timezone:string
```

**Use cases:**
- New database fields
- New model relationships
- New API endpoints
- New features to roadmap
- New architecture components

### **UPDATE** - Modify existing content

```php
@doc-update: [DB:SCHEMA_USERS#L570] UPDATE email field unique→not_unique
```

**Use cases:**
- Change field types
- Modify relationships
- Update API responses
- Revise architecture decisions

### **REMOVE** - Delete content

```php
@doc-update: [ROADMAP:BACKLOG#L3500] REMOVE email-sync feature
```

**Use cases:**
- Deprecated features
- Removed fields
- Deleted endpoints
- Cancelled plans

### **MARK** - Change status

```php
@doc-update: [ROADMAP:MVP#L3340] MARK notes-crud DONE
@doc-update: [ROADMAP:MVP#L3350] MARK auth-system IN_PROGRESS
```

**Valid status values:**
- `TODO` - Not started
- `IN_PROGRESS` - Currently working
- `DONE` - Completed
- `BLOCKED` - Waiting on something
- `CANCELLED` - Won't do

### **MOVE** - Relocate section

```php
@doc-update: [ROADMAP:MVP#L3350] MOVE email-sync TO [ROADMAP:V2#L3600]
```

**Use cases:**
- Feature moved to different version
- Section reorganization

### **NOTE** - Add note/warning

```php
@doc-update: [DEPLOY:CICD#L3100] NOTE Requires ImageMagick extension
```

**Use cases:**
- Important warnings
- Dependencies
- Breaking changes
- Configuration requirements

---

## [VALIDATION:RULES] [L180]

### **Format validation:**

```yaml
@session:
  - Format: YYYY-MM-DD-NNN
  - Example: 2025-11-15-001
  - Regex: ^\d{4}-\d{2}-\d{2}-\d{3}$

@type:
  - Must be in allowed types list
  - Case-sensitive
  
@file:
  - Must be relative path from project root
  - Must exist in filesystem
  - No leading slash
  
@refs:
  - Format: [MARKER#LINE] or [MARKER#LINE, MARKER#LINE]
  - Markers must exist in MASTER.md
  - Line numbers optional (parser finds them)
  
@doc-update:
  - Format: [MARKER#LINE] ACTION details
  - ACTION must be in allowed actions
  - Marker must exist in MASTER.md
  
@tests:
  - Format: ClassName::methodName
  - Multiple allowed (comma-separated)
```

### **Structural validation:**

1. Must start with `@meta-start`
2. Must end with `@meta-end`
3. All required fields present
4. No duplicate fields (except @doc-update, @refs, @tests)
5. Fields in any order (except delimiters)

### **Reference validation:**

1. `@refs` markers exist in MASTER.md
2. `@doc-update` markers exist in MASTER.md
3. `@file` path exists
4. `@type` matches file location
   - models → app/Models
   - migrations → database/migrations
   - etc.

---

## [EXAMPLES:COMPLETE] [L230]

### **Example 1: Create model with relationship**

```php
// File: app/Models/Note.php

/**
 * @meta-start
 * @session: 2025-11-15-001
 * @type: model
 * @file: app/Models/Note.php
 * @feature: notes-system
 * @refs: [DB:SCHEMA_NOTES#L610], [ARCH:MODELS#L950]
 * @changes: Created Note model with user and tags relationships, soft deletes enabled
 * @doc-update: [ROADMAP:MVP#L3340] MARK notes-crud IN_PROGRESS
 * @doc-update: [ARCH:MODELS#L950] ADD Note model with BelongsTo user, BelongsToMany tags
 * @tests: NoteTest::test_create_note, NoteTest::test_attach_tags, NoteTest::test_soft_delete
 * @meta-end
 */

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

// Modelo: Notas del usuario con sistema de tags
class Note extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'content',
        'date',
        'is_pinned',
    ];

    protected $casts = [
        'date' => 'date',
        'is_pinned' => 'boolean',
    ];

    // RelaciÃ³n: Nota pertenece a un usuario
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // RelaciÃ³n: Nota tiene muchos tags
    public function tags()
    {
        return $this->belongsToMany(Tag::class, 'notes_tags');
    }
}
```

### **Example 2: Create migration**

```php
// File: database/migrations/2025_11_15_000001_create_notes_table.php

/**
 * @meta-start
 * @session: 2025-11-15-001
 * @type: migration
 * @file: database/migrations/2025_11_15_000001_create_notes_table.php
 * @feature: notes-system
 * @refs: [DB:SCHEMA_NOTES#L610]
 * @changes: Created notes table with all MVP fields, indexes on user_id and date
 * @doc-update: [DB:SCHEMA_NOTES#L610] UPDATE status:planned→implemented
 * @doc-update: [ROADMAP:MVP#L3340] MARK db-schema-notes DONE
 * @meta-end
 */

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('notes')) {
            Schema::create('notes', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('title');
                $table->text('content')->nullable();
                $table->date('date')->nullable();
                $table->boolean('is_pinned')->default(false);
                $table->timestamps();
                $table->softDeletes();

                // Ã­ndices para optimizar queries
                $table->index('user_id');
                $table->index('date');
                $table->index(['user_id', 'is_pinned']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('notes');
    }
};
```

### **Example 3: Vue component**

```vue
<!-- File: resources/js/Components/NoteCard.vue -->

<!--
@meta-start
@session: 2025-11-15-002
@type: component
@file: resources/js/Components/NoteCard.vue
@feature: notes-system
@refs: [ARCH:COMPONENTS#L1150]
@changes: Created NoteCard component with pin/unpin, edit, delete actions
@doc-update: [ARCH:COMPONENTS#L1150] ADD NoteCard displays note with actions toolbar
@doc-update: [ROADMAP:MVP#L3340] MARK notes-ui IN_PROGRESS
@meta-end
-->

<script setup>
import { router } from '@inertiajs/vue3'

const props = defineProps({
  note: Object,
  canEdit: Boolean
})

const emit = defineEmits(['pin', 'delete'])

const togglePin = () => {
  emit('pin', props.note.id)
}

const deleteNote = () => {
  if (confirm('¿Eliminar esta nota?')) {
    emit('delete', props.note.id)
  }
}
</script>

<template>
  <div class="bg-white rounded-lg shadow p-4">
    <h3 class="font-bold text-lg">{{ note.title }}</h3>
    <p class="text-gray-600 mt-2">{{ note.content }}</p>
    
    <div v-if="canEdit" class="flex gap-2 mt-4">
      <button @click="togglePin" class="text-sm text-blue-600">
        {{ note.is_pinned ? 'Desanclar' : 'Anclar' }}
      </button>
      <button @click="deleteNote" class="text-sm text-red-600">
        Eliminar
      </button>
    </div>
  </div>
</template>
```

### **Example 4: Config change**

```php
// File: config/filesystems.php

/**
 * @meta-start
 * @session: 2025-11-15-003
 * @type: config
 * @file: config/filesystems.php
 * @feature: user-avatar
 * @changes: Added avatars disk for user profile images
 * @doc-update: [ARCH:STORAGE#L1100] ADD avatars disk (local/public, max 2MB)
 * @doc-update: [DEPLOY:SERVER#L3150] NOTE Requires storage:link artisan command
 * @meta-end
 */

return [
    'disks' => [
        'avatars' => [
            'driver' => 'local',
            'root' => storage_path('app/public/avatars'),
            'url' => env('APP_URL').'/storage/avatars',
            'visibility' => 'public',
        ],
    ],
];
```

### **Example 5: Multiple doc updates**

```php
// File: app/Services/PointsService.php

/**
 * @meta-start
 * @session: 2025-11-15-004
 * @type: service
 * @file: app/Services/PointsService.php
 * @feature: gamification
 * @refs: [DB:SCHEMA_POINTS#L750], [ARCH:SERVICES#L1050]
 * @changes: Created PointsService to handle user points and level calculations
 * @doc-update: [ARCH:SERVICES#L1050] ADD PointsService handles award/deduct/level_up
 * @doc-update: [ROADMAP:MVP#L3380] MARK gamification-points IN_PROGRESS
 * @doc-update: [BUSINESS:RULES#L2100] ADD Points formula: level = floor(sqrt(points/100))
 * @tests: PointsServiceTest::test_award_points, PointsServiceTest::test_level_calculation
 * @meta-end
 */

namespace App\Services;

use App\Models\User;
use App\Models\PointsLog;

// Servicio: Gestión de puntos y niveles de gamificación
class PointsService
{
    // Otorgar puntos al usuario
    public function award(User $user, int $points, string $reason): void
    {
        $user->increment('points', $points);
        
        PointsLog::create([
            'user_id' => $user->id,
            'points' => $points,
            'reason' => $reason,
        ]);
        
        $this->checkLevelUp($user);
    }
    
    // Calcular nivel según puntos: level = âˆš(points/100)
    protected function checkLevelUp(User $user): void
    {
        $newLevel = (int) floor(sqrt($user->points / 100));
        
        if ($newLevel > $user->level) {
            $user->update(['level' => $newLevel]);
            // TODO: Trigger level up event
        }
    }
}
```

---

## [PARSER:IMPLEMENTATION] [L440]

### **Required functions:**

```powershell
# 08_PARSER.ps1

function Extract-MetaBlock($filePath)
  - Read file content
  - Find @meta-start to @meta-end
  - Return block as object
  
function Validate-MetaBlock($metaBlock)
  - Check required fields
  - Validate formats (regex)
  - Verify references exist
  - Return validation result
  
function Parse-DocUpdates($metaBlock)
  - Extract @doc-update lines
  - Parse ACTION and details
  - Find marker locations in MASTER.md
  - Return update operations
  
function Apply-DocUpdates($updates)
  - Read MASTER.md
  - For each update:
    - Find marker location
    - Apply action (ADD/UPDATE/REMOVE/MARK/MOVE/NOTE)
    - Update line numbers if needed
  - Write updated MASTER.md
  
function Log-ParserActivity($result)
  - Append to docs/logs/parser.log
  - Format: [timestamp] [file] [action] [result]
```

### **Error handling:**

```powershell
Try {
    $meta = Extract-MetaBlock $file
    $valid = Validate-MetaBlock $meta
    
    if (-not $valid.IsValid) {
        Log-Error "Invalid @meta block: $($valid.Errors)"
        return
    }
    
    $updates = Parse-DocUpdates $meta
    Apply-DocUpdates $updates
    
    # Call existing update script
    .\update_docs.ps1 -Update
    
    Log-Success "Updated MASTER.md from $file"
}
Catch {
    Log-Error "Parser failed: $_"
}
```

---

## [WATCHER:IMPLEMENTATION] [L495]

### **Required functions:**

```powershell
# 07_WATCHER.ps1

function Start-FileWatcher
  - Watch: app/, database/, config/, routes/, resources/js/
  - Filter: *.php, *.vue
  - Debounce: 2 seconds
  - On change → Check-MetaBlock
  
function Check-MetaBlock($filePath)
  - Read file
  - Search for @meta-start
  - If found → Call Parser
  - If not → Ignore
  
function Get-WatchConfig
  - Return folders to watch
  - Return file extensions
  - Return debounce time
```

### **Debounce logic:**

```powershell
$lastChange = @{}
$debounceMs = 2000

$watcher.Changed += {
    $file = $_.FullPath
    $now = Get-Date
    
    if ($lastChange[$file] -and 
        ($now - $lastChange[$file]).TotalMilliseconds -lt $debounceMs) {
        return # Ignore, too soon
    }
    
    $lastChange[$file] = $now
    Check-MetaBlock $file
}
```

---

## [WORKFLOW:COMPLETE] [L540]

### **Developer workflow (JosÃ©):**

1. Opens Claude conversation
2. Pastes `04_SESSION_START.md`
3. Requests: "Create Note model with tags"
4. Claude generates code WITH @meta block
5. JosÃ© copies code
6. Saves to `app/Models/Note.php`
7. **AUTOMATIC FROM HERE:**
   - Watcher detects save
   - Waits 2 seconds (debounce)
   - Calls parser
   - Parser validates @meta
   - Parser updates MASTER.md
   - update_docs.ps1 versions
   - Optional: git commit
8. JosÃ© sees console notification: "âœ… Updated MASTER.md"
9. Continues coding

### **Claude workflow:**

1. Receives request: "Create Note model"
2. Checks `03_PROMPTS.md` for rules
3. Generates code following conventions
4. Adds @meta block with:
   - Current session ID
   - File path
   - Relevant @refs from MASTER.md
   - @doc-update for affected sections
5. Returns complete code
6. JosÃ© handles the rest

### **Documentation workflow:**

1. MASTER.md is source of truth
2. Code changes auto-update MASTER.md
3. update_docs.ps1 versions everything
4. Git tracks all changes
5. Perfect traceability
6. Zero manual intervention

---

## [INTEGRATION:UPDATE_DOCS] [L585]

### **How parser calls update_docs.ps1:**

```powershell
# At end of Apply-DocUpdates function:

# Update MASTER.md directly
Set-Content -Path $masterPath -Value $updatedContent

# Call update script
& "$PSScriptRoot\update_docs.ps1" -Update

Write-Host "âœ… Auto-updated MASTER.md from @meta block"
```

### **What update_docs.ps1 does:**

1. Reads MASTER.md, CONTEXT.md, PROMPTS.md
2. Counts lines
3. Bumps version (patch)
4. Adds entry to CONTEXT.md changelog:
   ```markdown
   ## [v2.1.1] - 2025-11-15 14:23:45
   
   **Changes:**
   - [AUTO] Updated [DB:SCHEMA_NOTES#L610] from Note.php
   - Status: planned → implemented
   
   **Modified files:**
   - 01_MASTER_DOC.md
   ```
5. Updates meta.json
6. Saves all files

### **Result:**

- MASTER.md updated with code changes
- Version bumped automatically
- Full changelog maintained
- Metadata tracked
- Zero manual work

---

## [LOGGING:SYSTEM] [L630]

### **Parser log format:**

```
docs/logs/parser.log

[2025-11-15 14:23:45] [app/Models/Note.php] [VALIDATE] âœ… Valid @meta block
[2025-11-15 14:23:45] [app/Models/Note.php] [PARSE] Found 2 @doc-update lines
[2025-11-15 14:23:45] [app/Models/Note.php] [UPDATE] [ROADMAP:MVP#L3340] MARK IN_PROGRESS
[2025-11-15 14:23:45] [app/Models/Note.php] [UPDATE] [ARCH:MODELS#L950] ADD Note model
[2025-11-15 14:23:45] [app/Models/Note.php] [SUCCESS] âœ… MASTER.md updated
[2025-11-15 14:23:45] [app/Models/Note.php] [VERSION] v2.1.0 → v2.1.1
```

### **Watcher log format:**

```
docs/logs/watcher.log

[2025-11-15 14:23:43] [START] Watching: app/, database/, config/, resources/js/
[2025-11-15 14:23:45] [DETECT] app/Models/Note.php changed
[2025-11-15 14:23:47] [DEBOUNCE] 2s passed, processing...
[2025-11-15 14:23:47] [FOUND] @meta block detected
[2025-11-15 14:23:47] [CALL] Parser started
[2025-11-15 14:23:48] [DONE] Parser finished successfully
```

### **Error log format:**

```
docs/logs/parser-errors.log

[2025-11-15 15:10:22] [app/Models/User.php] [ERROR] Missing required field: @session
[2025-11-15 15:12:05] [app/Models/Tag.php] [ERROR] Invalid @session format: 2025-11-15
[2025-11-15 15:15:33] [database/migrations/create_notes.php] [ERROR] Marker not found: [DB:NOTES#L999]
```

---

## [GIT:INTEGRATION] [L665]

### **Optional auto-commit:**

```powershell
# At end of parser, if git enabled:

if ($GitAutoCommit) {
    git add docs/01_MASTER_DOC.md
    git add docs/02_CONTEXT.md
    git add docs/meta.json
    git commit -m "[AUTO] Updated docs from $fileName
    
Session: $session
Changes: $changes
"
    
    Write-Host "âœ… Auto-committed to git"
}
```

### **Commit message format:**

```
[AUTO] Updated docs from app/Models/Note.php

Session: 2025-11-15-001
Changes: Created Note model with user and tags relationships

Updated sections:
- [ROADMAP:MVP#L3340] MARK notes-crud IN_PROGRESS
- [ARCH:MODELS#L950] ADD Note model

Version: v2.1.0 → v2.1.1
```

### **Configuration:**

```powershell
# In 07_WATCHER.ps1

$config = @{
    GitAutoCommit = $true  # Enable/disable
    GitAutoPush = $false   # Don't auto-push (requires manual)
}
```

---

## [EDGE:CASES] [L710]

### **Multiple files saved quickly:**

- Watcher debounces each file independently
- Parser queues updates
- Applies in order
- Single version bump at end

### **Invalid @meta block:**

- Parser logs error
- Skips auto-update
- Notifies JosÃ© in console
- JosÃ© fixes manually
- Re-saves file

### **Marker not found:**

- Parser logs error
- Asks JosÃ© to verify marker exists
- Skips that specific @doc-update
- Continues with other updates

### **Conflicting updates:**

- If two files update same line
- Last write wins (file timestamp order)
- Manual resolution needed
- Git shows conflict

### **Parser crashes:**

- Error logged
- Watcher continues running
- Next file triggers retry
- JosÃ© gets notification

---

## [PERFORMANCE] [L750]

### **Optimization strategies:**

1. **Cache MASTER.md in memory**
   - Parser loads once
   - Reuses for multiple updates
   - Reloads only on version change

2. **Batch updates**
   - If multiple files saved < 5s
   - Collect all @doc-updates
   - Apply in single pass
   - Single version bump

3. **Lazy validation**
   - Quick format checks first
   - Deep validation only if format valid
   - Skip expensive checks on invalid blocks

4. **Incremental search**
   - Index markers on MASTER.md load
   - Quick lookup by marker name
   - No full file scan each time

### **Expected performance:**

- Single update: < 1 second
- Batch (5 files): < 3 seconds
- Validation: < 100ms
- Marker lookup: < 50ms

---

## [TESTING:STRATEGY] [L785]

### **Test scenarios:**

1. **Valid @meta block**
   - Should parse correctly
   - Should update MASTER.md
   - Should version bump
   - Should log success

2. **Missing required field**
   - Should fail validation
   - Should log error
   - Should NOT update MASTER.md

3. **Invalid marker reference**
   - Should fail validation
   - Should log error with marker name
   - Should skip that update

4. **Multiple @doc-updates**
   - Should apply all in order
   - Should handle ADD + MARK together
   - Should update correctly

5. **Concurrent saves**
   - Should debounce
   - Should queue updates
   - Should not conflict

6. **Parser crash**
   - Should log error
   - Should not corrupt MASTER.md
   - Should recover on next run

### **Test files:**

```
tests/parser/
  âœ… valid_meta_block.php
  âœ… missing_session.php
  âœ… invalid_marker.php
  âœ… multiple_updates.php
  âœ… concurrent_saves.php
```

---

## [DEPLOYMENT:SETUP] [L830]

### **Installation steps:**

1. **Enable PowerShell scripts:**
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
   ```

2. **Install dependencies:**
   - None required (native PowerShell)

3. **Start watcher:**
   ```powershell
   cd C:/Users/JoseA/Projects/hub-personal/docs
   .\07_WATCHER.ps1 -Start
   ```

4. **Configure auto-start:**
   - Add to Windows Task Scheduler
   - Or: Add to VS Code workspace settings

### **VS Code integration:**

```json
{
  "tasks": [
    {
      "label": "Start Doc Watcher",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-File",
        "${workspaceFolder}/docs/07_WATCHER.ps1",
        "-Start"
      ],
      "runOptions": {
        "runOn": "folderOpen"
      }
    }
  ]
}
```

---

## [CONFIGURATION] [L870]

### **Watcher config:**

```powershell
# 07_WATCHER.ps1 config section

$config = @{
    # Folders to watch (relative to project root)
    WatchFolders = @(
        'app',
        'database/migrations',
        'database/seeders',
        'config',
        'routes',
        'resources/js/Pages',
        'resources/js/Components'
    )
    
    # File extensions to monitor
    FileExtensions = @('*.php', '*.vue')
    
    # Debounce time (milliseconds)
    DebounceMs = 2000
    
    # Git integration
    GitAutoCommit = $true
    GitAutoPush = $false
    
    # Logging
    LogLevel = 'INFO'  # DEBUG, INFO, WARN, ERROR
    LogPath = 'docs/logs/watcher.log'
    ErrorLogPath = 'docs/logs/parser-errors.log'
    
    # Notifications
    ShowConsoleNotifications = $true
    ShowToastNotifications = $false  # Windows 10+ toast
}
```

### **Parser config:**

```powershell
# 08_PARSER.ps1 config section

$config = @{
    # Validation strictness
    StrictValidation = $true
    AllowOptionalFields = $true
    
    # Performance
    CacheMaster = $true
    CacheDurationMinutes = 5
    BatchUpdates = $true
    BatchWindowSeconds = 5
    
    # Backup
    BackupBeforeUpdate = $true
    BackupPath = 'docs/backups'
    MaxBackups = 10
    
    # Logging
    LogLevel = 'INFO'
    LogPath = 'docs/logs/parser.log'
}
```

---

## [MIGRATION:FROM_MANUAL] [L925]

### **For existing files without @meta:**

1. **Don't touch existing files**
   - No need to add @meta retroactively
   - Only new/modified files need @meta

2. **Progressive adoption:**
   - Start with new features
   - Add @meta to files as you edit them
   - Old files stay manual update

3. **Bulk migration (optional):**
   ```powershell
   # Script to add basic @meta to existing files
   .\scripts\add_meta_to_existing.ps1
   ```
   - Generates basic @meta blocks
   - JosÃ© reviews and commits
   - One-time operation

### **Hybrid workflow:**

- New code: Auto-update via @meta
- Old code: Manual update via update_docs.ps1
- Both work together
- Gradual transition

---

## [FUTURE:ENHANCEMENTS] [L955]

**Potential improvements:**

1. **AI-assisted @doc-update:**
   - Claude suggests @doc-update lines
   - Based on code analysis
   - JosÃ© reviews before save

2. **Bidirectional sync:**
   - MASTER.md changes → Code comments
   - Keep everything in sync
   - Complex but powerful

3. **Visual dashboard:**
   - Web UI showing parser activity
   - Real-time updates
   - Git history visualization

4. **Cross-file validation:**
   - Check relationship consistency
   - Verify migrations match models
   - Detect orphaned @refs

5. **Export to other formats:**
   - Generate API docs from @meta
   - Create changelog from commits
   - Build deployment checklist

---

## [FAQ] [L990]

**Q: What if I forget to add @meta?**  
A: No problem. File saves normally. No auto-update happens. Update manually with `update_docs.ps1 -Update`.

**Q: Can I disable auto-update temporarily?**  
A: Yes. Stop watcher with Ctrl+C. Restart when ready.

**Q: What if parser makes a mistake?**  
A: Check `docs/backups/`. Parser backs up MASTER.md before each update. Restore if needed.

**Q: Can I review changes before commit?**  
A: Yes. Set `GitAutoCommit = $false`. Review in git diff, then commit manually.

**Q: What if two files update the same line?**  
A: Last save wins. Git shows conflict. Resolve manually.

**Q: Is this Windows-only?**  
A: Currently yes (PowerShell). Linux/Mac version possible with bash rewrite.

**Q: Performance impact?**  
A: Minimal. Watcher uses ~5MB RAM. Parser runs < 1 second.

**Q: Can Claude use this too?**  
A: Yes! Claude generates @meta blocks. Parser does the rest.

---

## [CHECKLIST:IMPLEMENTATION] [L1025]

**To implement this protocol:**

```
â–¡ 1. Create 06_METADATA_PROTOCOL.md (this file) âœ…
â–¡ 2. Create 07_WATCHER.ps1 (file system watcher)
â–¡ 3. Create 08_PARSER.ps1 (metadata parser)
â–¡ 4. Update 03_PROMPTS.md (add @meta rules for Claude)
â–¡ 5. Update 04_SESSION_START.md (explain protocol)
â–¡ 6. Create docs/logs/ directory
â–¡ 7. Create docs/backups/ directory
â–¡ 8. Test with sample files
â–¡ 9. Fix bugs
â–¡ 10. Start using in real development
```

**Next immediate step:**
Create `07_WATCHER.ps1`

---

**[PROTOCOL:COMPLETE]** [L1045]

Specification finalized.
Ready for implementation.
