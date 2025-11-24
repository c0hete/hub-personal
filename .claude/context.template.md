# Claude Context - Session [DATE]-[SESSION_NUM]

**Generado automáticamente al inicio de cada sesión**
**Uso:** Este archivo proporciona contexto. Léelo al iniciar, luego descartalo.
**NO se commitea a git.**

---

## 🎯 Estado Actual del Proyecto

### Last Commit
```
[COMMIT_SHA] [COMMIT_MESSAGE]
Date: [DATE]
```

### Rama Actual
```
Branch: main
Status: [up to date | behind | diverged]
```

### Cambios Pendientes
```
Archivos modificados: [COUNT]
Archivos sin stagear: [COUNT]
Archivos sin rastrear: [COUNT]
```

---

## 📊 Progreso General

**Completitud del Proyecto:** [PERCENTAGE]%

| Feature | Status | % |
|---------|--------|---|
| Authentication | [STATUS] | 100% |
| Notes System | [STATUS] | 85% |
| Tags System | [STATUS] | 90% |
| Design System (shadcn) | [STATUS] | 100% |
| Calendar | [STATUS] | 0% |
| Email | [STATUS] | 0% |
| Gamification | [STATUS] | 0% |
| Meditation | [STATUS] | 0% |
| Search | [STATUS] | 15% |
| PWA | [STATUS] | 0% |

---

## 📚 Documentación Principal

### Archivos a Consultar (Aplica siempre)
- **docs/00_INDEX.md** - Índice de navegación con marcadores
- **docs/01_MASTER_DOC_v2.1.25.md** - Documentación técnica completa (ÚNICA SOURCE OF TRUTH)
- **docs/SHADCN_INTEGRATION.md** - Manual de componentes UI

### Archivos Específicos de Cambios Recientes
- [Se generan según commits recientes]

---

## 🔧 Sistema de Documentación

**@meta Blocks:** Todos los cambios arquitectónicos deben incluir:
```php
/**
 * @meta-start
 * @session: [DATE]-[NUM]
 * @file: ruta/del/archivo
 * @refs: [MARKER1, MARKER2]
 * @changes: Descripción clara
 * @doc-update: [MARKER] ADD|MODIFY|DELETE contenido
 * @meta-end
 */
```

**Actualización automática:** Después de cambios importantes, ejecuta:
```bash
.\08_PARSER.ps1
```

---

## 🎯 Próximos Pasos Recomendados

[Se actualizan según estado del proyecto]

### Inmediato (Esta sesión)
- [ ] Paso 1
- [ ] Paso 2
- [ ] Paso 3

### Corto plazo (Esta semana)
- [ ] Paso A
- [ ] Paso B

---

## 💡 Notas Importantes

- **Usa aliases en imports:** `@/components`, `@/ui`, `@/lib`
- **Todos los componentes UI están en:** `resources/js/components/ui/`
- **shadcn-vue es copy-paste:** Modifica sin miedo, el código es tuyo
- **Dark mode:** Ya está integrado en todos los componentes

---

## 🆘 Troubleshooting Rápido

**Error de imports:**
- Verifica que vite.config.js tenga los aliases correctos

**Componentes no cargan estilos:**
- Asegúrate que Tailwind CSS está activo
- Revisa que tailwind.config.js incluye `resources/js/**/*.vue`

**Dark mode no funciona:**
- Agrega clase `dark` al elemento `<html>`

---

## 📞 Referencias Rápidas

```bash
# Desarrollo
npm run dev                    # Inicia servidor dev
npm run build                  # Build para producción

# Database
php artisan migrate           # Ejecuta migraciones
php artisan migrate:fresh --seed  # Reset + seed

# Testing
php artisan test              # Corre todos los tests
php artisan test --coverage   # Con reporte de cobertura

# Documentación
.\08_PARSER.ps1               # Sincroniza @meta blocks a MASTER_DOC
```

---

**Generado:** [AUTO]
**Próxima revisión:** Al iniciar siguiente sesión
**Estado:** Temporal (para esta sesión únicamente)

🎯 **Comienza con:** Leer docs/00_INDEX.md para navegación
