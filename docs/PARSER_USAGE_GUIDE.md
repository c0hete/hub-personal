# GUÍA COMPLETA DEL PARSER

**Versión:** 1.0.0  
**Fecha:** 2025-11-16  
**Propósito:** Explicar CUÁNDO y CÓMO usar el parser

---

## 🎯 PREGUNTA CLAVE: ¿CUÁNDO CORRER EL PARSER?

### RESPUESTA SIMPLE:

**Cada vez que:**
1. ✅ Creas un archivo con bloque @meta
2. ✅ Modificas un archivo que tiene @meta

**NO necesitas:**
- ❌ Correr el parser si no hay @meta en el código
- ❌ Correr el parser manualmente todo el tiempo
- ❌ Correr el parser para cada archivo del proyecto

---

## 📋 FLUJO COMPLETO EXPLICADO

### PASO A PASO:

```
TÚ (José)                          CLAUDE                    PARSER
═══════════════════════════════════════════════════════════════════════

1. "Necesito crear                →  Genera código con
   un modelo User                     bloque @meta:
   con avatar"                        
                                      /**
                                       * @meta-start
                                       * @session: 2025-11-16-001
                                       * @file: app/Models/User.php
                                       * @refs: [DB:SCHEMA_USERS]
                                       * @changes: Added avatar field
                                       * @doc-update: [DB:SCHEMA_USERS] 
                                       *   ADD avatar VARCHAR(255) NULL
                                       * @meta-end
                                       */

2. Copias el código                   
   al archivo                         
   app/Models/User.php

3. Guardas el archivo
   (Ctrl+S)

4. Ejecutas parser:               →                    →  Lee archivo
   cd docs                                                Encuentra @meta
   .\08_PARSER.ps1                                        Extrae instrucciones
     -File "..\app\Models\User.php"                       
                                                          ↓
                                                       Actualiza MASTER.md:
                                                       - Busca [DB:SCHEMA_USERS]
                                                       - Agrega avatar
                                                       
                                                          ↓
                                                       Versión: 2.1.15 → 2.1.16
                                                       
                                                          ↓
                                                       Git commit automático
                                                       
                                                          ↓
5. ¡Listo! ✅                                          Muestra confirmación
   MASTER.md actualizado
   Versión incrementada
   Commit hecho
```

---

## ❓ PREGUNTAS FRECUENTES

### P1: ¿Tengo que especificar el archivo o es general?

**R:** **DEBES ESPECIFICAR EL ARCHIVO**

```powershell
# ✅ CORRECTO - Especificas el archivo
.\08_PARSER.ps1 -File "..\app\Models\User.php"

# ❌ INCORRECTO - No existe modo "general"
.\08_PARSER.ps1  # Esto no hace nada
```

**¿Por qué?**
- El parser busca @meta solo en el archivo que le dices
- No escanea todo el proyecto automáticamente
- Esto es intencional (más control, más seguro)

---

### P2: ¿Cuándo necesito correr el parser?

**R:** Solo cuando el archivo tiene @meta

**Ejemplos:**

#### ✅ SÍ necesitas parser:

```php
// File: app/Models/Note.php

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: app/Models/Note.php
 * @refs: [DB:SCHEMA_NOTES]
 * @changes: Added is_pinned field
 * @doc-update: [DB:SCHEMA_NOTES] ADD is_pinned BOOLEAN DEFAULT false
 * @meta-end
 */

class Note extends Model {
    protected $fillable = ['title', 'content', 'is_pinned'];
}
```

**Acción:** `.\08_PARSER.ps1 -File "..\app\Models\Note.php"`

#### ❌ NO necesitas parser:

```php
// File: app/Services/EmailService.php

// Servicio simple sin cambios en docs
class EmailService {
    public function sendEmail($to, $subject) {
        // Lógica de envío
    }
}
```

**Acción:** Ninguna - no hay @meta

---

### P3: ¿Qué pasa si olvido correr el parser?

**R:** Tu código funciona bien, pero:

- ❌ MASTER.md no se actualiza
- ❌ Documentación queda desincronizada
- ❌ Versión no se incrementa
- ⚠️ Problema: Docs viejas, código nuevo

**Solución:** Corre el parser cuando te acuerdes. Funciona igual.

---

### P4: ¿Puedo correr el parser varias veces sobre el mismo archivo?

**R:** **Sí, pero...** 

**Primera vez:**
```powershell
.\08_PARSER.ps1 -File "..\app\Models\User.php"
# Resultado: MASTER.md actualizado, versión 2.1.15 → 2.1.16
```

**Segunda vez (mismo archivo, mismo @meta):**
```powershell
.\08_PARSER.ps1 -File "..\app\Models\User.php"
# Resultado: Nada cambia (ya procesado)
# O error: "avatar ya existe en schema"
```

**Recomendación:**
- Una vez por archivo con @meta
- Si cambias el @meta, córrelo de nuevo

---

### P5: ¿Puedo procesar múltiples archivos a la vez?

**R:** **Actualmente NO**, pero hay workaround:

**Opción actual (una a la vez):**
```powershell
.\08_PARSER.ps1 -File "..\app\Models\User.php"
.\08_PARSER.ps1 -File "..\app\Models\Note.php"
.\08_PARSER.ps1 -File "..\app\Http\Controllers\NoteController.php"
```

**Workaround (script manual):**
```powershell
# process_multiple.ps1 (crear este script)
$files = @(
    "..\app\Models\User.php",
    "..\app\Models\Note.php",
    "..\app\Http\Controllers\NoteController.php"
)

foreach ($file in $files) {
    Write-Host "Processing: $file"
    .\08_PARSER.ps1 -File $file
}
```

**Futuro (Feature request):**
```powershell
# Esto NO existe todavía
.\08_PARSER.ps1 -BatchFile "files_to_process.txt"
```

---

## 🔄 WORKFLOW TÍPICO DE DESARROLLO

### Escenario 1: Agregar campo a tabla existente

```
1. Claude genera:
   - Migración con @meta
   - Modelo actualizado con @meta

2. Tú:
   - Copias migración a database/migrations/
   - Copias modelo a app/Models/
   - Guardas ambos
   
3. Parser:
   cd docs
   .\08_PARSER.ps1 -File "..\database\migrations\2025_11_16_add_avatar_to_users.php"
   .\08_PARSER.ps1 -File "..\app\Models\User.php"
   
4. Resultado:
   - MASTER.md actualizado (2 cambios)
   - Versión: 2.1.15 → 2.1.17 (incrementa por cada archivo)
   - 2 commits automáticos
```

---

### Escenario 2: Crear feature completa (Notes CRUD)

```
1. Claude genera (con @meta):
   - Migración: create_notes_table.php
   - Modelo: Note.php
   - Controller: NoteController.php
   - Policy: NotePolicy.php
   - Vue Index: Notes/Index.vue
   - Vue Create: Notes/Create.vue

2. Tú copias todos los archivos

3. Parser (uno por uno):
   cd docs
   .\08_PARSER.ps1 -File "..\database\migrations\xxx_create_notes_table.php"
   .\08_PARSER.ps1 -File "..\app\Models\Note.php"
   .\08_PARSER.ps1 -File "..\app\Http\Controllers\NoteController.php"
   # etc...
   
4. Resultado:
   - MASTER.md actualizado con todos los cambios
   - Versión incrementa por cada archivo procesado
   - Múltiples commits (uno por archivo)
```

**Tiempo:** ~2 minutos para 6 archivos

---

### Escenario 3: Solo código, sin docs

```
1. Claude genera:
   - Servicio simple: EmailService.php
   - NO tiene @meta (no afecta MASTER.md)

2. Tú:
   - Copias a app/Services/
   - Guardas
   - ¡NO CORRES PARSER! (no hay @meta)
   
3. Listo ✅
```

---

## 📊 ESTADÍSTICAS DE TU SESIÓN

**Sesión actual (2025-11-16):**
- Archivos con @meta creados: ~15
- Veces que corriste parser: 11
- Éxito: 11/11 (100%)
- Commits automáticos: 11
- Versión inicial: 2.1.4
- Versión final: 2.1.15
- Incremento: 11 versiones
- **Tiempo ahorrado vs manual:** ~2 horas

---

## ⚙️ COMANDOS DEL PARSER

### Comando básico:
```powershell
cd C:\Users\JoseA\Projects\hub-personal\docs
.\08_PARSER.ps1 -File "RUTA_RELATIVA_AL_ARCHIVO"
```

### Ejemplos de rutas:

**Modelos:**
```powershell
.\08_PARSER.ps1 -File "..\app\Models\User.php"
.\08_PARSER.ps1 -File "..\app\Models\Note.php"
```

**Controllers:**
```powershell
.\08_PARSER.ps1 -File "..\app\Http\Controllers\NoteController.php"
```

**Migraciones:**
```powershell
.\08_PARSER.ps1 -File "..\database\migrations\2025_11_16_create_notes_table.php"
```

**Vue:**
```powershell
.\08_PARSER.ps1 -File "..\resources\js\Pages\Notes\Index.vue"
.\08_PARSER.ps1 -File "..\resources\js\Components\NoteCard.vue"
```

**Scripts/Config:**
```powershell
.\08_PARSER.ps1 -File "..\package.json"
.\08_PARSER.ps1 -File "..\composer.json"
```

---

## 🎨 SALIDA DEL PARSER

### Cuando funciona bien:

```
[OK] Processed: app/Models/User.php
   Updates: 1
   - [DB:SCHEMA_USERS] ADD avatar VARCHAR(255) NULL
   Version: 2.1.15 -> 2.1.16
   Changelog: Updated
   Git: Committed
```

### Cuando hay error:

```
[ERROR] Marker [DB:SCHEMA_XYZ] not found in MASTER.md
File: app/Models/XYZ.php
Line: 15
Action: Skipped, check marker name
```

---

## 🚨 ERRORES COMUNES

### Error 1: Marker no encontrado

**Síntoma:**
```
ERROR: Marker [DB:SCHEMA_PRODUCTS] not found
```

**Causa:** El marker no existe en MASTER.md

**Solución:**
1. Abre MASTER.md
2. Busca el marker (Ctrl+F)
3. Si no existe, créalo o usa otro marker
4. Actualiza el @meta en tu código
5. Corre el parser de nuevo

---

### Error 2: Archivo no encontrado

**Síntoma:**
```
ERROR: File not found: ..\app\Models\User.php
```

**Causa:** Ruta incorrecta

**Solución:**
```powershell
# Verifica que estás en docs/
pwd
# Debe mostrar: C:\Users\JoseA\Projects\hub-personal\docs

# Verifica la ruta relativa
ls ..\app\Models\User.php

# Si existe, corre el parser
.\08_PARSER.ps1 -File "..\app\Models\User.php"
```

---

### Error 3: Parser no ejecuta

**Síntoma:**
```powershell
.\08_PARSER.ps1
# No pasa nada
```

**Causa:** Falta parámetro -File

**Solución:**
```powershell
# ❌ Incorrecto
.\08_PARSER.ps1

# ✅ Correcto
.\08_PARSER.ps1 -File "..\app\Models\User.php"
```

---

## 📝 CHECKLIST DE USO

**Antes de correr el parser:**
```
☐ ¿El archivo tiene bloque @meta?
   → NO: No necesitas parser
   → SÍ: Continúa

☐ ¿Estás en el directorio docs/?
   → pwd debe mostrar: .../hub-personal/docs

☐ ¿Conoces la ruta relativa del archivo?
   → Desde docs/ hasta el archivo
   → Usa ../ para subir un nivel

☐ ¿El marker existe en MASTER.md?
   → Abre MASTER.md
   → Busca el marker (Ctrl+F)
   → Confirma que existe
```

**Al correr el parser:**
```
☐ Usa la sintaxis correcta:
   .\08_PARSER.ps1 -File "RUTA"

☐ Observa la salida:
   → [OK] = Éxito ✅
   → [ERROR] = Revisar ❌

☐ Verifica los cambios:
   → Abre MASTER.md
   → Busca el marker
   → Confirma que se agregó el contenido
```

**Después del parser:**
```
☐ ¿Se actualizó MASTER.md?
☐ ¿Se incrementó la versión?
☐ ¿Hay commit automático?
☐ ¿Necesitas procesar más archivos?
```

---

## 🎯 REGLA DE ORO

```
┌─────────────────────────────────────────┐
│                                         │
│  ¿Archivo tiene @meta?                  │
│                                         │
│  SÍ → Corre el parser                   │
│  NO → No hagas nada                     │
│                                         │
│  ¡Así de simple!                        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📚 RECURSOS RELACIONADOS

**Para más info:**
- `06_METADATA_PROTOCOL.md` - Sintaxis de @meta
- `11_AUTO_VERSIONING_SYSTEM.md` - Cómo funciona versioning
- `README_AUTO_VERSIONING.md` - Guía rápida
- `FULL_PROCESS_REVIEW_2025-11-16.md` - Análisis completo

**Scripts útiles:**
- `08_PARSER.ps1` - El parser
- `update_docs.ps1` - Actualizar version manual
- `verify_registry.ps1` - Verificar archivos

---

## 💡 TIPS PRO

### Tip 1: Script de batch processing

Crea `process_session.ps1`:
```powershell
# Procesar todos los archivos de una sesión
param([string[]]$Files)

foreach ($file in $Files) {
    Write-Host "`n=== Processing: $file ===" -ForegroundColor Cyan
    .\08_PARSER.ps1 -File $file
}

Write-Host "`n=== All files processed ===" -ForegroundColor Green
```

Uso:
```powershell
.\process_session.ps1 -Files @(
    "..\app\Models\User.php",
    "..\app\Models\Note.php",
    "..\app\Http\Controllers\NoteController.php"
)
```

---

### Tip 2: Alias en PowerShell profile

Agrega a tu `$PROFILE`:
```powershell
# Alias para parser
function Parse-Meta {
    param([string]$File)
    Set-Location "C:\Users\JoseA\Projects\hub-personal\docs"
    .\08_PARSER.ps1 -File $File
}

Set-Alias parse Parse-Meta
```

Uso simplificado:
```powershell
# Desde cualquier lugar
parse "..\app\Models\User.php"
```

---

### Tip 3: VS Code Task

Agrega a `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Parse @meta",
      "type": "shell",
      "command": "cd docs && .\\08_PARSER.ps1 -File '${relativeFile}'",
      "group": "build",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

Uso:
1. Abre archivo con @meta
2. `Ctrl+Shift+P`
3. "Tasks: Run Task"
4. "Parse @meta"

---

## 🎬 RESUMEN FINAL

### Lo que NECESITAS saber:

1. **Parser se corre POR ARCHIVO**
   ```powershell
   .\08_PARSER.ps1 -File "RUTA_AL_ARCHIVO"
   ```

2. **Solo si el archivo tiene @meta**
   - No @meta = No parser necesario

3. **Una vez por archivo** (normalmente)
   - Después de crear/modificar
   - Antes de commit final

4. **Desde el directorio docs/**
   - `cd docs` primero
   - Rutas relativas desde ahí

5. **Resultado automático**
   - MASTER.md actualizado
   - Versión incrementada
   - Git commit hecho

### Lo que NO necesitas:

- ❌ Correr parser para cada archivo del proyecto
- ❌ Correr parser si no hay @meta
- ❌ Correr parser más de una vez por archivo
- ❌ Hacer algo manualmente en MASTER.md
- ❌ Hacer commits manuales de docs

---

**¡Listo! Ahora sabes TODO sobre el parser.** 🎉

**¿Dudas?** Revisa esta guía o pregunta.

---

**[FIN DE GUÍA]**

**Versión:** 1.0.0  
**Fecha:** 2025-11-16  
**Autor:** Claude  
**Revisión:** José
