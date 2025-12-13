# 🚀 START HERE - Guía de Inicio para hub-personal

**Este archivo es tu punto de entrada a cada sesión**

---

## ⚡ Quick Start (1 minuto)

### Si es tu PRIMERA vez en el proyecto:
1. Lee `docs/00_INDEX.md` - Índice de navegación
2. Lee `DOCUMENTATION_STRUCTURE.md` - Cómo funciona la documentación
3. Luego sigue los pasos de abajo

### Si es una sesión POSTERIOR:
1. Mira el "Estado Rápido" abajo
2. Lee `.claude/context.md` si existe (auto-generado)
3. Sigue con lo que necesites

---

## 📊 Estado Rápido

**Última sesión:** 2025-11-24-001
**Última acción:** Integración completa de shadcn-vue
**Rama:** main (up to date)
**Status:** ✅ Ready for next phase

**Línea de comandos rápida:**
```bash
npm run dev              # Inicia desarrollo
npm run build            # Build para prod
php artisan test         # Ejecuta tests
.\08_PARSER.ps1          # Sincroniza documentación @meta
```

---

## 🎯 Dónde Encontrar Qué

### Documentación Técnica
📚 **`docs/01_MASTER_DOC_v2.1.25.md`** - Source of truth (TODO)
- Producto, stack, database, arquitectura, diseño, testing, deployment

🗺️ **`docs/00_INDEX.md`** - Índice con marcadores (LEER PRIMERO)
- Encuentras cualquier tema rápidamente con [MARKER]

📖 **`docs/SHADCN_INTEGRATION.md`** - Manual de componentes UI
- Cómo usar botones, cards, inputs, badges, dialogs

### Sistema de Documentación
📋 **`DOCUMENTATION_STRUCTURE.md`** - Explicación del sistema
- 3 capas, @meta blocks, cómo mantenerlo limpio
- LEE esto para entender cómo documentamos

### Contexto de Esta Sesión
📌 **`.claude/context.md`** - Auto-generado cada sesión
- Estado actual, último commit, próximos pasos
- Temporal, NO se commitea, se descarta después

---

## 🔄 Proceso de Trabajo (Por Sesión)

### INICIO (5 min)
```
1. Abre este archivo (START_HERE.md)
   ↓
2. Si existe .claude/context.md:
   - Lee rápidamente para contexto
   - Conoce el último estado
   ↓
3. Abre docs/00_INDEX.md
   - Navega a lo que necesites
   ↓
4. Comienza a trabajar
```

### DURANTE (variable)
```
1. Escribes código con @meta blocks si es arquitectura

2. Haces commits normales:
   git commit -m "feat(feature): description"

3. Si es feature compleja, creas docs/[feature].md

4. Trabajas normalmente
```

### FINAL (5 min)
```
1. Si hubo cambios arquitectónicos:
   .\08_PARSER.ps1

2. Verificas que MASTER_DOC se actualizó bien

3. Commit final:
   git add [todo]
   git commit -m "docs: Updated documentation"

4. .claude/context.md se descarta automáticamente
   (git lo ignora, no necesitas hacer nada)

5. Haces push si lo necesitas
```

---

## 📍 Marcadores de Búsqueda Rápida

Si buscas info sobre... usa este marcador en MASTER_DOC:

| Tema | Marcador | Línea aprox |
|------|----------|-------------|
| **Notas** | `[DB:SCHEMA_NOTES]` | L590 |
| **Tags** | `[DB:SCHEMA_TAGS]` | L620 |
| **Usuarios** | `[DB:SCHEMA_USERS]` | L570 |
| **Componentes UI** | `[DESIGN:COMPONENTS]` | L1600 |
| **Rutas** | `[ARCH:ROUTING]` | L1100 |
| **Backend Stack** | `[STACK:BACKEND]` | L450 |
| **Frontend Stack** | `[STACK:FRONTEND]` | L500 |

**Ver lista completa:** `docs/00_INDEX.md`

---

## 💡 Sistema de @meta Blocks

Cuando hagas cambios arquitectónicos, agrega este bloque al archivo:

```php
/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Models/MyModel.php
 * @refs: [DB:SCHEMA_USERS]
 * @changes: Created MyModel with relationships
 * @doc-update: [DB:SCHEMA_USERS] ADD MyModel to users relations
 * @meta-end
 */
```

Luego ejecuta: `.\08_PARSER.ps1`

Esto actualiza automáticamente `MASTER_DOC_v2.1.25.md`

---

## 🚀 Próximas Fases (Después de shadcn)

### Esta semana:
- [ ] Refactorizar Notes pages con NoteCard
- [ ] Crear Tags management UI
- [ ] Agregar más componentes (Textarea, Select)

### Próximas 2 semanas:
- [ ] Implementar Calendar
- [ ] Agregar tests para Notes/Tags
- [ ] Comenzar Gamification

### Productivo (4+ semanas):
- [ ] Email integration
- [ ] Meditation feature
- [ ] Global search
- [ ] Deploy a VPS

---

## 🆘 Cuando Necesites Ayuda

**"¿Dónde está la info sobre X?"**
→ Busca en `docs/00_INDEX.md` el marcador [X:Y]

**"¿Cómo agrego un componente nuevo?"**
→ Lee `docs/SHADCN_INTEGRATION.md`

**"¿Cómo documento mis cambios?"**
→ Lee `DOCUMENTATION_STRUCTURE.md` sección @meta

**"¿Qué debería hacer ahora?"**
→ Lee `.claude/context.md` (si existe) para próximos pasos

---

## 📝 Checklist Rápido

Al iniciar cada sesión:
- [ ] Leo `START_HERE.md` (este archivo)
- [ ] Reviso `.claude/context.md` si existe
- [ ] Abro `docs/00_INDEX.md` para navegación
- [ ] Sé qué marcadores usar para encontrar info
- [ ] Entiendo el proceso de work@meta blocks
- [ ] Sé ejecutar `.\08_PARSER.ps1`

### Checklist recurrente antes de commitear
- [ ] Confirmo que cada archivo relevante tiene su bloque @meta actualizado
- [ ] Ejecuto .\hub.ps1 parse <archivo> (o .\hub.ps1 update) para volcar los @meta a MASTER_DOC
- [ ] Reviso y hago git add docs/01_MASTER_DOC_v2.1.25.md (y cualquier doc tocada) antes de commitear
- [ ] Cuando avisamos que estamos listos para commitear, entrego tambi?n el comando git commit -m "..." listo para copiar y pegar


---

## 🎯 TL;DR (Para Impacientes)

```
1. Necesito código?    → Abre docs/00_INDEX.md, busca marker
2. Necesito UI?        → Usa componentes en resources/js/components/ui/
3. Hago cambio grande? → Agrega @meta block, ejecuta 08_PARSER.ps1
4. Dudo de algo?       → Lee DOCUMENTATION_STRUCTURE.md
5. Necesito contexto?  → Abre .claude/context.md (temporal)
6. Terminé?            → git commit, .claude/context.md se ignora auto
```

---

## 📚 Archivos Principales

**Leer primero (en este orden):**
1. **START_HERE.md** (este archivo)
2. **DOCUMENTATION_STRUCTURE.md** (cómo documentamos)
3. **docs/00_INDEX.md** (índice de búsqueda)

**Consultar según necesidad:**
4. **docs/01_MASTER_DOC_v2.1.25.md** (source of truth)
5. **docs/SHADCN_INTEGRATION.md** (manual de componentes)

**Auto-generado por sesión:**
6. **.claude/context.md** (context, se descarta después)

---

## ✅ Listo?

### Ahora que sabes el sistema:

**Primera vez:**
→ Lee `DOCUMENTATION_STRUCTURE.md` para entender el modelo

**Necesitas hacer algo específico:**
→ Abre `docs/00_INDEX.md` y busca el marcador

**Tienes dudas:**
→ Este archivo y DOCUMENTATION_STRUCTURE.md tienen todas las respuestas

---

**Última actualización:** 2025-11-24
**Version:** 1.0
**Status:** Ready to use 🚀

**Próxima sesión:** Abre este archivo de nuevo!
