# SPEC-005 — Completar Tarea (Housekeeper)

**ID**: SPEC-005
**Nombre**: Detalle, inicio y completación de tarea — Housekeeper
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Housekeeper

---

## Objetivo

Permitir al housekeeper ver el detalle completo de una tarea, iniciarla cuando comienza a trabajar en ella, y marcarla como completada al terminar, reportando duración, notas y si encontró algún problema que requiera mantenimiento.

## Contexto

La completación de tareas es la acción más frecuente del housekeeper durante su turno. Ocurre físicamente en la habitación. El flujo debe ser rápido y claro.

## Actores

- Housekeeper (rol: `housekeeper`)

## Precondiciones

- Usuario autenticado con rol `housekeeper`
- Tarea asignada al usuario actual
- Para iniciar: `task.status == 'pending'` y `task.assignedTo == uid`
- Para completar: `task.status == 'in-progress'`

---

## Pantalla: TaskDetailScreen

### Información mostrada

```
┌─────────────────────────────────────┐
│  ← Mis Tareas                       │
│                                     │
│  Habitación 205 — Piso 2            │
│  [URGENTE] Limpieza Profunda        │
│                                     │
│  Estado: ● Pendiente                │
│  Programada: Hoy, 10:00 AM          │
│  Duración estimada: 45 min          │
│                                     │
│  Notas del supervisor:              │
│  "Revisar baño con cuidado"         │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     INICIAR TAREA           │    │  ← visible si status == pending
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     COMPLETAR TAREA         │    │  ← visible si status == in-progress
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Campos mostrados
- Número de habitación + piso
- Chip de prioridad (color)
- Tipo de tarea (label en español)
- Estado actual
- Fecha/hora programada
- Duración estimada (minutos)
- Notas del supervisor (si existen)
- `startedAt` si ya fue iniciada

---

## Flujo — Iniciar Tarea

1. Housekeeper tap "Iniciar Tarea"
2. App muestra confirmación: "¿Iniciar limpieza de habitación 205?"
3. Housekeeper confirma
4. App actualiza: `status = 'in-progress'`, `startedAt = now()`
5. Loading indicator durante la operación
6. Éxito: UI actualiza el estado en pantalla, botón cambia a "Completar Tarea"
7. Error: mensaje específico

**Validaciones**:
- `task.status` debe ser `'pending'`
- `task.assignedTo` debe ser el usuario actual

---

## Flujo — Completar Tarea

1. Housekeeper tap "Completar Tarea"
2. App navega a CompleteTaskScreen (o abre bottom sheet)
3. Housekeeper completa el formulario
4. Housekeeper tap "Confirmar Completación"
5. App ejecuta la operación
6. Éxito: navegar de vuelta a MyTasksScreen con mensaje de éxito
7. Error: mensaje específico, permanecer en pantalla

---

## Pantalla: CompleteTaskScreen

### Formulario (igual que sistema web — DECISION-011)

```
┌─────────────────────────────────────┐
│  Completar Tarea                    │
│  Habitación 205                     │
│                                     │
│  Duración real (minutos) *          │
│  ┌─────────────────────────────┐    │
│  │  30                         │    │
│  └─────────────────────────────┘    │
│                                     │
│  Notas de completación              │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ☐ Requiere mantenimiento           │
│                                     │
│  [si checkbox activo:]              │
│  Notas de mantenimiento             │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   CONFIRMAR COMPLETACIÓN    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Cancelar                           │
└─────────────────────────────────────┘
```

### Campos
- **Duración real** (número, minutos): requerido, mínimo 1
- **Notas de completación** (texto libre): opcional
- **¿Requiere mantenimiento?** (checkbox): opcional
- **Notas de mantenimiento** (texto libre): visible y requerido si checkbox activo

---

## Reglas de negocio

1. Solo se puede iniciar una tarea con `status == 'pending'`
2. Solo se puede completar una tarea con `status == 'in-progress'`
3. Si la tarea está `pending` y el usuario toca "Completar", el sistema la inicia automáticamente primero (igual que sistema web)
4. Duración real debe ser > 0
5. Si `requiresMaintenance == true`:
   - Habitación cambia a `'maintenance'`
   - Se crea automáticamente una nueva tarea de mantenimiento
6. Si `requiresMaintenance == false`:
   - Habitación cambia a `'available'`
   - `room.assignedHousekeeperId` se limpia
7. La tarea completada desaparece de MyTasksScreen (ya no tiene status pending/in-progress)

## Excepciones

| Condición | Mensaje |
|---|---|
| Tarea no encontrada | "No se encontró la tarea" |
| Tarea ya completada | "Esta tarea ya fue completada" |
| Tarea no asignada al usuario | "No tienes permiso para modificar esta tarea" |
| Duración = 0 | "La duración debe ser mayor a 0" |
| Sin conexión al completar | "Sin conexión. La completación se guardará cuando recuperes conexión." |

## UI/UX

- Botón "Iniciar Tarea": color primario, ícono play
- Botón "Completar Tarea": color verde, ícono check
- Confirmación de inicio: dialog simple con "Cancelar" / "Iniciar"
- CompleteTaskScreen: pantalla completa (no modal) para dar espacio al formulario
- Teclado numérico para el campo de duración
- Checkbox de mantenimiento con animación al expandir las notas
- Botón "Confirmar" deshabilitado si duración está vacía o = 0

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading (iniciar) | Botón con spinner, pantalla no interactuable |
| Loading (completar) | Botón con spinner |
| Success (iniciar) | UI actualiza estado en pantalla |
| Success (completar) | Pop a MyTasksScreen + snackbar "Tarea completada" |
| Error | Snackbar con mensaje específico |

## Permisos

- Solo rol `housekeeper`
- Solo puede modificar tareas asignadas a sí mismo

## Criterios de aceptación

- [ ] TaskDetailScreen muestra toda la información de la tarea
- [ ] Botón "Iniciar" visible solo si status == pending
- [ ] Botón "Completar" visible solo si status == in-progress
- [ ] Iniciar tarea muestra confirmación antes de ejecutar
- [ ] Iniciar tarea actualiza el estado en pantalla inmediatamente
- [ ] CompleteTaskScreen valida duración > 0
- [ ] Campo de notas de mantenimiento aparece solo si checkbox activo
- [ ] Completar tarea sin mantenimiento cambia habitación a available
- [ ] Completar tarea con mantenimiento cambia habitación a maintenance
- [ ] Tarea completada desaparece de MyTasksScreen
- [ ] Errores muestran mensajes específicos

## Consideraciones técnicas

- Las operaciones de completar tarea involucran múltiples documentos (task + room). Usar `WriteBatch` para atomicidad.
- Si `requiresMaintenance`, crear la nueva tarea de mantenimiento en el mismo batch
- El campo `issuesFound` del modelo se puede dejar como array vacío en el MVP (el sistema web lo usa pero no es crítico para el housekeeper móvil)

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `GlassCard`, `PrimaryButton`, `ConfirmDialog`, `LoadingOverlay`, `TextInput`
**Referencias**: `docs/design-references/controls.jpg`, `docs/design-references/general.jpg`

### Elementos REQUIRED
- `TaskDetailScreen`: información en `GlassCard`s separadas por sección
- Botón "Iniciar Tarea": `PrimaryButton`, color `accentPrimary`
- Botón "Completar Tarea": `PrimaryButton`, color `success`
- Confirmación de inicio: `ConfirmDialog` simple
- `CompleteTaskScreen`: pantalla completa (no modal) con formulario en `GlassCard`
- Campo duración: `AppTextInput` con teclado numérico
- Checkbox mantenimiento: animación de expansión al activar el campo de notas
- Botón confirmar: deshabilitado si duración vacía o = 0
- `LoadingOverlay` durante la operación de completar

### Elementos FLEXIBLE
- Animación exacta de expansión del campo de mantenimiento
- Estilo del checkbox (puede ser switch o checkbox nativo)
- Disposición de los campos en el formulario
