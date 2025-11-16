# [CONTEXT] HUBPERSONAL - TECHNICAL LOG

**Version:** 2.1  
**Last Update:** 2025-11-03  
**Format:** Clean (markers + facts only)

---

## [HOWTO:USE] [L10]

**Purpose:**
- Technical decisions log
- Changelog (MASTER updates)
- Patterns reference
- Agent behavior rules

**Navigation:** Ctrl+F with `[DECISION:topic]` or `[PATTERN:topic]`

---

## [DECISIONS:TECHNICAL] [L30]

### [DECISION:MODELS_LANGUAGE] [L35]
**Rule:** English models, Spanish comments  
**Pattern:**
```php
// File: app/Models/Note.php
// Modelo: Notas del usuario
class Note extends Model {}
```

---

### [DECISION:MIGRATIONS_SAFETY] [L50]
**Rule:** Always check table existence  
**Pattern:**
```php
if (!Schema::hasTable('notes')) {
    Schema::create('notes', function (Blueprint $table) {
        // ...
    });
}
```

---

### [DECISION:FILE_HEADERS] [L65]
**Rule:** Path comment at top of every file  
**Pattern:**
```php
// File: app/Http/Controllers/NoteController.php
```
```vue
<!-- File: resources/js/Pages/Notes/Index.vue -->
```

---

### [DECISION:BLADE_STRUCTURE] [L80]
**Rule:** Extend `layouts.app`, include navbar  
**Pattern:**
```blade
@extends('layouts.app')
@section('content')
    @include('layouts.navbar')
    <!-- Content -->
@endsection
```

---

### [DECISION:CODE_STYLE] [L95]
**Rule:** PSR-12, 4 spaces, Laravel conventions  
**Command:** `./vendor/bin/pint`

---

### [DECISION:TESTING] [L105]
**Rule:** Pest (not PHPUnit)  
**Pattern:**
```php
test('user can create note', function() {
    // ...
});
```

---

### [DECISION:GIT_WORKFLOW] [L120]
**Branches:**
- `develop` → auto-deploy staging
- `main` → auto-deploy production
- `feature/*` → merge to develop
- `hotfix/*` → merge to main

---

## [PATTERNS:CODE] [L135]

### [PATTERN:CONTROLLER] [L140]
```php
// File: app/Http/Controllers/NoteController.php
use Inertia\Inertia;

public function index() {
    return Inertia::render('Notes/Index', [
        'notes' => Note::with('tags')->get(),
    ]);
}
```

---

### [PATTERN:VUE_COMPONENT] [L155]
```vue
<!-- File: resources/js/Components/NoteCard.vue -->
<script setup>
defineProps({ note: Object })
</script>

<template>
  <div class="note-card">
    {{ note.title }}
  </div>
</template>
```

---

### [PATTERN:MIGRATION] [L170]
```php
// File: database/migrations/2025_11_03_create_notes_table.php
public function up() {
    if (!Schema::hasTable('notes')) {
        Schema::create('notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title', 200)->nullable();
            $table->text('content');
            $table->date('date')->nullable();
            $table->timestamps();
        });
    }
}
```

---

## [CHANGELOG:MASTER] [L195]

### v2.1 - 2025-10-25
**Changes:**
- Removed: Livewire comparisons
- Removed: "Why" narratives
- Kept: 100% technical content
- Lines: 10,000 → 3,500 (65% reduction)

**Updated sections:**
- [STACK] L400-L550
- [DATABASE] L550-L900
- [ARCHITECTURE] L900-L1300

---

### v2.0 - 2025-10-25
**Changes:**
- Consolidated: 67 files → 1 MASTER.md
- Added: Marker-based navigation
- Format: English technical

**Sections:**
- 01_PRD
- 02_STACK
- 03_DATABASE
- 04_ARCHITECTURE
- 05_TESTING
- 06_DESIGN
- 07_AUTH
- 08_PERFORMANCE
- 09_DEPLOY
- 10_ROADMAP

---

## [UPDATES:LOG] [L240]

### 2025-11-03 15:00
**Action:** Cleaned CONTEXT.md  
**Removed:** Decision rationales, narratives  
**Format:** Markers + facts only  
**Lines:** 450 → 280

---

### 2025-10-25 14:30
**Action:** Cleaned MASTER.md v2.1  
**Removed:** [STACK:WHY_VUE] L750-850  
**Reason:** Eliminate rationale, keep facts

---

### 2025-10-25 14:00
**Action:** Added marker navigation  
**Tagged:** All sections with [L###]  
**Added:** [QUICK:], [SECTION:], [REF:]

---

### 2025-10-25 12:00
**Action:** Consolidated documentation  
**Created:** MASTER.md v2.0  
**Impact:** Single source of truth

---

## [AGENT:RULES] [L275]

**When updating MASTER.md:**
1. Update meta.json version
2. Add entry to [CHANGELOG:MASTER]
3. Log in [UPDATES:LOG] with timestamp
4. Update INDEX.md if sections change

**When coding:**
1. Check [DECISIONS:TECHNICAL] first
2. Follow [PATTERNS:CODE]
3. Add file path comment
4. Run `./vendor/bin/pint` before commit

**When answering "why":**
1. Check [DECISIONS:TECHNICAL]
2. Give technical reason
3. No philosophical explanations

---

## [TODO:PATTERNS] [L300]

**To document:**
- Vue component naming
- Pinia store structure
- Error handling
- Logging levels

---

**[CONTEXT:END]** [L310]

### v.1.1 - 2025-11-15 23:29
**Auto-update:** Documentation synchronized


### v0.0.1 - 2025-11-15 23:30
**Auto-update:** Documentation synchronized


### v2.1.1 - 2025-11-15 23:32
**Auto-update:** Documentation synchronized


### v2.1.2 - 2025-11-15 23:47
**Auto-update:** Documentation synchronized


### v2.1.3 - 2025-11-15 23:48
**Auto-update:** Documentation synchronized


### v2.1.4 - 2025-11-16 00:00
**Auto-update:** Documentation synchronized

