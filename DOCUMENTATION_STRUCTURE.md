# 📚 Estructura de Documentación - hub-personal

## 🎯 Principio: UNA ÚNICA FUENTE DE VERDAD

La documentación sigue un modelo de **3 capas** para evitar duplicación y mantener todo sincronizado:

---

## 📖 Capa 1: MASTER_DOC (SOURCE OF TRUTH)

**Ubicación:** `docs/01_MASTER_DOC_v2.1.25.md`

**Propósito:** Documentación técnica completa y única del proyecto

**Contenido:**
- Product Requirements (PRD)
- Technical Stack
- Database Schema
- Architecture
- Design System
- Testing Strategy
- Deployment
- Roadmap

**Actualización:**
- Manual via edits
- O automática via `@meta` blocks + `08_PARSER.ps1`

**Cómo usarla:**
1. Abre `docs/00_INDEX.md` para navegación
2. Busca el marker que necesites (ej: `[DB:SCHEMA_NOTES]`)
3. Lee en `01_MASTER_DOC_v2.1.25.md`

---

## 🗺️ Capa 2: INDEX (NAVEGACIÓN)

**Ubicación:** `docs/00_INDEX.md`

**Propósito:** Índice de contenidos con marcadores y líneas

**Contenido:**
- Lista de todos los marcadores
- Líneas exactas donde encontrar cada sección
- Palabras clave para búsqueda
- Respuestas rápidas a preguntas comunes

**Uso:**
```
Pregunta: "¿Dónde está el schema de notas?"
Respuesta: "[DB:SCHEMA_NOTES] L590" en MASTER_DOC
Acción: Ctrl+G en editor → línea 590
```

---

## 🔧 Capa 3: FEATURE DOCS (DETALLE)

**Ubicación:** `docs/[FEATURE_NAME].md`

**Propósito:** Documentación específica de features complejas

**Ejemplos:**
- `docs/SHADCN_INTEGRATION.md` - Manual de componentes UI
- `docs/04-DATABASE/schema.md` - Detalles de DB (si se crean)
- Etc.

**Cuándo crear:**
- Cuando una feature es compleja y necesita tutorial
- Cuando hay muchos detalles que no caben en MASTER_DOC
- Cuando hay código de ejemplo extenso

**Cómo vincular:**
- Desde MASTER_DOC: `[REF:SHADCN_INTEGRATION]`
- Desde aquí: Referenciar `docs/00_INDEX.md` para contexto

---

## ⚡ Capa 4: CONTEXTO TEMPORAL (POR SESIÓN)

**Ubicación:** `.claude/context.md`

**Propósito:** Contexto auto-generado para cada sesión

**Contenido:**
- Estado actual del proyecto
- Último commit
- Cambios pendientes
- Próximos pasos recomendados
- Referencias rápidas

**Características:**
- Se genera automáticamente al inicio de sesión
- Se descarta al terminar sesión
- **NO se commitea a git**

**Uso:**
1. Léelo al iniciar sesión
2. Úsalo como referencia rápida
3. Descartalo (git lo ignora automáticamente)

---

## @meta System (AUTOMATIZACIÓN)

**Objetivo:** Mantener MASTER_DOC actualizado automáticamente

### Estructura @meta Block

```php
/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: ruta/del/archivo.php
 * @refs: [MARKER1, MARKER2]
 * @changes: Descripción clara de cambios
 * @doc-update: [MARKER] ADD|MODIFY|DELETE contenido
 * @meta-end
 */
```

### Campos

| Campo | Propósito | Ejemplo |
|-------|-----------|---------|
| `@session` | ID único de sesión | `2025-11-24-001` |
| `@file` | Ruta del archivo modificado | `app/Models/Note.php` |
| `@refs` | Marcadores relacionados | `[DB:SCHEMA_NOTES]` |
| `@changes` | Descripción clara | `Created Note model with relationships` |
| `@doc-update` | Instrucción de actualización | `[DB:SCHEMA_NOTES] ADD Note.php model` |

### Opciones de doc-update

```
ADD [MARKER] contenido nuevo
MODIFY [MARKER] old_text -> new_text
DELETE [MARKER] contenido a remover
MOVE contenido TO [TARGET_MARKER]
```

### Ejecutar Parser

```bash
# Procesa TODOS los @meta blocks y actualiza MASTER_DOC
.\08_PARSER.ps1

# Procesa un archivo específico
.\08_PARSER.ps1 -File "app/Models/Note.php"
```

---

## 📋 Cuándo Usar Cada Capa

### MASTER_DOC (Siempre)
- ✅ Cambios de arquitectura
- ✅ Nuevos modelos/tablas
- ✅ Cambios en rutas/API
- ✅ Decisiones técnicas
- ✅ Schema de DB
- ✅ Información de deployment

### FEATURE DOC (A veces)
- ✅ Feature compleja con tutorial
- ✅ Documentación de usuario
- ✅ Ejemplos de código extenso
- ✅ Procedimientos paso-a-paso

### CONTEXTO TEMPORAL (Esta sesión)
- ✅ Recordatorios personales
- ✅ Estado rápido actual
- ✅ Próximos pasos para hoy
- ✅ Troubleshooting rápido

### NO DOCUMENTAR (Nunca commitees)
- ❌ Archivos SESSION_*.md
- ❌ Archivos CURRENT_STATUS.txt
- ❌ Archivos temporales de setup
- ❌ .claude/context.md

---

## 🔍 Ejemplo: Agregando Nueva Feature

### Paso 1: Escribir Código
```php
// app/Models/NewModel.php

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Models/NewModel.php
 * @refs: [DB:SCHEMA_NEWMODEL]
 * @changes: Created NewModel with relationships
 * @doc-update: [DB:SCHEMA_TABLES] ADD NewModel to table list
 * @doc-update: [DB:RELATIONS] ADD NewModel relationships
 * @meta-end
 */

class NewModel extends Model { ... }
```

### Paso 2: Ejecutar Parser
```bash
.\08_PARSER.ps1
```

### Paso 3: Verificar MASTER_DOC
```
docs/01_MASTER_DOC_v2.1.25.md se actualiza automáticamente
```

### Paso 4: Commitear
```bash
git add app/Models/NewModel.php
git commit -m "feat(models): Add NewModel with relationships"
```

---

## 🎯 Workflow por Sesión

### Inicio (5 min)
1. Leer `.claude/context.md` (si existe)
2. Leer `docs/00_INDEX.md` para navegación
3. Revisar `docs/01_MASTER_DOC_v2.1.25.md` según necesidad

### Durante (variable)
1. Escribir código con `@meta` blocks
2. Hacer commits normales
3. Documentar en FEATURE DOCs si es necesario

### Final (5 min)
1. Ejecutar `.\08_PARSER.ps1` si hubo cambios arquitectónicos
2. Verificar que MASTER_DOC se actualizó correctamente
3. Hacer commit final de documentación
4. `.claude/context.md` se descarta (git lo ignora)

---

## 📝 Marcadores Disponibles

### PRD (Product Requirements)
```
[PRD:NOTES_SYSTEM]
[PRD:CALENDAR]
[PRD:TAGS]
[PRD:GAMIFICATION]
[PRD:EMAIL]
[PRD:MEDITATION]
[PRD:SEARCH]
[PRD:PWA]
```

### Database
```
[DB:SCHEMA_USERS]
[DB:SCHEMA_NOTES]
[DB:SCHEMA_TAGS]
[DB:SCHEMA_GAMIFICATION]
[DB:SCHEMA_EMAIL]
[DB:SCHEMA_CALENDAR]
[DB:RELATIONS]
[DB:MIGRATIONS]
```

### Architecture
```
[ARCH:FOLDERS]
[ARCH:PATTERNS]
[ARCH:ROUTING]
[ARCH:EVENTS]
```

### Design System
```
[DESIGN:COLORS]
[DESIGN:TYPOGRAPHY]
[DESIGN:COMPONENTS]
[DESIGN:SPACING]
[DESIGN:SHADCN_COMPONENTS]
```

### Otros
```
[STACK:BACKEND]
[STACK:FRONTEND]
[AUTH:BREEZE]
[AUTH:POLICY]
[PERF:CACHING]
[TEST:STRATEGY]
[DEPLOY:CICD]
[ROADMAP:MVP]
```

**Ver lista completa:** `docs/00_INDEX.md`

---

## ❌ Archivos a IGNORAR (No commitear)

```
SESSION_*.md
CURRENT_STATUS.txt
QUICK_START_*.md
setup-shadcn.ps1
.claude/context.md
.claude/session-context.md
```

Estos están en `.gitignore` automáticamente.

---

## ✅ Checklist para Usar Bien la Documentación

- [ ] Leo `docs/00_INDEX.md` cuando necesito información
- [ ] Busco marcadores en `docs/01_MASTER_DOC_v2.1.25.md`
- [ ] Agrego `@meta` blocks a código nuevo
- [ ] Ejecuto `.\08_PARSER.ps1` después de cambios importantes
- [ ] No creo archivos duplicados de documentación
- [ ] Descarto `.claude/context.md` después de cada sesión
- [ ] Mantengo MASTER_DOC como source of truth

---

## 🆘 Troubleshooting

**"No encuentro la información en MASTER_DOC"**
→ Busca el marcador en `docs/00_INDEX.md`

**"El parser no actualizó MASTER_DOC"**
→ Verifica que el `@meta` block esté bien formado
→ Ejecuta: `.\08_PARSER.ps1 -Verbose`

**"¿Debo documentar cada cambio pequeño?"**
→ Solo cambios arquitectónicos/schema. Bug fixes y refactoring no.

**"¿Dónde pongo tutoriales largos?"**
→ En `docs/[FEATURE].md`. Luego referencia desde MASTER_DOC.

---

## 📞 Referencias Rápidas

- **Índice:** `docs/00_INDEX.md`
- **Source of Truth:** `docs/01_MASTER_DOC_v2.1.25.md`
- **Componentes UI:** `docs/SHADCN_INTEGRATION.md`
- **Contexto de sesión:** `.claude/context.md` (temporal)

---

**Última actualización:** 2025-11-24
**Sistema de documentación:** Operacional ✅
**Status:** Listo para usar 🚀
