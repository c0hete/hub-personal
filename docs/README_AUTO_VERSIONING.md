# Auto-Versioning Documentation System

**Quick Reference Guide**

---

## What is this?

Automatically sync code changes → documentation.

**No more manual doc updates!**

---

## How it works

```
Write code → Add @meta block → Save → Parser runs → Docs update → Version bumps → Git commit
```

**Time:** <1 second per file

---

## Quick Start (5 minutes)

### 1. Copy files to your project

```
docs/
├── 06_METADATA_PROTOCOL.md
├── 08_PARSER.ps1
└── update_docs.ps1
```

### 2. Create meta.json

```json
{
  "version": "1.0.0",
  "last_modified": "2025-11-16T00:00:00Z",
  "project_name": "YourProject"
}
```

### 3. Add markers to your MASTER.md

```markdown
## [DB:SCHEMA_USERS]
```

### 4. Add @meta to your code

```php
/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: src/User.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Added avatar field
 * @doc-update: [DB:SCHEMA_USERS] ADD avatar VARCHAR(255)
 * @meta-end
 */
```

### 5. Run parser

```powershell
cd docs
.\08_PARSER.ps1 -File "..\src\User.php"
```

### 6. Done! ✅

Check:
- MASTER.md updated
- Version bumped (1.0.0 → 1.0.1)
- Git commit created

---

## Common Use Cases

### Add database field

```php
/** @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/User.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Added timezone field
 * @doc-update: [DB:SCHEMA_USERS] ADD timezone VARCHAR(50)
 * @meta-end */
```

### Change tech stack

```php
/** @meta-start
 * @session: 2025-11-16-002
 * @file: config/cache.php
 * @refs: [STACK:BACKEND]
 * @changes: Switched cache from Redis to Memcached
 * @doc-update: [STACK:BACKEND] MODIFY Cache: Redis -> Cache: Memcached
 * @meta-end */
```

### Add new component

```vue
<!-- @meta-start
@session: 2025-11-16-003
@file: components/Button.vue
@refs: [DESIGN:COMPONENTS]
@changes: Created Button component
@doc-update: [DESIGN:COMPONENTS] ADD Button.vue with variants
@meta-end -->
```

---

## Actions Available

| Action | Usage | Example |
|--------|-------|---------|
| ADD | Add new content | `ADD avatar VARCHAR(255)` |
| MODIFY | Change existing | `MODIFY old -> new` |
| DELETE | Remove content | `DELETE field_name` |
| MOVE | Relocate | `MOVE content TO [TARGET]` |

---

## Rules

✅ **DO:**
- Use markers: `[SECTION:NAME]`
- Multiple @doc-update allowed
- Keep @changes concise

❌ **DON'T:**
- Use line numbers: ~~`[DB:SCHEMA#L570]`~~
- Skip required fields
- Use outside code comments

---

## Troubleshooting

**Marker not found?**
→ Add to MASTER.md: `### [YOUR:MARKER]`

**Version not bumping?**
→ Check meta.json exists

**Parser errors?**
→ Validate @meta format (see protocol)

---

## FAQ

**Q: Need PowerShell?**  
A: Yes (v5+ or Core)

**Q: Works on Mac/Linux?**  
A: With PowerShell Core, yes

**Q: Language-specific?**  
A: No, works with any text files

**Q: Team collaboration?**  
A: Yes, coordinate on MASTER.md changes

---

## Full Documentation

**Complete guide:** [11_AUTO_VERSIONING_SYSTEM.md](11_AUTO_VERSIONING_SYSTEM.md) (850 lines)

Includes:
- Detailed installation
- All features explained
- Customization guide
- Testing procedures
- Replication checklist
- Visual diagrams
- Troubleshooting

---

## Stats

- **Setup time:** ~30 minutes
- **Learning curve:** ~5 minutes
- **Time saved:** Hours per week
- **Accuracy:** 100% (automated)

---

## Status

- **Version:** 1.0.0
- **Status:** Production-ready
- **Tested:** HubPersonal project (4 updates)
- **License:** Open for replication

---

**Maintained by:** José Alvarado Mazzei  
**Project:** HubPersonal  
**Date:** 2025-11-16
