# [SESSION:START] CONTEXT LOADER

**Purpose:** Load full project context in new Claude conversations  
**Usage:** Copy/paste this file at start of every new chat  
**Target:** Claude gets complete context in <1000 tokens

---

## [PROJECT:IDENTITY] [L10]

**Name:** HubPersonal  
**Type:** Personal productivity hub  
**User:** José Alvarado Mazzei (ADHD)  
**Goal:** Centralize digital life without cognitive overload

**Current Phase:** Pre-development (documentation complete)  
**Next Phase:** Laravel setup + MVP development

---

## [STACK:FINAL] [L25]

**Backend:**  
Laravel 11 | PHP 8.3 | PostgreSQL 15 | Redis 7.2

**Frontend:**  
Vue 3.4 | Inertia.js 1.0 | Vite 5 | Pinia 2.1 | Tailwind 3.4

**Auth:** Breeze (Vue)  
**Testing:** Pest  
**Deploy:** GitHub Actions → VPS Contabo

---

## [DOCS:LOCATION] [L40]

**All documentation:**  
`C:/Users/JoseA/Projects/hub-personal/docs/`

**Files in Claude Project:**
- `00_INDEX.md` - Navigation with markers
- `01_MASTER_DOC.md` - Complete technical docs (3,500 lines)
- `03_PROMPTS.md` - Agent behavior rules

**Local only:**
- `02_CONTEXT.md` - Changelog (not for Claude)
- `meta.json` - Metadata
- `update_docs.ps1` - Update script

---

## [NAVIGATION:QUICK] [L60]

**To find info in MASTER.md:**

```
Stack details       → [QUICK:STACK] L420
Database schema     → [DB:SCHEMA_NOTES] L590
Architecture        → [ARCH:FOLDERS] L920
Deploy pipeline     → [DEPLOY:CICD] L3050
MVP scope           → [ROADMAP:MVP] L3320
```

**Search method:** Ctrl+F with `[MARKER:name]` in MASTER.md

---

## [RULES:CRITICAL] [L80]

**Read these BEFORE generating code:**

1. **File headers:** Always add path comment
   ```php
   // File: app/Models/Note.php
   ```

2. **Naming:** Models in English, comments in Spanish
   ```php
   // Modelo: Notas del usuario
   class Note extends Model {}
   ```

3. **Migrations:** Always check table existence
   ```php
   if (!Schema::hasTable('notes')) {
       Schema::create('notes', ...);
   }
   ```

4. **Code style:** PSR-12, run `./vendor/bin/pint` before commit

5. **Documentation updates:** If you modify architecture/schema, suggest:
   ```
   "You should update MASTER.md and run .\update_docs.ps1 -Update"
   ```

**Full rules:** See `03_PROMPTS.md` in project

---

## [STATE:CURRENT] [L115]

**What exists:**
- ✅ Complete documentation (MASTER.md)
- ✅ Database schema (13 tables)
- ✅ Architecture design
- ✅ Testing strategy
- ✅ Deploy pipeline
- ✅ Design system

**What doesn't exist yet:**
- ❌ Laravel installation
- ❌ Any code files
- ❌ Database created
- ❌ Git repository

**Next immediate steps:**
1. Create project folder structure
2. Install Laravel 11
3. Configure PostgreSQL
4. Setup Breeze + Inertia + Vue
5. First migration

---

## [MVP:SCOPE] [L145]

**Must have (v0.1):**
- Auth (register, login)
- Notes CRUD (quick + scheduled)
- Tags system
- Calendar view (month)
- Basic gamification (points)
- Search (notes + tags)
- PWA setup

**Not in MVP:**
- Email sync
- Meditation timer
- Achievements system
- Social features

**Timeline:** 4 weeks

---

## [DATABASE:CORE] [L170]

**Main tables:**

```sql
users (id, name, email, points, level)
notes (id, user_id, title, content, date, is_pinned)
tags (id, user_id, name, color)
notes_tags (note_id, tag_id)
categories (id, user_id, name)
calendar_events (id, user_id, title, start_date)
points_log (id, user_id, points, reason)
achievements (id, name, points_reward)
```

**Full schema:** See `[DB:SCHEMA_*]` markers in MASTER.md

---

## [BEHAVIOR:EXPECTED] [L195]

**When I ask you to code:**
1. Check `03_PROMPTS.md` for rules
2. Follow naming conventions strictly
3. Add file path comment
4. Use proper error handling
5. Write clean, PSR-12 compliant code

**When I ask about architecture:**
1. Check `00_INDEX.md` for navigation
2. Jump to relevant section in `01_MASTER_DOC.md`
3. Answer from documented decisions
4. NO assumptions, NO improvisation

**When you modify MASTER.md:**
1. Keep marker format: `[SECTION:NAME] [L###]`
2. Update line numbers if needed
3. Tell me to run `.\update_docs.ps1 -Update`

---

## [COMMUNICATION:STYLE] [L220]

**José has ADHD, so:**
- ✅ Responses: Concise, direct, actionable
- ✅ Code: Complete, ready to copy/paste
- ✅ Explanations: Only when asked
- ❌ No fluff, no philosophical discussions
- ❌ No "let me explain why..."
- ❌ No comparisons with alternatives

**Format:**
- Code blocks with file paths
- Markers for navigation
- Step-by-step when complex
- Ask clarifying questions if unclear

---

## [CONTEXT:LOADED] [L240]

**You now know:**
- ✅ Project identity and goal
- ✅ Complete tech stack
- ✅ Where documentation lives
- ✅ How to navigate MASTER.md
- ✅ Critical coding rules
- ✅ Current project state
- ✅ MVP scope
- ✅ Database structure
- ✅ Expected behavior
- ✅ Communication preferences

**Ready to work.** 🚀

---

## [FIRST:ACTION] [L260]

**Typical first messages after loading context:**

```
"Create the User model with avatar field"
→ You generate code following PROMPTS rules

"Where is the database schema?"
→ You say: [DB:SCHEMA_NOTES] L590 in MASTER.md

"Let's start the Laravel installation"
→ You guide step-by-step, following MASTER architecture

"What's in the MVP?"
→ You reference [ROADMAP:MVP] L3320 and summarize
```

---

**[SESSION:READY]** [L280]

Context loaded. Awaiting instructions.
