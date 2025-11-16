# TEST EXAMPLE: Note Model with @meta block
# This is what the Note.php file should look like after adding @meta

---

## File Location:
```
app/Models/Note.php
```

---

## Complete File Content:

```php
<?php

// File: app/Models/Note.php

/**
 * @meta-start
 * @session: 2025-11-15-001
 * @file: app/Models/Note.php
 * @refs: [DB:SCHEMA_NOTES]
 * @changes: Added priority field and archived scope
 * @doc-update: [DB:SCHEMA_NOTES] ADD priority VARCHAR(10) DEFAULT 'medium'
 * @doc-update: [DB:SCHEMA_NOTES] ADD archived_at TIMESTAMP NULL
 * @meta-end
 */

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Note extends Model
{
    use SoftDeletes;
    
    protected $fillable = [
        'user_id',
        'category_id',
        'title',
        'content',
        'date',
        'time',
        'is_pinned',
        'color',
        'priority',        // NEW FIELD
        'reminder_minutes',
        'recurrence',
        'metadata',
    ];
    
    protected $casts = [
        'date' => 'date',
        'time' => 'datetime',
        'is_pinned' => 'boolean',
        'metadata' => 'array',
        'archived_at' => 'datetime',  // NEW FIELD
    ];
    
    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
    
    public function tags()
    {
        return $this->belongsToMany(Tag::class, 'notes_tags');
    }
    
    // Scopes
    public function scopePinned($query)
    {
        return $query->where('is_pinned', true);
    }
    
    public function scopeActive($query)
    {
        return $query->whereNull('archived_at');
    }
    
    public function scopeArchived($query)
    {
        return $query->whereNotNull('archived_at');
    }
}
```

---

## Testing Steps:

### 1. Start Watcher
```powershell
cd C:\Projects\hub-personal\docs
.\07_WATCHER.ps1 -Path "..\app" -Recursive
```

### 2. Edit Note.php
- Open: `C:\Projects\hub-personal\app\Models\Note.php`
- Add the @meta block shown above
- Save file (Ctrl+S)

### 3. Watch Console
Watcher should show:
```
[WAIT] Archivo detectado (esperando 1000 ms): ..\app\Models\Note.php
[INFO] Procesando: ..\app\Models\Note.php

--- @meta Block ---
Session: 2025-11-15-001
File: app/Models/Note.php
Changes: Added priority field and archived scope
Refs: DB:SCHEMA_NOTES
Updates: 2

Executing updates...
[INFO] [DB:SCHEMA_NOTES] ADD priority VARCHAR(10) DEFAULT 'medium'
[OK] Updated [DB:SCHEMA_NOTES] - ADD
[INFO] [DB:SCHEMA_NOTES] ADD archived_at TIMESTAMP NULL
[OK] Updated [DB:SCHEMA_NOTES] - ADD

[OK] Changelog entry added
[INFO] Calling update_docs.ps1...
[OK] Documentation versioned
[INFO] Auto-committing documentation changes...
[OK] Git commit created: docs: Auto-update from app/Models/Note.php - Added priority field and archived scope

=== Parser Statistics ===
Blocks found:    1
Blocks valid:    1
Updates executed: 2
Errors:          0

[OK] All updates completed successfully!
```

### 4. Verify Results

**Check MASTER.md:**
```powershell
# Should see new fields in [DB:SCHEMA_NOTES] section
code docs\01_MASTER_DOC.md
# Search for: [DB:SCHEMA_NOTES]
# Should contain:
#   priority VARCHAR(10) DEFAULT 'medium'
#   archived_at TIMESTAMP NULL
```

**Check Git:**
```powershell
git log -1
# Should show:
#   docs: Auto-update from app/Models/Note.php - Added priority field and archived scope

git diff HEAD~1 docs/01_MASTER_DOC.md
# Should show the additions
```

**Check Changelog:**
```powershell
code docs\02_CONTEXT.md
# Should have new entry at bottom with timestamp
```

---

## Expected Outcome:

1. File saved -> Watcher detects (1 second debounce)
2. Parser extracts @meta block
3. Validates all fields
4. Finds [DB:SCHEMA_NOTES] in MASTER.md
5. Adds priority field
6. Adds archived_at field
7. Calls update_docs.ps1 (versions to 2.1.1)
8. Creates git commit automatically
9. José continues coding - docs updated automatically!

---

## Troubleshooting:

### If watcher doesn't detect:
```powershell
# Check watcher is running
# Check file extension (.php is in allowed list)
# Check file path not in excluded paths
```

### If parser fails:
```powershell
# Run manually to see error:
.\08_PARSER.ps1 -File "..\app\Models\Note.php"

# Or validate only:
.\08_PARSER.ps1 -File "..\app\Models\Note.php" -Validate
```

### If marker not found:
```powershell
# Verify marker exists in MASTER.md:
Select-String -Path "01_MASTER_DOC.md" -Pattern "\[DB:SCHEMA_NOTES\]"
```

---

## Success Criteria:

- [x] Watcher detects file change
- [x] Parser extracts @meta successfully
- [x] Validation passes
- [x] MASTER.md updated with new fields
- [x] Version bumped (2.1.0 -> 2.1.1)
- [x] Changelog entry added
- [x] Git commit created automatically
- [x] No manual doc editing required

---

**READY TO TEST!**

This is the complete end-to-end workflow.
José just needs to save the file and watch the magic happen.
