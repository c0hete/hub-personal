# GUÍA DE ENCODING - PowerShell Scripts

**Version:** 1.1.0  
**Fecha:** 2025-11-16  
**Propósito:** PREVENIR errores de encoding en scripts PowerShell

---

## 🚨 PROBLEMA CRÍTICO

### Síntoma:
```powershell
PS> .\script.ps1
Token '}' inesperado en la expresión o la instrucción.
ParserError: UnexpectedToken
```

### Causa:
**Scripts generados por Claude tienen encoding UTF-8 con BOM (Byte Order Mark)**
- PowerShell espera: UTF-8 sin BOM o ANSI
- Claude genera: UTF-8 con BOM
- Resultado: PowerShell no puede parsear

---

## ✅ SOLUCIÓN PERMANENTE

### Método 1: Usar fix_encoding.ps1 (RECOMENDADO)

**Ya existe este script en docs/**

```powershell
# Después de descargar cualquier .ps1 de Claude:
.\fix_encoding.ps1 -File "nuevo_script.ps1"

# Resultado: Encoding corregido automáticamente
```

**Automatizar para múltiples archivos:**
```powershell
# Corregir todos los .ps1 en docs/
Get-ChildItem *.ps1 | ForEach-Object {
    .\fix_encoding.ps1 -File $_.Name
}
```

---

### Método 2: Regenerar con encoding correcto

**Si fix_encoding.ps1 falla, pedir a Claude:**

```
Claude, el script tiene error de encoding.
Por favor regenera usando:
- Unix line endings (LF)
- UTF-8 sin BOM
- Evitar caracteres especiales en comentarios
```

---

## 📋 CHECKLIST OBLIGATORIO

### CADA VEZ que descargues un .ps1 de Claude:

```
☐ Descargar script de Claude
☐ Copiar a docs/
☐ ANTES de ejecutar, correr:
  .\fix_encoding.ps1 -File "nuevo_script.ps1"
☐ Verificar que no hay errores:
  Get-Content "nuevo_script.ps1" | Select-Object -First 5
☐ Ejecutar el script
```

**SI OLVIDAS EL FIX:**
- ❌ Script falla con ParseError
- ⏱️ Pierdes tiempo debuggeando
- 🔧 Tienes que regenerarlo

**SI USAS EL FIX:**
- ✅ Script funciona de inmediato
- ⚡ Cero problemas
- 😊 Felicidad

---

## 🔧 SCRIPT: fix_encoding.ps1

**Ubicación:** `docs/fix_encoding.ps1`

**Código completo:**
```powershell
# fix_encoding.ps1
# Version: 1.0.0
# Purpose: Fix encoding issues in PowerShell scripts

param(
    [Parameter(Mandatory=$true)]
    [string]$File
)

if (-not (Test-Path $File)) {
    Write-Host "Error: File not found: $File" -ForegroundColor Red
    exit 1
}

Write-Host "Fixing encoding for: $File" -ForegroundColor Cyan

# Read with correct encoding
$content = Get-Content $File -Raw -Encoding UTF8

# Write with correct encoding (UTF-8 without BOM)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($File, $content, $Utf8NoBomEncoding)

Write-Host "Encoding fixed successfully!" -ForegroundColor Green
```

**Uso:**
```powershell
.\fix_encoding.ps1 -File "verify_registry.ps1"
.\fix_encoding.ps1 -File "nuevo_parser.ps1"
```

---

## 📝 ACTUALIZACIÓN DE DOCUMENTACIÓN

### 1. PROMPTS.md - Agregar sección

**Ubicación:** `03_PROMPTS_v2.3.md`  
**Después de:** `[RULES:FILE_CREATION_WORKFLOW]`

```markdown
## [RULES:POWERSHELL_ENCODING] [L650]

**CRITICAL: All PowerShell scripts must use UTF-8 without BOM**

### For José:

**ALWAYS run after downloading .ps1 from Claude:**
```powershell
.\fix_encoding.ps1 -File "downloaded_script.ps1"
```

**Why:**
- Claude generates UTF-8 with BOM
- PowerShell requires UTF-8 without BOM
- Without fix → ParseError

### For Claude:

**When generating .ps1 scripts:**
1. Use simple ASCII characters only in comments
2. Avoid special characters (émojis, accents)
3. Remind user to run fix_encoding.ps1
4. Include encoding note in script header

**Example header:**
```powershell
# script_name.ps1
# Version: 1.0.0
# ENCODING: Run .\fix_encoding.ps1 -File "script_name.ps1" before use
```
```

---

### 2. FILE_REGISTRY.md - Agregar nota

**Ubicación:** `FILE_REGISTRY.md`  
**En sección:** `[SYSTEM:FILES]`

```markdown
### Important: PowerShell Script Encoding

**All .ps1 files downloaded from Claude require encoding fix:**

```powershell
# After downloading any .ps1:
.\fix_encoding.ps1 -File "new_script.ps1"
```

**Why:**
- Claude: UTF-8 with BOM
- PowerShell: UTF-8 without BOM
- Fix converts automatically

**If you forget:**
- Script will fail with ParseError
- Run fix_encoding.ps1 to correct
```

---

### 3. PARSER_USAGE_GUIDE.md - Agregar warning

**Ubicación:** `PARSER_USAGE_GUIDE.md`  
**Después de:** Sección de errores comunes

```markdown
### Error 4: Script encoding (ParseError)

**Síntoma:**
```
Token '}' inesperado
ParserError: UnexpectedToken
```

**Causa:** Encoding UTF-8 con BOM

**Solución:**
```powershell
.\fix_encoding.ps1 -File "script.ps1"
```

**Prevención:**
- SIEMPRE correr fix_encoding.ps1 después de descargar .ps1
- Ver POWERSHELL_STANDARDS.md para más info
```

---

### 4. Crear ENCODING_QUICKFIX.md

**Nuevo archivo:** `docs/ENCODING_QUICKFIX.md`

```markdown
# ENCODING QUICK FIX

## Script PowerShell tiene error de ParseError?

### FIX EN 10 SEGUNDOS:

```powershell
cd C:\Users\JoseA\Projects\hub-personal\docs
.\fix_encoding.ps1 -File "NOMBRE_DEL_SCRIPT.ps1"
```

### Listo! Ejecuta de nuevo:

```powershell
.\NOMBRE_DEL_SCRIPT.ps1
```

---

## ¿Por qué pasa esto?

- Claude genera: UTF-8 **con BOM**
- PowerShell necesita: UTF-8 **sin BOM**
- fix_encoding.ps1: Convierte automáticamente

---

## Prevenir en el futuro:

### REGLA DE ORO:

**Cada .ps1 descargado de Claude →**  
**PRIMERO: fix_encoding.ps1**  
**DESPUÉS: ejecutar**

---

## Archivos afectados:

Todos los .ps1:
- verify_registry.ps1 ✅ (ya corregido)
- 08_PARSER.ps1 ✅ (ya corregido)
- update_docs.ps1 ✅ (ya corregido)
- Cualquier .ps1 nuevo ⚠️ (necesita fix)

---

**[FIN]**
```

---

## 🎯 WORKFLOW ACTUALIZADO

### ANTES (propenso a errores):
```
1. Claude genera script.ps1
2. Descargas
3. Copias a docs/
4. Ejecutas
5. ❌ ERROR: ParseError
6. 😫 Frustracion
7. Pides ayuda
8. Regeneras o corriges
```

### DESPUÉS (a prueba de errores):
```
1. Claude genera script.ps1
2. Descargas
3. Copias a docs/
4. Ejecutas: .\fix_encoding.ps1 -File "script.ps1"
5. ✅ Encoding corregido
6. Ejecutas: .\script.ps1
7. ✅ Funciona perfecto
8. 😊 Continúas trabajando
```

---

## 📊 IMPACTO

### Scripts afectados en tu proyecto:

```
✅ Ya corregidos (funcionan):
- 08_PARSER.ps1
- update_docs.ps1
- cleanup_docs.ps1
- fix_encoding.ps1 (sí, se arregla a sí mismo)
- regenerate_scripts.ps1
- verify_registry.ps1

⚠️ Futuros (necesitarán fix):
- Cualquier .ps1 nuevo de Claude
- Cualquier .ps1 actualizado de Claude
```

### Tiempo ahorrado:

**Sin fix:**
- Error: 2 min
- Debug: 5 min
- Regenerar: 3 min
- Total: **10 minutos** por script

**Con fix:**
- Correr fix_encoding.ps1: 5 segundos
- Total: **5 segundos** por script

**Ahorro:** 9 min 55 seg por script ⚡

---

## 🔄 INTEGRACIÓN EN WORKFLOW

### Agregar a IMPLEMENTATION_INSTRUCTIONS.md

**En sección de scripts:**

```markdown
### IMPORTANTE: Encoding de scripts PowerShell

Todos los .ps1 descargados de Claude requieren fix de encoding:

```powershell
# Después de descargar cualquier .ps1:
.\fix_encoding.ps1 -File "nuevo_script.ps1"

# Esto previene errores de ParseError
```

**Razón:**
- Claude genera UTF-8 con BOM
- PowerShell necesita UTF-8 sin BOM
- fix_encoding.ps1 convierte automáticamente
```

---

### Agregar a README_AUTO_VERSIONING.md

**En sección de scripts:**

```markdown
## Encoding Fix (Importante)

**Antes de ejecutar cualquier .ps1 descargado de Claude:**

```powershell
.\fix_encoding.ps1 -File "script.ps1"
```

Ver `ENCODING_QUICKFIX.md` para más detalles.
```

---

## 🎓 PARA CLAUDE

### Cuando generes scripts .ps1:

**1. Incluir header con warning:**
```powershell
# script_name.ps1
# Version: 1.0.0
# ENCODING WARNING: Run fix before use
# Command: .\fix_encoding.ps1 -File "script_name.ps1"
```

**2. Recordar al usuario:**
```markdown
## IMPORTANTE: Encoding Fix

Antes de ejecutar este script, corre:

```powershell
.\fix_encoding.ps1 -File "nuevo_script.ps1"
```

Esto previene errores de ParseError.
```

**3. Usar caracteres ASCII:**
- ✅ Comentarios en inglés simple
- ❌ Emojis en comentarios
- ❌ Acentos en comentarios
- ❌ Caracteres especiales

---

## 🧪 TESTING

### Verificar encoding de un script:

```powershell
# Método 1: Ver primeros bytes
Format-Hex "script.ps1" -Count 16

# UTF-8 con BOM muestra: EF BB BF
# UTF-8 sin BOM: No muestra EF BB BF

# Método 2: Intentar ejecutar
.\script.ps1

# Si falla con ParseError → Necesita fix
# Si ejecuta → Encoding OK
```

---

## 📚 RECURSOS

**Scripts relacionados:**
- `fix_encoding.ps1` - Corrector automático
- `regenerate_scripts.ps1` - Regenera todos los scripts

**Documentación:**
- `POWERSHELL_STANDARDS.md` - Estándares completos
- `ENCODING_QUICKFIX.md` - Fix rápido
- Esta guía - Referencia completa

---

## ✅ CHECKLIST FINAL

### Para José - CADA SESIÓN:

```
Al iniciar sesión:
☐ Verificar que fix_encoding.ps1 existe en docs/
☐ Conocer el comando: .\fix_encoding.ps1 -File "X"

Al descargar .ps1 de Claude:
☐ Descargar archivo
☐ Copiar a docs/
☐ ANTES de ejecutar: .\fix_encoding.ps1 -File "X"
☐ Ejecutar el script
☐ ✅ Funciona

Si hay ParseError:
☐ No entrar en pánico
☐ Correr: .\fix_encoding.ps1 -File "X"
☐ Ejecutar de nuevo
☐ ✅ Ahora funciona
```

### Para Claude - CADA .ps1:

```
Al generar script:
☐ Incluir header con encoding warning
☐ Usar solo caracteres ASCII en comentarios
☐ Recordar al usuario correr fix_encoding.ps1
☐ Proporcionar comando exacto

Al entregar script:
☐ Mencionar encoding fix en instrucciones
☐ Link a ENCODING_QUICKFIX.md
☐ Ejemplos claros
```

---

## 🎯 RESUMEN EJECUTIVO

### El Problema:
Scripts de Claude tienen encoding que PowerShell no acepta

### La Solución:
```powershell
.\fix_encoding.ps1 -File "script.ps1"
```

### La Prevención:
SIEMPRE correr fix_encoding.ps1 antes de ejecutar .ps1 nuevos

### El Resultado:
Cero errores de encoding, cero tiempo perdido

---

**[FIN DE GUÍA]**

**Versión:** 1.1.0  
**Última actualización:** 2025-11-16  
**Status:** Documentado y resuelto permanentemente
