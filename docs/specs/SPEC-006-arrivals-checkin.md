# SPEC-006 — Llegadas del Día y Check-In

**ID**: SPEC-006
**Nombre**: Llegadas del día y ejecución de check-in
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Receptionist

---

## Objetivo

Permitir al recepcionista ver todas las llegadas programadas para hoy y ejecutar el check-in de un huésped con confirmación explícita.

## Contexto

Operación core de recepción. El check-in puede ocurrir lejos del escritorio. Requiere confirmación para evitar errores (DECISION-010).

## Actores

- Receptionist (rol: `receptionist`)
- Admin, Superadmin (acceso también)

## Precondiciones

- Usuario autenticado con rol receptionist/admin/superadmin
- Reserva con `status == 'confirmed'` y `checkInDate == hoy`

---

## Pantalla: ArrivalsScreen

### Layout

```
┌─────────────────────────────────────┐
│  Llegadas de hoy — 15 ene 2025      │
│  3 llegadas pendientes              │
│                                     │
│  🔍 Buscar por nombre o habitación  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Juan García                 │    │
│  │ Hab. 205 · Suite · 3 noches │    │
│  │ [CONFIRMADA]                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ María López                 │    │
│  │ Hab. 101 · Estándar · 1 noche│   │
│  │ [PENDIENTE]                 │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Información por reserva en lista
- Nombre del huésped
- Número de habitación + tipo de habitación
- Número de noches
- Badge de estado: CONFIRMADA (verde) / PENDIENTE (amarillo)
- Indicador de solicitudes especiales (ícono si existen)

### Búsqueda
- Filtro en tiempo real por nombre del huésped o número de habitación
- Sin botón de búsqueda — filtra mientras escribe

---

## Pantalla: ArrivalDetailScreen

### Layout

```
┌─────────────────────────────────────┐
│  ← Llegadas                         │
│                                     │
│  Juan García                        │
│  VIP ⭐ (si aplica)                 │
│                                     │
│  RESERVA                            │
│  Número: BK-20250115-001            │
│  Habitación: 205 — Suite            │
│  Piso: 2                            │
│  Check-in: 15 ene 2025              │
│  Check-out: 18 ene 2025             │
│  Noches: 3                          │
│  Adultos: 2 · Niños: 0              │
│  Total: $450.00                     │
│  Estado: Confirmada                 │
│                                     │
│  SOLICITUDES ESPECIALES             │
│  "Cama extra, piso alto"            │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      REALIZAR CHECK-IN      │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Campos mostrados
- Nombre completo del huésped + badge VIP si aplica
- Número de reserva
- Habitación (número + tipo + piso)
- Fechas check-in / check-out
- Número de noches
- Adultos y niños
- Total de la reserva
- Estado de la reserva
- Solicitudes especiales (si existen)

### Botón "Realizar Check-In"
- Visible siempre en esta pantalla
- Deshabilitado si `status != 'confirmed'` (con tooltip explicativo)
- Si `status == 'pending'`: botón visible pero con advertencia "La reserva debe estar confirmada"

---

## Flujo — Ejecutar Check-In

1. Receptionist tap "Realizar Check-In"
2. App muestra **ConfirmCheckInDialog**:
   ```
   ¿Confirmar check-in?
   
   Juan García
   Habitación 205 — Suite
   Check-out: 18 ene 2025 (3 noches)
   
   [Cancelar]  [Confirmar Check-In]
   ```
3. Receptionist tap "Confirmar Check-In"
4. App muestra loading
5. App ejecuta en orden (WriteBatch):
   a. Verificar `booking.status == 'confirmed'`
   b. Verificar que no existe `guestAccount` para este `bookingId`
   c. Crear `guestAccount` con cargo de alojamiento
   d. Actualizar `room.status = 'occupied'`
   e. Actualizar `booking.status = 'checked-in'`
6. Éxito:
   - Snackbar: "Check-in realizado — Juan García, Hab. 205"
   - Pop a ArrivalsScreen
   - La reserva desaparece de la lista (ya no tiene status confirmed/pending)
7. Error: mensaje específico, permanecer en ArrivalDetailScreen

---

## Reglas de negocio

1. Solo reservas con `status == 'confirmed'` pueden hacer check-in
2. Si ya existe una `guestAccount` para el `bookingId`, no crear otra (idempotente)
3. La `guestAccount` se crea con cargo de alojamiento: `basePrice * nights`, IVA según parámetro del sistema
4. La habitación cambia a `'occupied'`
5. La reserva cambia a `'checked-in'`
6. Estas operaciones deben ser atómicas (WriteBatch)

## Excepciones

| Condición | Mensaje |
|---|---|
| Reserva no confirmada | "La reserva debe estar confirmada para hacer check-in" |
| Habitación no disponible | "La habitación no está disponible" |
| Error de red | "Error de conexión. Intenta nuevamente." |
| Error genérico | "No se pudo realizar el check-in. Intenta nuevamente." |

## Datos

**Query llegadas**:
```
bookings
  WHERE checkInDate >= startOfToday
  AND checkInDate < startOfTomorrow
  AND status IN ['confirmed', 'pending']
```

**WriteBatch check-in**:
- Create: `guestAccounts/{newId}`
- Update: `rooms/{roomId}` → `status: 'occupied'`
- Update: `bookings/{bookingId}` → `status: 'checked-in'`, `updatedBy`, `updatedAt`

## UI/UX

- Lista con pull-to-refresh
- Búsqueda en tiempo real
- Badge de estado con color (confirmada = verde, pendiente = amarillo)
- ArrivalDetailScreen: layout de tarjetas con secciones claras
- Dialog de confirmación: muestra resumen de la operación
- Loading: overlay semitransparente sobre la pantalla durante el check-in
- Snackbar de éxito con acción "Ver cuenta" (navega a GuestAccountScreen)

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton de lista |
| Success con datos | Lista de llegadas |
| Empty | "No hay llegadas programadas para hoy" |
| Error | "No se pudieron cargar las llegadas" + reintentar |
| Offline | Banner + datos del caché |

## Permisos

- Roles con check-in: `receptionist`, `admin`, `superadmin`
- `manager`: acceso de solo lectura — puede ver llegadas pero NO ejecutar check-in (no es su responsabilidad operativa, ver personas.md)
- `housekeeper`: sin acceso a esta pantalla

## Criterios de aceptación

- [ ] Lista muestra solo llegadas del día actual
- [ ] Búsqueda filtra por nombre y número de habitación
- [ ] ArrivalDetailScreen muestra todos los datos de la reserva
- [ ] Botón check-in deshabilitado si reserva no está confirmed
- [ ] Dialog de confirmación muestra resumen antes de ejecutar
- [ ] Check-in exitoso: reserva desaparece de lista + snackbar
- [ ] Check-in crea guestAccount automáticamente
- [ ] Check-in cambia habitación a occupied
- [ ] Errores muestran mensajes específicos
- [ ] Pull-to-refresh actualiza la lista

## Consideraciones técnicas

- El IVA para la guestAccount se debe leer del parámetro del sistema (DECISION-005). Para el MVP, usar IVA = 0 y dejar un TODO comentado en el código. No mostrar advertencia al usuario — la inconsistencia de IVA es un problema del sistema web que se resolverá allí.
- Usar `WriteBatch` para atomicidad de las 3 operaciones
- La query de llegadas requiere índice compuesto en Firestore: `checkInDate ASC + status ASC`

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `BookingCard`, `GlassCard`, `SearchBar`, `ConfirmDialog`, `LoadingOverlay`, `SkeletonLoader`, `EmptyState`
**Referencias**: `docs/design-references/general.jpg`, `docs/design-references/dashboard.jpg`

### Elementos REQUIRED
- `ArrivalsScreen`: header con fecha + contador de llegadas pendientes
- `BookingCard` con badge de estado (verde=confirmada, amarillo=pendiente)
- `SearchBar` en la parte superior de la lista
- `ArrivalDetailScreen`: información en `GlassCard`s por sección (RESERVA, SOLICITUDES)
- Botón "Realizar Check-In": `PrimaryButton`, color `success`, ancho completo
- Botón deshabilitado con tooltip si reserva no está confirmed
- `ConfirmDialog` con resumen antes de ejecutar
- `LoadingOverlay` durante el check-in
- Snackbar de éxito con acción "Ver cuenta"

### Elementos FLEXIBLE
- Posición del badge VIP (puede ser chip o ícono estrella)
- Estilo del indicador de solicitudes especiales
- Animación de desaparición de la reserva de la lista tras check-in exitoso
