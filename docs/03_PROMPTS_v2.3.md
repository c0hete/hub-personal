# [PROMPTS] HUBPERSONAL - AGENT RULES

**Version:** 2.1  
**Last Update:** 2025-11-03  
**Format:** Clean (rules only)

---

## [HOWTO:USE] [L10]

**Purpose:**
- Define agent behavior
- Code conventions
- Auto-update rules
- Consistent patterns

**For Claude:**
- Follow these rules ALWAYS
- Update CONTEXT when making changes
- Maintain MASTER sync
- Auto-version on updates

---

## [RULES:FILE_HEADERS] [L30]

**ALWAYS add file path comment at top:**

```php
// File: app/Models/Note.php
```

```vue
<!-- File: resources/js/Pages/Notes/Index.vue -->
```

```js
// File: resources/js/Stores/notes.js
```

---

## [RULES:NAMING] [L50]

**Models:** English, singular, PascalCase
```php
User, Note, Tag, EmailAccount
```

**Controllers:** English, PascalCase + Controller
```php
NoteController, CalendarController
```

**Vue Pages:** English, PascalCase
```
Notes/Index.vue, Calendar/Month.vue
```

**Vue Components:** English, PascalCase
```
NoteCard.vue, TagInput.vue, PointsCounter.vue
```

**Stores:** English, camelCase
```js
notes.js, calendar.js, user.js
```

**Composables:** English, camelCase, use prefix
```js
useNotes.js, useCalendar.js, useAuth.js
```

**Database tables:** English, snake_case, plural
```sql
users, notes, tags, email_accounts
```

**Database columns:** English, snake_case
```sql
user_id, created_at, is_pinned
```

---

## [RULES:MIGRATIONS] [L100]

**ALWAYS check table existence:**

```php
// File: database/migrations/2025_11_03_create_notes_table.php

public function up() {
    if (!Schema::hasTable('notes')) {
        Schema::create('notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title', 200)->nullable();
            $table->text('content');
            $table->timestamps();
        });
    }
}

public function down() {
    Schema::dropIfExists('notes');
}
```

**NEVER run migrations directly**
- Use: `php artisan migrate`
- Check: Existing migrations first
- Test: In local/staging before production

---

## [RULES:BLADE] [L135]

**Structure:**

```blade
@extends('layouts.app')

@section('content')
    @include('layouts.navbar')
    
    <div class="container mx-auto px-4 py-8">
        <!-- Content -->
    </div>
    
    @include('layouts.footer')
@endsection
```

---

## [RULES:VUE_COMPONENTS] [L155]

**Structure:**

```vue
<!-- File: resources/js/Components/NoteCard.vue -->

<script setup>
import { ref, computed } from 'vue'

// Props
defineProps({
  note: {
    type: Object,
    required: true
  }
})

// Emits
defineEmits(['update', 'delete'])

// State
const isEditing = ref(false)

// Computed
const formattedDate = computed(() => {
  // Logic
})

// Methods
function handleEdit() {
  isEditing.value = true
}
</script>

<template>
  <div class="note-card">
    <h3>{{ note.title }}</h3>
    <p>{{ note.content }}</p>
  </div>
</template>

<style scoped>
.note-card {
  @apply bg-white rounded-lg shadow p-6;
}
</style>
```

**Order:**
1. Imports
2. Props
3. Emits
4. State (ref)
5. Computed
6. Methods
7. Lifecycle hooks

---

## [RULES:INERTIA_PAGES] [L215]

**Structure:**

```vue
<!-- File: resources/js/Pages/Notes/Index.vue -->

<script setup>
import { Head, router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import NoteCard from '@/Components/NoteCard.vue'

// Props from controller
defineProps({
  notes: Array
})

// Methods
function createNote() {
  router.visit('/notes/create')
}
</script>

<template>
  <AppLayout>
    <Head title="Notes" />
    
    <div class="notes-page">
      <h1>My Notes</h1>
      
      <NoteCard 
        v-for="note in notes" 
        :key="note.id"
        :note="note"
      />
    </div>
  </AppLayout>
</template>
```

---

## [RULES:CONTROLLERS] [L260]

**Structure:**

```php
// File: app/Http/Controllers/NoteController.php

namespace App\Http\Controllers;

use App\Models\Note;
use Illuminate\Http\Request;
use Inertia\Inertia;

class NoteController extends Controller
{
    public function index()
    {
        return Inertia::render('Notes/Index', [
            'notes' => Note::with('tags')
                ->where('user_id', auth()->id())
                ->latest()
                ->get(),
        ]);
    }
    
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'nullable|string|max:200',
            'content' => 'required|string',
        ]);
        
        $note = auth()->user()->notes()->create($validated);
        
        return redirect()->route('notes.index');
    }
}
```

**Patterns:**
- Use Inertia::render() for pages
- Eager load relationships
- Validate input
- Use route names in redirects

---

## [RULES:MODELS] [L310]

**Structure:**

```php
// File: app/Models/Note.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Note extends Model
{
    use SoftDeletes;
    
    protected $fillable = [
        'title',
        'content',
        'date',
        'is_pinned',
    ];
    
    protected $casts = [
        'date' => 'date',
        'is_pinned' => 'boolean',
    ];
    
    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    public function tags()
    {
        return $this->belongsToMany(Tag::class);
    }
    
    // Scopes
    public function scopePinned($query)
    {
        return $query->where('is_pinned', true);
    }
}
```

**Order:**
1. Use statements
2. Protected properties ($fillable, $casts)
3. Relations
4. Scopes
5. Accessors/Mutators
6. Methods

---

## [RULES:PINIA_STORES] [L375]

**Structure:**

```js
// File: resources/js/Stores/notes.js

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'

export const useNotesStore = defineStore('notes', () => {
  // State
  const notes = ref([])
  const loading = ref(false)
  
  // Getters
  const pinnedNotes = computed(() => 
    notes.value.filter(n => n.is_pinned)
  )
  
  // Actions
  async function fetchNotes() {
    loading.value = true
    try {
      const { data } = await axios.get('/api/notes')
      notes.value = data
    } finally {
      loading.value = false
    }
  }
  
  function addNote(note) {
    notes.value.unshift(note)
  }
  
  return { 
    notes, 
    loading, 
    pinnedNotes, 
    fetchNotes, 
    addNote 
  }
})
```

**Composition API style:**
- State: ref()
- Getters: computed()
- Actions: functions
- Return: all public items

---

## [RULES:TESTING] [L435]

**Use Pest syntax:**

```php
// File: tests/Feature/NoteTest.php

test('user can create note', function () {
    $user = User::factory()->create();
    
    actingAs($user)->post('/notes', [
        'title' => 'Test Note',
        'content' => 'Content',
    ])->assertRedirect('/notes');
    
    expect($user->notes()->count())->toBe(1);
});

test('user cannot create note without content', function () {
    $user = User::factory()->create();
    
    actingAs($user)->post('/notes', [
        'title' => 'Test',
    ])->assertSessionHasErrors('content');
});
```

---

## [RULES:CODE_STYLE] [L470]

**PSR-12:**
- 4 spaces (no tabs)
- Opening braces on new line (classes/functions)
- No trailing whitespace

**Commands:**
```bash
./vendor/bin/pint              # Auto-format
./vendor/bin/pint --test       # Check only
```

**Before every commit:**
```bash
./vendor/bin/pint
php artisan test
```

---

## [RULES:COMMENTS] [L495]

**Spanish for business logic:**

```php
// Verificar si el usuario tiene permisos
if ($user->can('edit', $note)) {
    // Actualizar nota
    $note->update($data);
}
```

**English for technical:**

```php
// Eager load relationships to avoid N+1
$notes = Note::with('tags', 'user')->get();
```

---

## [RULES:GIT_COMMITS] [L515]

**Format:**
```
type(scope): message

feat(notes): add note pinning functionality
fix(calendar): resolve date formatting issue
docs(readme): update installation steps
refactor(auth): simplify login logic
test(notes): add note creation tests
```

**Types:**
- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code refactor
- test: Tests
- chore: Maintenance

**CRITICAL:**
- ❌ NO emojis in commit messages
- ❌ NO stickers or icons
- ✅ Plain text only
- ✅ English language
- ✅ Clear and concise

---

## [RULES:DOCUMENTATION_UPDATES] [L545]

**When modifying MASTER.md:**

1. Update version in meta.json
```json
{
  "version": "2.2.0",
  "last_modified": "2025-11-03T15:30:00Z"
}
```

2. Add entry to CONTEXT.md [CHANGELOG:MASTER]
```markdown
### v2.2.0 - 2025-11-03
**Changes:**
- Added: Email sync feature
- Modified: [DB:SCHEMA_EMAIL] L700
```

3. Update [UPDATES:LOG] in CONTEXT.md
```markdown
### 2025-11-03 15:30
**Action:** Added email feature to MASTER
**Modified:** [DB:SCHEMA_EMAIL] L700-750
```

4. If sections move, update INDEX.md line numbers

---

## [RULES:CODE_CHANGES] [L580]

**When creating/modifying files:**

1. Add file path comment
2. Follow naming conventions
3. Run Pint before commit
4. Write test if feature
5. Update CONTEXT if significant change

**Significant changes:**
- New database table
- New feature/module
- Breaking change
- Architecture decision

---

## [RULES:FILE_CREATION_WORKFLOW] [L610]

**ALWAYS provide creation command BEFORE code:**

### Controllers
```bash
php artisan make:controller NoteController --resource
```

### Models
```bash
php artisan make:model Note
# With migration
php artisan make:model Note -m
# With factory and seeder
php artisan make:model Note -mfs
```

### Migrations
```bash
php artisan make:migration create_notes_table
php artisan make:migration add_column_to_notes_table --table=notes
```

### Policies
```bash
php artisan make:policy NotePolicy --model=Note
```

### Requests
```bash
php artisan make:request StoreNoteRequest
```

### Resources (API)
```bash
php artisan make:resource NoteResource
```

### Middleware
```bash
php artisan make:middleware CheckNoteOwnership
```

### Jobs
```bash
php artisan make:job ProcessNoteJob
```

### Events
```bash
php artisan make:event NoteCreated
```

### Listeners
```bash
php artisan make:listener SendNoteNotification --event=NoteCreated
```

### Vue Components/Pages
```bash
# Manual creation (Laravel doesn't have artisan for Vue)
# Path: resources/js/Components/NoteCard.vue
# Path: resources/js/Pages/Notes/Index.vue
```

**Workflow:**
1. Give artisan command
2. Show full code
3. User creates file
4. User copies code
5. User parses (if has @meta)

---

## [RULES:TESTING_URLS] [L710]

**ALWAYS provide testing URLs after feature completion:**

### Format:
```
## 🧪 Testing URLs

Base URL: http://localhost:8000

### Feature: Notes CRUD
- List:   http://localhost:8000/notes
- Create: http://localhost:8000/notes/create
- Edit:   http://localhost:8000/notes/{id}/edit

### Auth (if needed)
- Login:    http://localhost:8000/login
- Register: http://localhost:8000/register
```

### Testing checklist:
```bash
☐ php artisan serve running
☐ npm run dev running
☐ User authenticated
☐ Database migrated
☐ Test each route manually
```

---

## [RULES:DEPENDENCIES] [L760]

**NEVER use undocumented dependencies without verification:**

### Check MASTER.md first:

**PowerShell command:**
```powershell
Select-String -Path "docs/01_MASTER_DOC.md" -Pattern "package-name"
```

**Linux/Mac:**
```bash
grep -n "package-name" docs/01_MASTER_DOC.md
```

### If package NOT found in MASTER.md:

**ASK user:**
```
Package NOT documented: @heroicons/vue
Purpose: SVG icons
Size: ~50KB

Options:
A) Install and document
B) Use alternative (emojis/CSS)
C) Cancel feature
```

### If approved:

**1. Install:**
```bash
npm install package-name
```

**2. Document with @meta:**
```json
/**
 * @meta-start
 * @session: YYYY-MM-DD-NNN
 * @file: package.json
 * @refs: [STACK:DEPENDENCIES]
 * @changes: Added package-name for purpose
 * @doc-update: [STACK:DEPENDENCIES] ADD package-name ^version
 * @meta-end
 */
```

**3. Parse:**
```bash
cd docs
.\08_PARSER.ps1 -File "..\package.json"
```

### Core packages (always OK, no verification needed):

**✅ Auto-approved:**
- Laravel framework
- Vue 3 core
- Inertia.js
- Tailwind CSS
- Vite
- Dev tools (prettier, eslint, pint)

**❌ Always verify first:**
- UI libraries (icons, components)
- State management (beyond Pinia)
- HTTP clients (beyond axios)
- Utility libraries (beyond @vueuse)
- Packages >100KB

### PowerShell commands reference:

```powershell
# Search in file (like grep)
Select-String -Path "file.md" -Pattern "text"

# Search with line numbers
Get-Content file.md | Select-String "text" | Select-Object LineNumber, Line

# Case-insensitive
Select-String -Path "file.md" -Pattern "text" -CaseSensitive:$false
```

### CRITICAL rules:

- ❌ NEVER install without checking MASTER.md
- ❌ NEVER assume package is approved
- ✅ ALWAYS use Select-String (PowerShell) or grep (Linux/Mac)
- ✅ ALWAYS verify in [STACK:DEPENDENCIES]
- ✅ ALWAYS ask if not found
- ✅ ALWAYS document after approval

---

## [RULES:ERROR_HANDLING] [L850]

**Controllers:**

```php
try {
    $note = auth()->user()->notes()->create($data);
    return redirect()->route('notes.show', $note);
} catch (\Exception $e) {
    return back()->with('error', 'Failed to create note');
}
```

**Vue:**

```js
try {
  await store.createNote(data)
  router.visit('/notes')
} catch (error) {
  console.error('Failed to create note:', error)
  // Show toast notification
}
```

---

## [RULES:QUERIES] [L880]

**Avoid N+1:**

```php
// âŒ Bad
$notes = Note::all();
foreach ($notes as $note) {
    echo $note->user->name; // N queries
}

// âœ… Good
$notes = Note::with('user')->get();
foreach ($notes as $note) {
    echo $note->user->name; // 1 query
}
```

**Use eager loading:**
```php
Note::with('user', 'tags', 'category')->get();
```

---

## [RULES:SECURITY] [L905]

**Always authorize:**

```php
// Controller
$this->authorize('update', $note);

// Policy
public function update(User $user, Note $note): bool
{
    return $user->id === $note->user_id;
}
```

**Validate input:**

```php
$request->validate([
    'email' => 'required|email',
    'password' => 'required|min:8',
]);
```

**Mass assignment:**

```php
// Model
protected $fillable = ['title', 'content'];

// Or
protected $guarded = ['id', 'user_id'];
```

---

## [RULES:PERFORMANCE] [L940]

**Cache queries:**

```php
Cache::remember('user.notes.'.$userId, 300, fn() =>
    Note::where('user_id', $userId)->get()
);
```

**Paginate large datasets:**

```php
$notes = Note::paginate(20);
```

**Index frequently queried columns:**

```php
$table->index('user_id');
$table->index(['user_id', 'created_at']);
```

---

## [AUTO:BEHAVIOR] [L965]

**On every response:**
- Check [DECISIONS:TECHNICAL] in CONTEXT
- Follow [PATTERNS:CODE] in CONTEXT
- Maintain consistency with MASTER

**On code generation:**
- Add file path comment
- Follow naming conventions
- Include proper error handling
- Add comments for business logic

**On MASTER updates:**
- Version bump in meta.json
- Changelog entry in CONTEXT
- Log entry with timestamp
- Update INDEX if needed

---

## [RULES:FILE_DELIVERY] [L900]

**When providing files for download at session end:**

### Naming convention:
```
Core docs with version:
- 01_MASTER_DOC_v{VERSION}.md
- 03_PROMPTS_v{VERSION}.md

Migrations with date:
- 10_MIGRATION_{YYYY-MM-DD}.md

Always current (no version):
- 00_INDEX.md
- FILE_REGISTRY.md
- 06_METADATA_PROTOCOL.md
```

### Delivery package must include:

**1. Versioned files with current version/date**

**2. cleanup_old_versions.ps1 script**

**3. Installation instructions**

### CRITICAL rules:

- ALWAYS generate cleanup script
- ALWAYS update FILE_REGISTRY.md DEPRECATED section
- ALWAYS use version in filenames (except INDEX, REGISTRY, PROTOCOL)
- ALWAYS list old files to delete in cleanup script

---

**[PROMPTS:END]** [L930]
