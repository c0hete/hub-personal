<!-- File: docs/META_TAG_STANDARD.md -->

# @meta Tag Standard Format
## Version: 1.0
## Last Updated: 2025-11-16

---

## OFFICIAL FORMAT

**Required Fields:**
- @session: YYYY-MM-DD-NNN
- @file: Relative path from root
- @refs: [SECTION:ANCHOR], [SECTION:ANCHOR]
- @changes: Brief description
- @doc-update: [SECTION:ANCHOR] ACTION description

**Anchor Format:**
 CORRECT: [PRD:NOTES_SYSTEM]
 INCORRECT: PRD:NOTES_SYSTEM

---

## COMMON ANCHORS

**Product:** [PRD:NOTES_SYSTEM], [PRD:TAGS], [PRD:CALENDAR]
**Architecture:** [ARCH:FOLDERS], [ARCH:ROUTING]
**Database:** [DB:SCHEMA_NOTES], [DB:SEEDERS], [DB:MIGRATIONS]
**Stack:** [STACK:BACKEND], [STACK:FRONTEND]
**Design:** [DESIGN:COMPONENTS], [DESIGN:LAYOUTS]
**Auth:** [AUTH:POLICY], [AUTH:MIDDLEWARE]
