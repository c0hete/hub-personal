# ACTUALIZACIÓN PARA 03_PROMPTS_v2.3.md

**Agregar después de línea 650 (después de [RULES:FILE_CREATION_WORKFLOW])**

---

## [RULES:POWERSHELL_ENCODING] [L650]

**CRITICAL: All PowerShell scripts must use UTF-8 without BOM**

### Problem:
Claude generates scripts with UTF-8 + BOM encoding, which causes PowerShell ParseError.

### Solution for José:

**ALWAYS run after downloading .ps1 from Claude:**
```powershell
.\fix_encoding.ps1 -File "downloaded_script.ps1"
```

**Why this is necessary:**
- Claude generates: UTF-8 **with BOM**
- PowerShell requires: UTF-8 **without BOM**  
- Without fix → ParseError: "Token '}' inesperado"

**Workflow:**
```powershell
# 1. Download .ps1 from Claude
# 2. Copy to docs/
# 3. FIX ENCODING FIRST:
.\fix_encoding.ps1 -File "new_script.ps1"

# 4. Now execute:
.\new_script.ps1  # ✅ Works!
```

### For Claude:

**When generating .ps1 scripts:**

1. **Include encoding warning in header:**
```powershell
# script_name.ps1
# Version: 1.0.0
# ENCODING: Run .\fix_encoding.ps1 -File "script_name.ps1" before use
# Purpose: Description here
```

2. **Use only ASCII characters:**
   - ✅ Simple English comments
   - ❌ NO emojis in comments
   - ❌ NO accents in comments  
   - ❌ NO special Unicode characters

3. **Remind user in delivery:**
```markdown
## ⚠️ IMPORTANT: Encoding Fix Required

Before executing this script, run:

```powershell
.\fix_encoding.ps1 -File "new_script.ps1"
```

This prevents ParseError issues.
```

4. **Provide exact commands:**
```powershell
# Download and save script, then:
cd C:\Users\JoseA\Projects\hub-personal\docs
.\fix_encoding.ps1 -File "new_script.ps1"
.\new_script.ps1
```

### Common Error:

**Symptom:**
```
Token '}' inesperado en la expresión
ParserError: UnexpectedToken
```

**Cause:** UTF-8 with BOM encoding

**Fix:**
```powershell
.\fix_encoding.ps1 -File "problematic_script.ps1"
```

### Prevention Checklist:

**For every .ps1 file from Claude:**
```
☐ Download from Claude
☐ Copy to docs/
☐ Run: .\fix_encoding.ps1 -File "X.ps1"
☐ Execute: .\X.ps1
☐ ✅ Success
```

**See also:**
- `ENCODING_GUIDE.md` - Complete encoding documentation
- `ENCODING_QUICKFIX.md` - Quick reference
- `POWERSHELL_STANDARDS.md` - PowerShell standards

---

**Version:** 2.4 (added encoding section)  
**Last Update:** 2025-11-16
