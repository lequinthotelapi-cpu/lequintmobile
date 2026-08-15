# SPEC-008 — Estado de Habitaciones

**ID**: SPEC-008
**Nombre**: Vista de estado de habitaciones
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Receptionist, Manager, Housekeeper, Admin, Superadmin

---

## Objetivo

Permitir a todos los roles ver el estado actual de todas las habitaciones del hotel en tiempo real, con posibilidad de filtrar por estado.

## Contexto

Consulta frecuente para todos los roles. El mapa SVG del sistema web no es viable en móvil. Se implementa como lista/grid con colores de estado.

## Actores

- Todos los roles autenticados

## Precondiciones

- Usuario autenticado

---

## Pantalla: RoomsScreen

### Layout — Vista Grid (por defecto)

```
┌─────────────────────────────────────┐
│  Habitaciones                       │
│  20 habitaciones · 12 ocupadas      │
│                                     │
│  [Todos] [Disp.] [Ocup.] [Sucias]  │  ← chips de filtro
│  [Limpiando] [Mant.] [Reservadas]  │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ 101  │ │ 102  │ │ 103  │        │
│  │ Disp │ │ Ocup │ │Sucia │        │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ 201  │ │ 202  │ │ 203  │        │
│  │Limp. │ │Mant. │ │Reserv│        │
│  └──────┘ └──────┘ └──────┘        │
└─────────────────────────────────────┘
```

### Cada tarjeta de habitación muestra
- Número de habitación (grande, prominente)
- Color de fondo según estado
- Label del estado
- Piso (pequeño, secundario)

### Filtros
- Chips horizontales con scroll: Todos, Disponible, Ocupada, Sucia, En limpieza, Mantenimiento, Reservada
- Chip activo: color del estado correspondiente
- Filtro "Todos" activo por defecto

### Toggle vista
- Ícono para cambiar entre grid y lista
- Vista lista: más información por habitación

---

## Vista Lista

```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────┐    │
│  │ 101 · Piso 1                │    │
│  │ Estándar · 2 personas       │    │
│  │ ● Disponible                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 102 · Piso 1                │    │
│  │ Suite · 4 personas          │    │
│  │ ● Ocupada — Juan García     │    │  ← nombre del huésped si ocupada
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Vista lista muestra adicionalmente
- Tipo de habitación
- Capacidad
- Nombre del huésped si `status == 'occupied'`

---

## Pantalla: RoomDetailScreen

```
┌─────────────────────────────────────┐
│  ← Habitaciones                     │
│                                     │
│  Habitación 205                     │
│  ● Ocupada                          │
│                                     │
│  Piso: 2                            │
│  Tipo: Suite                        │
│  Capacidad: 4 personas              │
│  Precio base: $150.00/noche         │
│                                     │
│  HUÉSPED ACTUAL                     │
│  Juan García                        │
│  Check-out: 18 ene 2025             │
│                                     │
│  [Ver cuenta del huésped →]         │  ← solo si occupied
└─────────────────────────────────────┘
```

### Acciones contextuales por estado

| Estado | Acciones disponibles |
|---|---|
| occupied | "Ver cuenta del huésped" |
| dirty | Informativo (sin acción — la tarea se crea desde housekeeping) |
| cleaning | "Ver tarea de limpieza" (navega a tarea activa) |
| maintenance | "Ver tarea de mantenimiento" |
| available | Sin acciones adicionales |
| reserved | "Ver reserva" (navega a ArrivalDetailScreen) |

---

## Reglas de negocio

1. El estado `reserved` es calculado: habitación `available` con check-in programado para HOY
2. El estado físico se lee de `room.status` en Firestore
3. El nombre del huésped en habitaciones ocupadas se obtiene del booking activo (`status == 'checked-in'`)
4. La lista se actualiza en tiempo real (stream)
5. El housekeeper ve TODAS las habitaciones (DECISION-016)

## Datos

**Stream combinado**:
```dart
// Combinar rooms + bookings para calcular displayStatus
StreamProvider: combineLatest([roomsStream, bookingsStream])
  → calcular displayStatus para cada habitación
  → si room.status == 'available' Y booking.checkInDate == hoy Y status in [confirmed, pending]
    → displayStatus = 'reserved'
  → sino → displayStatus = room.status
```

## Colores de estado

| Estado | Color fondo | Color texto/borde |
|---|---|---|
| available | #d1fae5 | #10b981 |
| reserved | #ede9fe | #8b5cf6 |
| occupied | #fee2e2 | #ef4444 |
| dirty | #fef3c7 | #f59e0b |
| cleaning | #dbeafe | #3b82f6 |
| maintenance | #e0e7ff | #6366f1 |

## UI/UX

- Grid: 3 columnas en teléfonos normales, 4 en tablets
- Tarjetas cuadradas con número grande centrado
- Chips de filtro con scroll horizontal
- Pull-to-refresh
- Contador en el header: "X habitaciones · Y ocupadas"
- Transición suave al cambiar filtro

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton grid |
| Success | Grid/lista de habitaciones |
| Empty (con filtro) | "No hay habitaciones con estado [X]" |
| Error | "No se pudieron cargar las habitaciones" + reintentar |
| Offline | Banner + datos del caché |

## Permisos

- Todos los roles autenticados pueden ver habitaciones
- Ningún rol puede cambiar el estado de habitaciones directamente desde esta pantalla en el MVP

## Criterios de aceptación

- [ ] Grid muestra todas las habitaciones con color de estado correcto
- [ ] Filtros por estado funcionan correctamente
- [ ] Estado "reserved" se calcula correctamente (no se lee de BD)
- [ ] Vista lista muestra nombre del huésped en habitaciones ocupadas
- [ ] RoomDetailScreen muestra información completa
- [ ] Habitación ocupada muestra enlace a cuenta del huésped
- [ ] Pull-to-refresh actualiza los datos
- [ ] Lista se actualiza en tiempo real
- [ ] Housekeeper ve todas las habitaciones

## Consideraciones técnicas

- El stream combinado de rooms + bookings puede ser costoso. Usar `combineLatest` de Riverpod.
- Cachear el resultado del cálculo de displayStatus para evitar recalcular en cada rebuild
- La query de bookings para el estado reserved solo necesita los de hoy: filtrar en cliente

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `RoomCard`, `StatusChip`, `GlassCard`, `SkeletonLoader`, `EmptyState`
**Referencias**: `docs/design-references/general.jpg`, `docs/design-references/dashboard.jpg`

### Elementos REQUIRED
- Vista grid: `RoomCard` cuadrada con color de fondo del estado (colores exactos de `design-tokens.md`)
- Chips de filtro: scroll horizontal, chip activo con color del estado correspondiente
- Toggle grid/lista: ícono en el app bar
- Vista lista: `GlassCard` con más información por habitación
- `RoomDetailScreen`: información en `GlassCard`s por sección
- Colores de estado: IDÉNTICOS al sistema web (ver `design-tokens.md`)
- Skeleton: grid de tarjetas cuadradas durante carga

### Elementos FLEXIBLE
- Número de columnas en el grid (3 en teléfonos, 4 en tablets)
- Estilo del toggle grid/lista
- Información adicional en la vista lista
