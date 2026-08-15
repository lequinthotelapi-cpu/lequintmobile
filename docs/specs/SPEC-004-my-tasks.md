# SPEC-004 — Mis Tareas (Housekeeper)

**ID**: SPEC-004
**Nombre**: Ver mis tareas asignadas — Housekeeper
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Housekeeper

---

## Objetivo

Permitir al housekeeper ver todas sus tareas asignadas, ordenadas por prioridad, con información suficiente para saber qué habitación limpiar y en qué orden.

## Contexto

El caso de uso más crítico de la app. El housekeeper se desplaza físicamente por el hotel y actualmente debe ir a un escritorio para ver sus tareas. Esta pantalla elimina esa fricción.

## Actores

- Housekeeper (rol: `housekeeper`)

## Precondiciones

- Usuario autenticado con rol `housekeeper`
- Tareas asignadas al usuario en Firestore (`assignedTo == uid`)

## Flujo principal

1. Housekeeper abre la app → ve MyTasksScreen (home del rol)
2. App carga tareas con `status in [pending, in-progress]` asignadas al usuario
3. Tareas ordenadas por: urgente → alta → normal → baja, luego por `scheduledDate`
4. Cada tarea muestra: número de habitación, piso, tipo, prioridad, estado
5. Housekeeper tap en tarea → TaskDetailScreen (SPEC-005)

## Flujo alternativo — Sin tareas

- Si no hay tareas asignadas → mostrar empty state: "No tienes tareas asignadas por ahora"

## Flujo alternativo — Tarea urgente

- Tareas con prioridad `urgent` muestran un indicador visual destacado (borde rojo, badge pulsante)
- Si hay tareas urgentes, aparecen primero independientemente del orden

## Secciones de la lista

La lista se divide en dos secciones:

**En progreso** (si hay alguna):
- Tareas con `status == in-progress`
- Aparecen primero, destacadas

**Pendientes**:
- Tareas con `status == pending`
- Ordenadas por prioridad

## Información por tarea en la lista

```
┌─────────────────────────────────────┐
│ [URGENTE]  Hab. 205 — Piso 2        │
│ Limpieza profunda                   │
│ ● En progreso                       │
└─────────────────────────────────────┘
```

- Chip de prioridad (color según prioridad)
- Número de habitación + piso
- Tipo de tarea (Limpieza, Limpieza profunda, Mantenimiento, Inspección)
- Estado actual (Pendiente / En progreso)
- Ícono de flecha para indicar que es navegable

## Reglas de negocio

1. Solo se muestran tareas con `status in [pending, in-progress]`
2. Las tareas completadas y canceladas NO aparecen en esta lista
3. El orden es: in-progress primero, luego pending por prioridad (urgent > high > normal > low)
4. La lista se actualiza en tiempo real (stream de Firestore)

## Datos

**Query Firestore**:
```
housekeepingTasks
  WHERE assignedTo == currentUserId
  AND status IN ['pending', 'in-progress']
  ORDER BY scheduledDate ASC
```
El ordenamiento por prioridad se hace en el cliente.

## UI/UX

- Lista con scroll vertical
- Pull-to-refresh
- Sección "En progreso" con header diferenciado
- Sección "Pendientes" con header
- Chip de prioridad con color:
  - urgent: rojo #ef4444
  - high: naranja #f59e0b
  - normal: azul #3b82f6
  - low: verde #10b981
- Indicador de estado:
  - pending: punto amarillo
  - in-progress: punto azul animado (pulsante)
- Contador en el header: "X tareas pendientes"

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton de 3-4 tarjetas |
| Success con datos | Lista de tareas |
| Empty | Ícono + "No tienes tareas asignadas por ahora" |
| Error | "No se pudieron cargar tus tareas" + reintentar |
| Offline | Banner + datos del caché |

## Permisos

- Solo rol `housekeeper`
- Cada housekeeper ve SOLO sus propias tareas (filtrado por `assignedTo == uid`)

## Criterios de aceptación

- [ ] Lista muestra solo tareas del usuario actual
- [ ] Tareas in-progress aparecen primero
- [ ] Tareas ordenadas por prioridad (urgent primero)
- [ ] Tareas completadas/canceladas no aparecen
- [ ] Pull-to-refresh actualiza la lista
- [ ] Empty state visible cuando no hay tareas
- [ ] Tap en tarea navega a TaskDetailScreen
- [ ] Lista se actualiza en tiempo real (sin necesidad de refresh manual)
- [ ] Chip de prioridad muestra color correcto

## Consideraciones técnicas

- Usar `StreamProvider` para actualizaciones en tiempo real
- El ordenamiento por prioridad se hace en el cliente con un comparador personalizado
- La pantalla es el `initialLocation` del router para el rol `housekeeper`

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `TaskCard`, `PriorityChip`, `SkeletonLoader`, `EmptyState`
**Referencias**: `docs/design-references/general.jpg`

### Elementos REQUIRED
- `TaskCard` con borde izquierdo del color de prioridad
- `PriorityChip` con colores exactos de `design-tokens.md`
- Sección "En progreso" visualmente diferenciada (header + fondo ligeramente distinto)
- Punto animado (pulsante) para tareas in-progress
- Skeleton de 3-4 tarjetas durante carga
- Empty state con mensaje contextual

### Elementos FLEXIBLE
- Estilo exacto del header de sección
- Animación del punto pulsante
- Contador de tareas en el app bar o en el header de la pantalla
