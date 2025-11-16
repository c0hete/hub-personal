# ENCODING QUICK FIX

**Version:** 1.0.0  
**Purpose:** Fix PowerShell encoding errors in 10 seconds

---

## 🚨 ¿Script PowerShell con ParseError?

### Síntoma:
```
Token '}' inesperado en la expresión o la instrucción.
ParserError: UnexpectedToken
```

---

## ⚡ FIX EN 10 SEGUNDOS:

```powershell
cd C:\Users\JoseA\Projects\hub-personal\docs
.\fix_encoding.ps1 -File "NOMBRE_DEL_SCRIPT.ps1"
```

### Listo! Ahora ejecuta:

```powershell
.\NOMBRE_DEL_SCRIPT.ps1
```

✅ **Debe funcionar**

---

## 🤔 ¿Por qué pasa esto?

| Origen | Encoding | PowerShell Acepta |
|--------|----------|-------------------|
| Claude | UTF-8 **con BOM** | ❌ NO |
| fix_encoding.ps1 | UTF-8 **sin BOM** | ✅ SÍ |

**Solución:** `fix_encoding.ps1` convierte automáticamente

---

## 📋 REGLA DE ORO

```
┌─────────────────────────────────────────┐
│                                         │
│  Cada .ps1 descargado de Claude →       │
│                                         │
│  PRIMERO: fix_encoding.ps1              │
│  DESPUÉS: ejecutar                      │
│                                         │
│  ¡Así de simple!                        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎯 WORKFLOW CORRECTO

### PASO 1: Descargar script de Claude
```
Archivo: nuevo_script.ps1
Guardar en: C:\Users\JoseA\Projects\hub-personal\docs\
```

### PASO 2: Fix encoding (OBLIGATORIO)
```powershell
cd C:\Users\JoseA\Projects\hub-personal\docs
.\fix_encoding.ps1 -File "nuevo_script.ps1"
```

**Salida esperada:**
```
Fixing encoding for: nuevo_script.ps1
Encoding fixed successfully!
```

### PASO 3: Ejecutar script
```powershell
.\nuevo_script.ps1
```

✅ **Funciona perfecto**

---

## ⚠️ WORKFLOW INCORRECTO (No hacer)

### ❌ ERROR: Ejecutar sin fix

```powershell
# Descargar script
# Copiar a docs/
.\nuevo_script.ps1  # ❌ FALLA con ParseError
```

**Resultado:**
- 😫 Frustración
- ⏱️ Tiempo perdido debuggeando
- 🔄 Tienes que regenerar

---

## 📊 ARCHIVOS AFECTADOS

### Ya corregidos (funcionan):
```
✅ 08_PARSER.ps1
✅ update_docs.ps1
✅ cleanup_docs.ps1
✅ fix_encoding.ps1
✅ regenerate_scripts.ps1
✅ verify_registry.ps1
```

### Necesitarán fix:
```
⚠️ Cualquier .ps1 NUEVO de Claude
⚠️ Cualquier .ps1 ACTUALIZADO de Claude
```

---

## 🔍 VERIFICAR SI NECESITA FIX

### Método 1: Intentar ejecutar
```powershell
.\script.ps1

# Si muestra ParseError → Necesita fix
# Si ejecuta normal → Está OK
```

### Método 2: Ver encoding
```powershell
Format-Hex "script.ps1" -Count 16

# UTF-8 con BOM: Muestra EF BB BF al inicio
# UTF-8 sin BOM: No muestra EF BB BF
```

---

## 💡 TIPS

### Tip 1: Corregir múltiples scripts
```powershell
# Todos los .ps1 en docs/
Get-ChildItem *.ps1 | ForEach-Object {
    .\fix_encoding.ps1 -File $_.Name
}
```

### Tip 2: Alias para fix
```powershell
# En tu PowerShell profile
function Fix-Encoding {
    param([string]$File)
    .\fix_encoding.ps1 -File $File
}
Set-Alias fix Fix-Encoding

# Uso:
fix "script.ps1"
```

### Tip 3: VS Code Task
```json
{
  "label": "Fix Encoding",
  "type": "shell",
  "command": "cd docs && .\\fix_encoding.ps1 -File '${fileBasename}'",
  "presentation": {
    "reveal": "always"
  }
}
```

---

## 🆘 TROUBLESHOOTING

### Problema: fix_encoding.ps1 no existe

**Solución:**
```powershell
# Descargar de Claude
# O regenerar con:
cd docs
.\regenerate_scripts.ps1
```

---

### Problema: fix_encoding.ps1 también falla

**Solución:**
```powershell
# Pedir a Claude regenerar con encoding correcto:
"Claude, regenera el script con Unix line endings (LF) 
y UTF-8 sin BOM"
```

---

### Problema: Sigo teniendo ParseError después del fix

**Verificar:**
```powershell
# 1. Confirmar que corriste el fix
Get-Item "script.ps1" | Select-Object LastWriteTime

# 2. Ver contenido
Get-Content "script.ps1" -Raw

# 3. Si sigue fallando, pedir a Claude regenerar
```

---

## 📚 MÁS INFORMACIÓN

**Documentos relacionados:**
- `ENCODING_GUIDE.md` - Guía completa
- `POWERSHELL_STANDARDS.md` - Estándares PowerShell
- `03_PROMPTS_v2.3.md` - Reglas de Claude

**Archivos:**
- `fix_encoding.ps1` - Script de corrección
- `regenerate_scripts.ps1` - Regenerar scripts

---

## ✅ RESUMEN

**El problema:**
Scripts de Claude → UTF-8 con BOM → PowerShell error

**La solución:**
```powershell
.\fix_encoding.ps1 -File "script.ps1"
```

**La prevención:**
Correr `fix_encoding.ps1` ANTES de ejecutar cualquier .ps1 nuevo

**El resultado:**
✅ Cero errores  
✅ Cero tiempo perdido  
✅ Scripts funcionan de inmediato

---

**¿Dudas?** Consulta `ENCODING_GUIDE.md`

---

**[FIN]**

**Última actualización:** 2025-11-16  
**Status:** Problema documentado y resuelto
