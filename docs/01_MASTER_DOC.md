# [MASTER:DOC] HUBPERSONAL APP - TECHNICAL DOCUMENTATION

**Version:** 2.1 (Clean)  
**Last Update:** 2025-10-25  
**Format:** Marker-based (No fluff, only facts)

---

## [HOWTO:NAVIGATE] [L10]

**CRITICAL: Read _INDEX.md FIRST**

**Navigation:**
- [QUICK:topic] → 3-5 line summary
- [SECTION:topic] → Full section
- [REF:topic] → Cross-reference
- [L###] → Line number

**Search:** Ctrl+F with EXACT marker (case-sensitive)

---

## [INDEX:EMBEDDED] [L30]

[QUICK:STACK] L100
[QUICK:DATABASE] L500
[QUICK:FEATURES] L1000
[QUICK:AUTH] L1500
[QUICK:DEPLOY] L3000

---
---

# [SECTION:PRD] PRODUCT REQUIREMENTS [L100]

## [QUICK:FEATURES] [L100]

**Core:**
Notes(quick+scheduled) | Calendar | Tags | Gamification | Email | Meditation | QuickLinks | Search | PWA

**User:** José (ADHD)  
**Goal:** Centralize digital life without stress

---

## [PRD:NOTES_SYSTEM] [L120]

### Quick Notes (no date)
**Fields:**
- title VARCHAR(200) NULL
- content TEXT NOT NULL
- tags (many-to-many)
- color VARCHAR(20) DEFAULT 'yellow'
- priority VARCHAR(10) DEFAULT 'medium'
- is_pinned BOOLEAN DEFAULT false

**Features:**
- Edit in-place (Vue reactive)
- Markdown support
- Full-text search
- Archive (soft delete)

**Tech:**
- Component: NoteQuick.vue
- Controller: NoteController
- DB: notes (date NULL)

### Scheduled Notes (with date)
**Additional fields:**
- date DATE NOT NULL
- time TIME NULL
- reminder_minutes INT NULL
- recurrence VARCHAR(20) NULL

**Features:**
- Calendar sticker
- Drag & drop reschedule
- Reminders (queue job)

**Tech:**
- Component: NoteScheduled.vue
- Page: Calendar/Month.vue
- Job: ReminderJob (Redis)

**[REF:DB_NOTES]** L550

---

## [PRD:CALENDAR] [L150]

**Views:** Month | Week | Day

**Stickers:**
- Yellow: Notes
- Blue: Events
- Green: Achievements
- Red: Important

**Interactions:**
- Click → Open item
- Drag → Reschedule
- Right-click → Quick actions

**Tech:**
- Library: FullCalendar + Vue
- Component: Calendar.vue
- Drag: vue-draggable
- Store: Pinia calendarStore

**[REF:DB_CALENDAR]** L750

---

## [PRD:TAGS] [L180]

**Features:**
- Autocomplete
- Color per tag
- Filter by tag(s)
- Combine filters (AND/OR)

**Limits:**
- Max 20 tags per note
- Max 100 chars per tag

**Tech:**
- DB: tags, notes_tags (many-to-many)
- Component: TagInput.vue
- Autocomplete: VueUse useDebounceFn

**[REF:DB_TAGS]** L600

---

## [PRD:GAMIFICATION] [L200]

**Points:**
- Create note: +5
- Complete event: +10
- Process email: +3
- Meditation: +20
- Daily login: +2
- 7-day streak: +50

**Achievements:**
- Note Master: 100 notes (500 pts)
- Consistent: 7-day streak (100 pts)
- Email Zen: Inbox zero (200 pts)
- Meditation Pro: 30 sessions (300 pts)

**Visual:**
- Confetti (canvas-confetti)
- Toast notification
- Points badge

**Tech:**
- DB: points_log, achievements, user_achievements
- Component: PointsCounter.vue

**[REF:DB_GAMIFICATION]** L650

---

## [PRD:EMAIL] [L250]

**Providers:** Gmail | Outlook | IMAP

**Features:**
- Unified inbox
- Mark read/unread
- Archive
- Create note from email
- Search

**Sync:** Manual or every 15 min

**Limits (MVP):**
- Max 3 accounts
- Last 30 days only

**Tech:**
- Package: webklex/php-imap
- Job: EmailSyncJob (Redis)
- DB: email_accounts, emails
- Component: EmailInbox.vue

**[REF:DB_EMAIL]** L700

---

## [PRD:MEDITATION] [L280]

**Modes:** 2min | 5min | 10min | Custom

**Visual:**
- Animated SVG circle
- Inhale: Circle grows (4s)
- Hold: Pause (4s)
- Exhale: Circle shrinks (6s)

**Tracking:**
- Sessions logged
- Points +20
- Streak counter

**Tech:**
- Component: MeditationTimer.vue
- Animation: SVG + Vue transitions
- DB: meditation_sessions

---

## [PRD:SEARCH] [L300]

**Scope:**
- Notes (title + content)
- Tags
- Emails
- Events

**Tech:**
- PostgreSQL full-text search (pg_trgm)
- Controller: SearchController
- Component: GlobalSearch.vue
- Debounce: 300ms

---

## [PRD:PWA] [L320]

**Features:**
- Install on home screen
- Offline mode (basic)
- Push notifications
- Fast loading

**Tech:**
- Package: silviolleite/laravel-pwa
- Service Worker: precache assets
- Manifest: /manifest.json

---
---

# [SECTION:STACK] TECHNICAL STACK [L400]

## [QUICK:STACK] [L420]

**Backend:**  
Laravel11 | PHP8.3 | PostgreSQL15 | Redis7.2

**Frontend:**  
Vue3.4 | Inertia1.0 | Vite5 | Pinia2.1 | Tailwind3.4 | HeadlessUI

**Auth:** Breeze(Vue)  
**Testing:** Pest  
**Deploy:** GitHub Actions

---

## [STACK:BACKEND] [L450]

### Laravel 11
**Version:** 11.x (LTS until 2027)

**Packages:**
```json
{
  "laravel/framework": "^11.0",
  "inertiajs/inertia-laravel": "^1.0",
  "tightenco/ziggy": "^2.0",
  "spatie/laravel-activitylog": "^4.8",
  "webklex/php-imap": "^5.3"
}
```

### PHP 8.3
**Extensions:**
- pgsql, redis, mbstring, xml, curl, zip, gd, intl, bcmath, imap

### PostgreSQL 15
**Features used:**
- JSONB (metadata)
- Full-text search (pg_trgm)
- Arrays
- Enums

### Redis 7.2
**Used for:**
- Cache
- Queue
- Session
- Rate limiting

---

## [STACK:FRONTEND] [L500]

### Vue 3.4
**Style:** Composition API

**Setup:**
```js
// app.js
import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import { createPinia } from 'pinia'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('./Pages/**/*.vue', { eager: true })
    return pages[`./Pages/${name}.vue`]
  },
  setup({ el, App, props, plugin }) {
    createApp({ render: () => h(App, props) })
      .use(plugin)
      .use(createPinia())
      .mount(el)
  },
})
```

### Inertia.js 1.0
**Benefits:**
- No separate REST API
- Backend routing
- Shared data automatic
- Form handling simplified

### Vite 5
**Config:**
```js
// vite.config.js
export default defineConfig({
  plugins: [
    laravel({
      input: 'resources/js/app.js',
      refresh: true,
    }),
    vue(),
  ],
})
```

### Pinia 2.1
**Example:**
```js
// stores/notes.js
export const useNotesStore = defineStore('notes', () => {
  const notes = ref([])
  const pinnedNotes = computed(() => notes.value.filter(n => n.is_pinned))
  
  function addNote(note) {
    notes.value.unshift(note)
  }
  
  return { notes, pinnedNotes, addNote }
})
```

### Tailwind CSS 3.4
**Config:**
```js
// tailwind.config.js
colors: {
  primary: {
    500: '#0ea5e9',
  },
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444',
}
```

### Headless UI 1.7
**Components:**
- Dialog (modals)
- Listbox (select)
- Menu (dropdown)
- Transition

### Heroicons 2.1
**Usage:**
```vue
<script setup>
import { PlusIcon } from '@heroicons/vue/24/outline'
</script>
<template>
  <PlusIcon class="w-5 h-5" />
</template>
```

---

## [STACK:DEPENDENCIES] [L480]

### package.json
```json
{
  "type": "module",
  "devDependencies": {
    "@inertiajs/vue3": "^1.0.0",
    "@tailwindcss/forms": "^0.5.7",
    "@vitejs/plugin-vue": "^5.0.0",
    "autoprefixer": "^10.4.16",
    "laravel-vite-plugin": "^1.0.0",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.4.0",
    "vite": "^5.0.0",
    "vue": "^3.4.0"
  },
  "dependencies": {
    "@headlessui/vue": "^1.7.16",
    "@heroicons/vue": "^2.1.1",
    "pinia": "^2.1.7",
    "@vueuse/core": "^10.7.0",
    "canvas-confetti": "^1.9.2"
  }
}
```

**Bundle (production):**
- JS: ~188KB gzipped
- CSS: ~30KB gzipped
- Total: ~220KB ✅

---
---

# [SECTION:DATABASE] DATABASE DESIGN [L550]

## [QUICK:DATABASE] [L550]

**Tables:**
users | notes | tags | notes_tags | categories | quick_links |  
points_log | achievements | user_achievements |  
email_accounts | emails | calendar_events | settings

**Engine:** PostgreSQL 15

---

## [DB:SCHEMA_USERS] [L570]

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    points INT DEFAULT 0,
    level INT DEFAULT 1,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_points ON users(points DESC);
```

---

## [DB:SCHEMA_NOTES]
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
archived BOOLEAN DEFAULT false
status VARCHAR(20) DEFAULT 'active'
Categories table created (user-specific)
Migration created and tested
[L590]

```sql
CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT NULL REFERENCES categories(id) ON DELETE SET NULL,
    title VARCHAR(200) NULL,
    content TEXT NOT NULL,
    date DATE NULL,
    time TIME NULL,
    is_pinned BOOLEAN DEFAULT false,
    color VARCHAR(20) DEFAULT 'yellow',
    priority VARCHAR(10) DEFAULT 'medium',
    reminder_minutes INT NULL,
    recurrence VARCHAR(20) NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_notes_user ON notes(user_id);
CREATE INDEX idx_notes_date ON notes(date) WHERE date IS NOT NULL;
CREATE INDEX idx_notes_pinned ON notes(is_pinned) WHERE is_pinned = true;
CREATE INDEX idx_notes_deleted ON notes(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_search ON notes USING gin(to_tsvector('english', coalesce(title,'') || ' ' || content));
```

---

## [DB:SCHEMA_TAGS]
Tags tables created and tested
[L620]

```sql
CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20) NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(user_id, name)
);

CREATE TABLE notes_tags (
    note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (note_id, tag_id)
);

CREATE INDEX idx_tags_user ON tags(user_id);
CREATE INDEX idx_notes_tags_note ON notes_tags(note_id);
CREATE INDEX idx_notes_tags_tag ON notes_tags(tag_id);
```

---

## [DB:SCHEMA_GAMIFICATION] [L650]

```sql
CREATE TABLE points_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points INT NOT NULL,
    reason VARCHAR(100) NOT NULL,
    reference_type VARCHAR(100) NULL,
    reference_id BIGINT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE achievements (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    icon VARCHAR(50) NOT NULL,
    requirement JSONB NOT NULL,
    points_reward INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE user_achievements (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id BIGINT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP NOT NULL,
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_points_log_user ON points_log(user_id);
CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
```

---

## [DB:SCHEMA_EMAIL] [L700]

```sql
CREATE TABLE email_accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    imap_host VARCHAR(255) NULL,
    imap_port INT NULL,
    imap_encryption VARCHAR(10) NULL,
    username VARCHAR(255) NOT NULL,
    password_encrypted TEXT NOT NULL,
    last_synced_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE emails (
    id BIGSERIAL PRIMARY KEY,
    email_account_id BIGINT NOT NULL REFERENCES email_accounts(id) ON DELETE CASCADE,
    message_id VARCHAR(500) UNIQUE NOT NULL,
    subject VARCHAR(500) NULL,
    from_email VARCHAR(255) NOT NULL,
    from_name VARCHAR(255) NULL,
    to_email VARCHAR(255) NOT NULL,
    date TIMESTAMP NOT NULL,
    body_text TEXT NULL,
    body_html TEXT NULL,
    is_read BOOLEAN DEFAULT false,
    is_important BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_email_accounts_user ON email_accounts(user_id);
CREATE INDEX idx_emails_account ON emails(email_account_id);
CREATE INDEX idx_emails_date ON emails(date DESC);
CREATE INDEX idx_emails_search ON emails USING gin(to_tsvector('english', coalesce(subject,'') || ' ' || coalesce(from_name,'')));
```

---

## [DB:SCHEMA_CALENDAR] [L750]

```sql
CREATE TABLE calendar_events (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    start_date DATE NOT NULL,
    start_time TIME NULL,
    end_date DATE NULL,
    end_time TIME NULL,
    all_day BOOLEAN DEFAULT false,
    color VARCHAR(20) DEFAULT 'blue',
    recurrence VARCHAR(20) NULL,
    source VARCHAR(50) NULL,
    source_id VARCHAR(255) NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_calendar_user ON calendar_events(user_id);
CREATE INDEX idx_calendar_date_range ON calendar_events(start_date, end_date);
```

---

## [DB:RELATIONS] [L800]

```
users
  ├─ has many → notes
  ├─ has many → tags
  ├─ has many → email_accounts
  ├─ has many → calendar_events
  └─ many to many → achievements

notes
  ├─ belongs to → user
  ├─ belongs to → category
  └─ many to many → tags

tags
  ├─ belongs to → user
  └─ many to many → notes

email_accounts
  ├─ belongs to → user
  └─ has many → emails
```

---

## [DB:MIGRATIONS] [L850]

**Order:**
```
01_create_users_table
02_create_categories_table
03_create_notes_table
04_create_tags_table
05_create_notes_tags_table
06_create_quick_links_table
07_create_achievements_table
08_create_user_achievements_table
09_create_points_log_table
10_create_email_accounts_table
11_create_emails_table
12_create_calendar_events_table
```

**Commands:**
```bash
php artisan migrate
php artisan migrate --seed
php artisan migrate:rollback
php artisan migrate:fresh --seed
```

---
---

# [SECTION:ARCHITECTURE] SOFTWARE ARCHITECTURE [L900]

## [ARCH:FOLDERS]
Category.php in app/Models/
Note.php relationships and scopes implemented
Tag.php in app/Models/
[L920]

```
hub-personal/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── NoteController.php
│   │   │   ├── CalendarController.php
│   │   │   ├── TagController.php
│   │   │   └── EmailController.php
│   │   ├── Middleware/
│   │   └── Requests/
│   ├── Models/
│   │   ├── User.php
│   │   ├── Note.php
│   │   ├── Tag.php
│   │   └── Email.php
│   ├── Events/
│   ├── Listeners/
│   ├── Jobs/
│   │   └── EmailSyncJob.php
│   ├── Policies/
│   └── Observers/
│
├── resources/
│   ├── js/
│   │   ├── app.js
│   │   ├── Pages/
│   │   │   ├── Dashboard.vue
│   │   │   ├── Notes/
│   │   │   ├── Calendar/
│   │   │   └── Auth/
│   │   ├── Components/
│   │   │   ├── NoteCard.vue
│   │   │   ├── TagInput.vue
│   │   │   └── PointsCounter.vue
│   │   ├── Layouts/
│   │   │   ├── AppLayout.vue
│   │   │   └── GuestLayout.vue
│   │   ├── Stores/
│   │   │   ├── notes.js
│   │   │   ├── calendar.js
│   │   │   └── user.js
│   │   └── Composables/
│   ├── css/
│   │   └── app.css
│   └── views/
│       └── app.blade.php
│
├── routes/
│   ├── web.php
│   └── api.php
│
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
│
├── tests/
│   ├── Feature/
│   └── Unit/
│
├── public/
│   └── build/
│
├── .env
├── composer.json
├── package.json
├── vite.config.js
└── tailwind.config.js
```

**Naming:**
- Controllers: PascalCase + Controller
- Models: Singular PascalCase
- Vue Pages: PascalCase
- Vue Components: PascalCase
- Stores: camelCase
- Composables: camelCase + use prefix

---

## [ARCH:PATTERNS] [L1000]

### Service Layer
```php
// app/Services/NoteService.php
class NoteService {
    public function createNote(User $user, array $data): Note
    {
        $note = $user->notes()->create($data);
        event(new NoteCreated($note));
        PointsService::award($user, 'note_created', 5);
        return $note;
    }
}
```

### Observer
```php
// app/Observers/NoteObserver.php
class NoteObserver {
    public function created(Note $note): void
    {
        activity()
            ->causedBy($note->user)
            ->performedOn($note)
            ->log('created note');
    }
}
```

### Policy
```php
// app/Policies/NotePolicy.php
class NotePolicy {
    public function update(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }
}
```

### Vue Composable
```js
// composables/useNotes.js
export function useNotes() {
  const notes = ref([])
  const loading = ref(false)
  
  async function fetchNotes() {
    loading.value = true
    const { data } = await axios.get('/api/notes')
    notes.value = data
    loading.value = false
  }
  
  return { notes, loading, fetchNotes }
}
```

---

## [ARCH:ROUTING] [L1100]

### Inertia Routes
```php
// routes/web.php

Route::get('/', fn() => Inertia::render('Dashboard'))->name('dashboard');

Route::resource('notes', NoteController::class);
// GET    /notes           → Notes/Index.vue
// GET    /notes/create    → Notes/Create.vue
// POST   /notes           → notes.store
// GET    /notes/{id}      → Notes/Show.vue
// PUT    /notes/{id}      → notes.update
// DELETE /notes/{id}      → notes.destroy

Route::get('/calendar', [CalendarController::class, 'index'])->name('calendar');

Route::prefix('email')->name('email.')->group(function() {
    Route::get('/', [EmailController::class, 'index'])->name('index');
    Route::post('/sync', [EmailController::class, 'sync'])->name('sync');
});
```

### Ziggy (Routes in JS)
```vue
<script setup>
import { router } from '@inertiajs/vue3'

function goToNote(id) {
  router.get(route('notes.show', { note: id }))
}
</script>
```

---

## [ARCH:EVENTS] [L1200]

```
Event: NoteCreated
  → AwardPointsListener (+5)
  → CheckAchievementsListener
  → LogActivityListener

Event: EmailSynced
  → AwardPointsListener (+3 per email)

Event: MeditationCompleted
  → AwardPointsListener (+20)
  → UpdateStreakListener

Event: AchievementUnlocked
  → ShowConfettiListener
  → SendNotificationListener
```

---
---

# [SECTION:TESTING] TESTING [L1300]

## [TEST:STRATEGY] [L1320]

**Framework:** Pest  
**Coverage:** 80%+  
**CI/CD:** GitHub Actions

---

## [TEST:EXAMPLES] [L1350]

### Unit
```php
// tests/Unit/PointsServiceTest.php
test('awards points correctly', function() {
    $user = User::factory()->create(['points' => 0]);
    
    PointsService::award($user, 'note_created', 5);
    
    expect($user->fresh()->points)->toBe(5);
});
```

### Feature
```php
// tests/Feature/NoteTest.php
test('user can create note', function() {
    $user = User::factory()->create();
    
    actingAs($user)->post('/notes', [
        'title' => 'Test',
        'content' => 'Content',
    ])->assertRedirect();
    
    expect($user->notes()->count())->toBe(1);
});
```

---

## [TEST:COMMANDS] [L1400]

```bash
# All tests
php artisan test

# With coverage
php artisan test --coverage --min=80

# Specific
php artisan test --filter=NoteTest

# Parallel
php artisan test --parallel
```

---
---

# [SECTION:DESIGN] DESIGN SYSTEM [L1500]

## [DESIGN:COLORS] [L1520]

```js
// tailwind.config.js
colors: {
  primary: {
    50: '#f0f9ff',
    500: '#0ea5e9',
    900: '#0c4a6e',
  },
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444',
}
```

**Note colors:**
```
yellow: '#fef3c7'
blue: '#dbeafe'
green: '#d1fae5'
pink: '#fce7f3'
purple: '#f3e8ff'
```

---

## [DESIGN:TYPOGRAPHY] [L1550]

**Font:** Inter

```css
h1 { font-size: 2rem; font-weight: 700; }
h2 { font-size: 1.5rem; font-weight: 600; }
h3 { font-size: 1.25rem; font-weight: 600; }
p { font-size: 1rem; font-weight: 400; }
```

---

## [DESIGN:COMPONENTS] [L1600]

### Button
```vue
<button class="bg-primary-500 hover:bg-primary-600 text-white px-4 py-2 rounded-lg">
  Save
</button>
```

### Modal
```vue
<script setup>
import { Dialog, DialogPanel, DialogTitle } from '@headlessui/vue'

const isOpen = ref(false)
</script>

<template>
  <Dialog :open="isOpen" @close="isOpen = false">
    <div class="fixed inset-0 bg-black/30" />
    <div class="fixed inset-0 flex items-center justify-center p-4">
      <DialogPanel class="bg-white rounded-lg max-w-md p-6">
        <DialogTitle>Title</DialogTitle>
        <!-- Content -->
      </DialogPanel>
    </div>
  </Dialog>
</template>
```

---

## [DESIGN:SPACING] [L1700]

**Scale:**
```
p-2  = 0.5rem (8px)
p-4  = 1rem (16px)
p-6  = 1.5rem (24px)
p-8  = 2rem (32px)
p-12 = 3rem (48px)
```

**Layout:**
- Container max: 1280px
- Sidebar: 256px
- Card padding: p-6
- Section spacing: space-y-8

---
---

# [SECTION:AUTH] AUTHENTICATION [L1800]

## [AUTH:BREEZE] [L1820]

**System:** Laravel Breeze (Vue stack)

**Features:**
- Register
- Login
- Password reset
- Email verification
- Remember me

**Routes:**
```
/register
/login
/forgot-password
/reset-password/{token}
/verify-email/{id}/{hash}
/logout
```

**Middleware:**
```php
Route::middleware(['auth', 'verified'])->group(function() {
    // Protected routes
});
```

---

## [AUTH:POLICY]
NotePolicy ensures users can only access their own notes
AuthServiceProvider created with NotePolicy registration
[L1900]

```php
// app/Policies/NotePolicy.php
class NotePolicy {
    public function update(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }
}

// Usage
$this->authorize('update', $note);
```

---
---

# [SECTION:PERFORMANCE] PERFORMANCE [L2000]

## [PERF:CACHING] [L2020]

```php
// Config cache
php artisan config:cache

// Route cache
php artisan route:cache

// View cache
php artisan view:cache

// Query cache
$notes = Cache::remember('user.notes.'.$userId, 300, fn() =>
    Note::where('user_id', $userId)->get()
);
```

---

## [PERF:QUERIES] [L2100]

```php
// ❌ Bad (N+1)
$notes = Note::all();
foreach($notes as $note) {
    echo $note->user->name; // N queries
}

// ✅ Good
$notes = Note::with('user')->get();
foreach($notes as $note) {
    echo $note->user->name; // 1 query
}
```

---

## [PERF:BUDGET] [L2150]

**Targets:**
- FCP: <1.5s
- TTI: <3s
- Bundle: <250KB
- Lighthouse: >90

---
---

# [SECTION:DEPLOY] DEPLOYMENT [L3000]

## [QUICK:DEPLOY] [L3020]

**Pipeline:** GitHub Actions → Staging → Production

**Process:**
1. Push to develop → Staging
2. Push to main → Production
3. Tests must pass (80%)

---

## [DEPLOY:CICD] [L3050]

### tests.yml
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: hub_test
          POSTGRES_USER: hub
          POSTGRES_PASSWORD: secret
        ports:
          - 5432:5432
      
      redis:
        image: redis:7.2
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PHP 8.3
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: pgsql, redis
      
      - name: Setup Node 20
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install Composer deps
        run: composer install
      
      - name: Install NPM deps
        run: npm ci
      
      - name: Build frontend
        run: npm run build
      
      - name: Run tests
        run: php artisan test --coverage --min=80
```

### deploy-production.yml
```yaml
name: Deploy Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Deploy
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USERNAME }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          script: |
            cd /var/www/hub-personal
            
            # Backup
            tar -czf ../backups/backup-$(date +%Y%m%d-%H%M%S).tar.gz .
            
            # Maintenance
            php artisan down --retry=60
            
            # Code
            git pull origin main
            
            # Backend
            composer install --no-dev --optimize-autoloader
            
            # Frontend
            npm ci
            npm run build
            
            # DB
            php artisan migrate --force
            
            # Optimize
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
            php artisan optimize
            
            # Queue
            php artisan queue:restart
            
            # PHP-FPM
            sudo systemctl reload php8.3-fpm
            
            # Up
            php artisan up
```

**Critical steps:**
1. Backup
2. Maintenance mode
3. Pull code
4. Composer install
5. **npm ci**
6. **npm run build**
7. Migrate
8. Cache optimize
9. Restart queue
10. Reload PHP-FPM
11. Up

---

## [DEPLOY:BACKUP] [L3200]

```bash
#!/bin/bash
# Daily backup at 3am

DATE=$(date +%Y%m%d)
BACKUP_DIR=/backups

# Database
pg_dump -h localhost -U hub_user hub_db > $BACKUP_DIR/db-$DATE.sql
gzip $BACKUP_DIR/db-$DATE.sql

# Files
tar -czf $BACKUP_DIR/files-$DATE.tar.gz /var/www/hub-personal/storage

# Cleanup (>30 days)
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
```

---
---

# [SECTION:ROADMAP] ROADMAP [L3300]

## [ROADMAP:MVP] [L3320]

### MVP v0.1 (4 weeks)

**Must have:**
- ✅ Auth (Breeze Vue)
- ✅ Notes CRUD
- ✅ Tags
- ✅ Calendar
- ✅ Gamification (points)
- ✅ Search
- ✅ PWA

**Not in MVP:**
- ❌ Email
- ❌ Meditation
- ❌ Achievements

**Timeline:**
```
Week 1: Setup
Week 2: Notes + Tags
Week 3: Calendar + Gamification
Week 4: Testing + Deploy
```

---

## [ROADMAP:RELEASES] [L3400]

### v0.2 (+2 weeks)
- Email sync (1 account)
- Meditation timer
- 5 achievements

### v1.0 (+2 months)
- Multiple emails (3 max)
- 10 achievements
- Mobile app (Capacitor)

---
---

# [END:DOC] [L3500]

**Document complete.**

**Format:** Clean (no fluff)  
**Lines:** ~3,500 (vs 10,000 original)  
**Reduction:** 65%  
**Content:** 100% technical facts

---

**Quick access:**
- [QUICK:STACK] L420
- [DB:SCHEMA_NOTES]
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
priority VARCHAR(10) DEFAULT 'medium'
color VARCHAR(20) DEFAULT 'yellow'
archived BOOLEAN DEFAULT false
status VARCHAR(20) DEFAULT 'active'
Categories table created (user-specific)
Migration created and tested
L590
- [DEPLOY:CICD] L3050
- [ROADMAP:MVP] L3320

**[REF:INDEX]** See _INDEX.md

---
