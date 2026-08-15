# SPEC-007 — Salidas del Día y Check-Out

**ID**: SPEC-007
**Nombre**: Salidas del día y ejecución de check-out
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Receptionist

---

## Objetivo

Permitir al recepcionista ver todas las salidas programadas para hoy, verificar el saldo de la cuenta del huésped, y ejecutar el check-out con confirmación explícita.

## Actores

- Receptionist, Admin, Superadmin

## Precondiciones

- Usuario autenticado con rol receptionist/admin/superadmin
- Reserva con `status == 'checked-in'` y `checkOutDate == hoy`

---

## Pantalla: DeparturesScreen

### Layout

```
┌─────────────────────────────────────┐
│  Salidas de hoy — 15 ene 2025       │
│  2 salidas pendientes               │
│                                     │
│  🔍 Buscar por nombre o habitación  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Juan García                 │    │
│  │ Hab. 205 · Suite            │    │
│  │ Saldo: $0.00 ✓              │    │  ← verde si balance = 0
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ María López                 │    │
│  │ Hab. 101 · Estándar         │    │
│  │ Saldo: $85.00 ⚠             │    │  ← naranja/rojo si balance > 0
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Información por reserva en lista
- Nombre del huésped
- Número de habitación + tipo
- Saldo pendiente de la cuenta (balance de guestAccount)
  - $0.00 con ícono ✓ verde: listo para check-out
  - $XX.XX con ícono ⚠ naranja: tiene saldo pendiente

---

## Pantalla: DepartureDetailScreen

### Layout

```
┌─────────────────────────────────────┐
│  ← Salidas                          │
│                                     │
│  Juan García                        │
│                                     │
│  RESERVA                            │
│  Número: BK-20250115-001            │
│  Habitación: 205 — Suite            │
│  Check-in: 12 ene 2025              │
│  Check-out: 15 ene 2025             │
│  Noches: 3                          │
│                                     │
│  CUENTA                             │
│  Total: $450.00                     │
│  Pagado: $450.00                    │
│  Saldo: $0.00                       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      REALIZAR CHECK-OUT     │    │  ← habilitado solo si balance = 0
│  └─────────────────────────────┘    │
│                                     │
│  [si balance > 0:]                  │
│  ⚠ Saldo pendiente: $85.00          │
│  El huésped debe saldar su cuenta   │
│  antes del check-out.               │
│  Ver cuenta →                       │
└─────────────────────────────────────┘
```

### Campos mostrados
- Nombre del huésped
- Datos de la reserva (número, habitación, fechas, noches)
- Resumen de cuenta: total, pagado, saldo
- Advertencia prominente si balance > 0
- Enlace "Ver cuenta" → GuestAccountScreen (SPEC-011)

### Botón "Realizar Check-Out"
- **Habilitado** solo si `guestAccount.balance == 0`
- **Deshabilitado** con mensaje explicativo si `balance > 0`

---

## Flujo — Ejecutar Check-Out

1. Receptionist tap "Realizar Check-Out"
2. App verifica `guestAccount.balance == 0` (segunda verificación)
3. App muestra **ConfirmCheckOutDialog**:
   ```
   ¿Confirmar check-out?
   
   Juan García
   Habitación 205 — Suite
   Estadía: 3 noches
   Total pagado: $450.00
   
   [Cancelar]  [Confirmar Check-Out]
   ```
4. Receptionist tap "Confirmar Check-Out"
5. App muestra loading
6. App ejecuta en WriteBatch:
   a. Verificar `booking.status == 'checked-in'`
   b. Verificar `guestAccount.balance == 0`
   c. Actualizar `room.status = 'dirty'`
   d. Actualizar `booking.status = 'checked-out'`
7. Éxito:
   - Snackbar: "Check-out realizado — Juan García, Hab. 205"
   - Pop a DeparturesScreen
   - La reserva desaparece de la lista
8. Error: mensaje específico

---

## Reglas de negocio

1. Solo reservas con `status == 'checked-in'` pueden hacer check-out
2. `guestAccount.balance` debe ser exactamente `0` para permitir check-out
3. La habitación cambia a `'dirty'` (no `'available'` — debe limpiarse primero)
4. La `guestAccount` permanece abierta hasta que se cierre manualmente desde el sistema web
5. Estas operaciones deben ser atómicas (WriteBatch)

## Excepciones

| Condición | Mensaje |
|---|---|
| Balance > 0 | "El huésped tiene saldo pendiente de $XX.XX. Debe saldar la cuenta antes del check-out." |
| Reserva no en checked-in | "Esta reserva no tiene check-in activo" |
| guestAccount no encontrada | "No se encontró la cuenta del huésped" |
| Error de red | "Error de conexión. Intenta nuevamente." |

## Datos

**Query salidas**:
```
bookings
  WHERE checkOutDate >= startOfToday
  AND checkOutDate < startOfTomorrow
  AND status == 'checked-in'
```

**Para mostrar saldo**: obtener `guestAccount` donde `bookingId == booking.id`

**WriteBatch check-out**:
- Update: `rooms/{roomId}` → `status: 'dirty'`
- Update: `bookings/{bookingId}` → `status: 'checked-out'`, `updatedBy`, `updatedAt`

## UI/UX

- Indicador de saldo en la lista: verde ($0) / naranja/rojo (>$0)
- DepartureDetailScreen: sección de cuenta con colores claros
- Advertencia de saldo pendiente: card con fondo naranja claro, texto explicativo
- Enlace "Ver cuenta" para ir a GuestAccountScreen
- Dialog de confirmación: muestra resumen completo
- Botón check-out: gris/deshabilitado si balance > 0, verde si balance = 0

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton de lista |
| Success con datos | Lista de salidas |
| Empty | "No hay salidas programadas para hoy" |
| Error | "No se pudieron cargar las salidas" + reintentar |
| Offline | Banner + datos del caché |

## Permisos

- Roles: `receptionist`, `admin`, `superadmin`

## Criterios de aceptación

- [ ] Lista muestra solo salidas del día actual
- [ ] Saldo visible en la lista (verde si $0, naranja si >$0)
- [ ] DepartureDetailScreen muestra resumen de cuenta
- [ ] Botón check-out deshabilitado si balance > 0
- [ ] Advertencia de saldo pendiente visible y clara
- [ ] Enlace "Ver cuenta" navega a GuestAccountScreen
- [ ] Dialog de confirmación muestra resumen antes de ejecutar
- [ ] Check-out exitoso: reserva desaparece de lista + snackbar
- [ ] Check-out cambia habitación a dirty
- [ ] Errores muestran mensajes específicos

## Consideraciones técnicas

- Necesita cargar la `guestAccount` asociada a cada booking para mostrar el saldo en la lista. Esto puede ser costoso si hay muchas salidas. Estrategia: cargar las guestAccounts en paralelo con las reservas usando `Future.wait`.
- La query de salidas requiere índice compuesto: `checkOutDate ASC + status ASC`

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `BookingCard`, `GlassCard`, `ConfirmDialog`, `LoadingOverlay`, `SkeletonLoader`, `EmptyState`
**Referencias**: `docs/design-references/general.jpg`

### Elementos REQUIRED
- `DeparturesScreen`: indicador de saldo en cada `BookingCard` (verde $0 / naranja >$0)
- `DepartureDetailScreen`: sección CUENTA con `GlassCard` y colores semánticos
- Advertencia de saldo pendiente: `GlassCard` con fondo `warningBg`, borde `warning`, texto explicativo
- Botón "Realizar Check-Out": `PrimaryButton` verde si balance=0, deshabilitado si balance>0
- Enlace "Ver cuenta": visible y accesible cuando hay saldo pendiente
- `ConfirmDialog` con resumen completo (noches, total pagado)
- `LoadingOverlay` durante el check-out

### Elementos FLEXIBLE
- Estilo exacto del indicador de saldo en la lista (chip vs texto coloreado)
- Posición del enlace "Ver cuenta" en la pantalla de detalle
