# File: POWERSHELL_STANDARDS.md
# Purpose: Coding standards for PowerShell scripts
# Version: 1.0.0

---

## CRITICAL: ENCODING RULES FOR POWERSHELL

### THE PROBLEM

PowerShell scripts (.ps1 files) **MUST use pure ASCII encoding**.

UTF-8 special characters (emojis, Unicode symbols, smart quotes) cause **parsing errors** when downloaded from web or copied between systems.

### RULE: ASCII-ONLY IN .PS1 FILES

**Applies to:**
- All .ps1 PowerShell scripts
- All executable code
- All string literals
- All regex patterns

**Does NOT apply to:**
- .md documentation files (use emojis freely)
- Comments (prefer ASCII but tolerated)
- Output to console (after processing)

---

## FORBIDDEN CHARACTERS

### Emojis (NEVER in .ps1)

```powershell
# WRONG:
Write-Host "✅ Success"
Write-Host "❌ Error"
Write-Host "⚠️ Warning"  
Write-Host "ℹ️ Info"
Write-Host "🚀 Starting"
Write-Host "👋 Goodbye"

# CORRECT:
Write-Host "[OK] Success"
Write-Host "[ERROR] Error"
Write-Host "[WARN] Warning"
Write-Host "[INFO] Info"
Write-Host "[START] Starting"
Write-Host "[BYE] Goodbye"
```

### Unicode Arrows (NEVER in .ps1)

```powershell
# WRONG:
$text = "old → new"
if ($Details -match '(.+?)\s*→\s*(.+)') { }
Write-Host "Version: 2.1.0 → 2.1.1"

# CORRECT:
$text = "old -> new"
if ($Details -match '(.+?)\s*->\s*(.+)') { }
Write-Host "Version: 2.1.0 -> 2.1.1"
```

### Smart Quotes (NEVER in .ps1)

```powershell
# WRONG:
Write-Host "It's broken"    # Curly apostrophe
Write-Host "Use "quotes""   # Curly quotes

# CORRECT:
Write-Host "It's broken"    # Straight apostrophe
Write-Host "Use 'quotes'"   # Straight quotes
```

### Other Unicode Symbols (NEVER in .ps1)

```powershell
# WRONG:
Write-Host "• Item 1"       # Bullet point
Write-Host "─────────"      # Box drawing
Write-Host "≥ 5"            # Greater-or-equal
Write-Host "×"              # Multiplication

# CORRECT:
Write-Host "- Item 1"       # Hyphen
Write-Host "---------"      # Hyphens
Write-Host ">= 5"           # ASCII comparison
Write-Host "*"              # Asterisk
```

---

## ALLOWED PATTERNS

### Status Prefixes

```powershell
# Use bracketed prefixes for status messages
Write-Host "[OK] Operation successful"
Write-Host "[ERROR] Operation failed"
Write-Host "[WARN] Check configuration"
Write-Host "[INFO] Processing file"
Write-Host "[DEBUG] Variable value: $x"
Write-Host "[WAIT] Debouncing..."
Write-Host "[SKIP] File excluded"
```

### Arrows and Separators

```powershell
# Use ASCII equivalents
"old -> new"           # Arrow (not →)
"source => target"     # Fat arrow (not ⇒)
"A to B"               # Alternative to arrow
"before :: after"      # Alternative separator
```

### Box Drawing

```powershell
# Use simple ASCII boxes
Write-Host "=================================="
Write-Host "=== Title =======================
Write-Host "=================================="

# NOT Unicode box drawing:
# ╔════════╗  (causes errors)
# ║ Title  ║  (causes errors)
# ╚════════╝  (causes errors)
```

---

## STANDARD FUNCTION TEMPLATES

### Color Output Functions

```powershell
# ALWAYS use this pattern:
function Write-Success { 
    param([string]$Message) 
    Write-Host "[OK] $Message" -ForegroundColor Green 
}

function Write-Error-Custom { 
    param([string]$Message) 
    Write-Host "[ERROR] $Message" -ForegroundColor Red 
}

function Write-Warning-Custom { 
    param([string]$Message) 
    Write-Host "[WARN] $Message" -ForegroundColor Yellow 
}

function Write-Info { 
    param([string]$Message) 
    Write-Host "[INFO] $Message" -ForegroundColor Cyan 
}
```

### Banner Templates

```powershell
# Simple ASCII banners only:
function Show-Banner {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   MY SCRIPT v1.0.0                    " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Alternative with hash marks:
Write-Host "###################################"
Write-Host "#  MY SCRIPT v1.0.0               #"
Write-Host "###################################"
```

---

## TESTING FOR COMPLIANCE

### Manual Test

1. Copy script content to Notepad (Windows)
2. Save as .ps1 with UTF-8 encoding
3. Run: `powershell.exe -File script.ps1`
4. Should execute without parse errors

### Keyboard Test

**Rule:** If you can't type it with standard US keyboard (no Alt codes), don't use it.

**Valid:**
- All letters (A-Z, a-z)
- Numbers (0-9)
- Symbols: ! @ # $ % ^ & * ( ) - _ = + [ ] { } | \ ; : ' " , . < > / ?
- Space, Tab, Newline

**Invalid:**
- Anything requiring Alt+### codes
- Anything requiring copy-paste from character map
- Anything not on standard US keyboard

---

## REGEX PATTERNS

### Safe Patterns

```powershell
# Use ASCII only in patterns
if ($text -match '^[A-Za-z0-9\-_]+$') { }       # OK
if ($text -match '(.+?)\s*->\s*(.+)') { }       # OK
if ($text -match '\[([^\]]+)\]') { }            # OK
```

### Unsafe Patterns (AVOID)

```powershell
# These can break with encoding:
if ($text -match '→') { }                       # NO - Unicode arrow
if ($text -match '[✓✗]') { }                    # NO - Emojis
if ($text -match '"(.+?)"') { }                 # NO - Smart quotes
```

---

## STRING LITERALS

### Always Use Straight Quotes

```powershell
# CORRECT:
$message = "Hello World"
$path = 'C:\Users\Jose'
$regex = "test.*pattern"

# WRONG (smart quotes):
$message = "Hello World"  # Curly quotes - will break
$path = 'C:\Users\Jose'   # Curly apostrophe - will break
```

### Escape Sequences

```powershell
# Use PowerShell escape sequences (backtick)
Write-Host "Line 1`nLine 2"      # Newline
Write-Host "Tab`there"           # Tab
Write-Host "Quote: `"text`""     # Escaped quote
```

---

## ERROR MESSAGES

### Good Examples

```powershell
Write-Error-Custom "File not found: $FilePath"
Write-Error-Custom "Invalid format. Expected: YYYY-MM-DD-NNN"
Write-Error-Custom "Marker not found in MASTER.md: [$Marker]"
Write-Error-Custom "Parsing failed at line $LineNumber"
```

### Bad Examples (Contains Unicode)

```powershell
Write-Error-Custom "❌ File not found"           # Emoji
Write-Error-Custom "Invalid format → use YYYY"   # Unicode arrow
Write-Error-Custom "Can't find marker"           # Smart apostrophe
```

---

## COMMENTS

### Preferred (ASCII-only)

```powershell
# This is a comment
# TODO: Fix this later
# FIXME: Bug in logic
# NOTE: Important detail
# HACK: Temporary solution
```

### Tolerated (But avoid)

```powershell
# ✅ This works (emoji in comment - OK but not preferred)
# → Next step (arrow in comment - OK but not preferred)
```

### Code Comments

```powershell
# ALWAYS use English for technical comments
# For business logic, Spanish is OK

# Verificar si el usuario tiene permisos (Spanish OK)
if ($user.CanEdit) {
    # Update allowed (English OK)
}
```

---

## FILE HEADERS

### Standard Header

```powershell
# File: 08_PARSER.ps1
# Purpose: Parse metadata blocks from source files
# Version: 1.0.0
# Author: Jose Alvarado Mazzei
# Created: 2025-11-15

<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Longer description

.PARAMETER Name
    Parameter description

.EXAMPLE
    .\script.ps1 -Parameter Value
#>
```

---

## VALIDATION CHECKLIST

Before committing any .ps1 file:

```
[ ] No emojis in code
[ ] No Unicode arrows (use ->)
[ ] No smart quotes (use " and ')
[ ] No box-drawing characters
[ ] Only ASCII in regex patterns
[ ] Only ASCII in string literals
[ ] Functions use [OK]/[ERROR]/[WARN]/[INFO]
[ ] All symbols typeable on US keyboard
[ ] File saved as UTF-8 (for comments)
[ ] Tested: Script executes without parse errors
```

---

## DOCUMENTATION EXCEPTION

**IMPORTANT:** These rules apply ONLY to .ps1 PowerShell scripts.

**For .md documentation files:**
- ✅ Emojis are ENCOURAGED for readability
- ✅ Unicode arrows are FINE
- ✅ Smart quotes are OK
- ✅ Box drawing is GOOD
- ✅ Any UTF-8 characters are ALLOWED

**Example:**
```markdown
# Documentation.md (emojis OK here)

## Features
- ✅ Auto-detection
- ✅ Validation
- ⚠️ Experimental feature
- 🚀 High performance

Status: old → new (arrow OK here)
```

---

## SUMMARY

### Golden Rules

1. **PowerShell scripts (.ps1):** ASCII-only, no exceptions
2. **Documentation (.md):** UTF-8 freely, emojis encouraged
3. **Test:** If you can't type it on US keyboard, don't use it in .ps1
4. **Replace:** ✅→[OK], ❌→[ERROR], →→->, ""→""
5. **Validate:** Always test script execution before committing

### Quick Reference

```
✅ → [OK]
❌ → [ERROR]
⚠️ → [WARN]
ℹ️ → [INFO]
→ → ->
" " → " "
' ' → ' '
• → -
```

---

**END OF STANDARDS**

Follow these rules for all future PowerShell script generation.
