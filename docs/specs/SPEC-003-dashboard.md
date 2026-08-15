# SPEC-003 — Dashboard por Rol

**ID**: SPEC-003
**Nombre**: Dashboard principal diferenciado por rol
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Superadmin, Admin, Manager, Receptionist, Housekeeper

---

## Objetivo

Proveer a cada rol una pantalla de inicio que muestre la información más relevante para su trabajo, permitiendo entender el estado del hotel de un vistazo.

## Contexto

Decisión DECISION-009: dashboards diferenciados por rol. El superadmin/admin ve todo. Cada otro rol ve una versión filtrada y adaptada.

## Actores

- Superadmin / Admin: dashboard general completo
- Manager: KPIs operacionales + financieros
- Receptionist: operaciones del día
- Housekeeper: resumen de sus tareas

---

## Dashboard — Superadmin / Admin

### Secciones
1. **Header**: fecha actual, nombre del usuario
2. **KPIs operacionales** (tarjetas):
   - Llegadas hoy (número + ícono)
   - Salidas hoy (número + ícono)
   - Habitaciones ocupadas / total (ej: "12/20")
   - Cuentas abiertas (número)
3. **Estado de habitaciones** (resumen visual con colores):
   - Disponibles, Reservadas, Ocupadas, Sucias, En limpieza, Mantenimiento
4. **KPIs financieros** (tarjetas, período = mes actual):
   - Ingresos del período
   - Tasa de ocupación (%)
   - RevPAR
   - Por cobrar (balance total de cuentas abiertas)
5. **Accesos rápidos**: botones a Llegadas, Salidas, Habitaciones, Tareas

### Datos necesarios
- `bookings`: llegadas hoy, salidas hoy
- `rooms` + `bookings`: estado de habitaciones (RoomStatusService)
- `guestAccounts`: cuentas abiertas, balance total
- `guestAccounts` + `sales`: ingresos del período
- `products`: productos con stock bajo (badge informativo)

---

## Dashboard — Manager

### Secciones
1. **Header**: fecha actual, nombre del usuario
2. **KPIs operacionales**: llegadas hoy, salidas hoy, ocupación actual
3. **Estado de habitaciones**: resumen visual con colores
4. **KPIs financieros** (período = mes actual):
   - Ingresos del período
   - Tasa de ocupación (%)
   - RevPAR
   - Por cobrar
5. **Resumen housekeeping**: pendientes, en progreso, completadas hoy
6. **Accesos rápidos**: Reportes, Habitaciones, Tareas

---

## Dashboard — Receptionist

### Secciones
1. **Header**: fecha actual, nombre del usuario, turno
2. **Llegadas hoy**: contador grande + lista de las próximas 3 (nombre, habitación, hora estimada)
3. **Salidas hoy**: contador grande + lista de las próximas 3
4. **Estado de habitaciones**: resumen visual compacto (solo contadores por estado)
5. **Cuentas abiertas**: contador (cuántas cuentas tienen saldo pendiente)
6. **Accesos rápidos**: botones grandes a Llegadas, Salidas, Habitaciones

### Nota de diseño
Para el recepcionista, los contadores de llegadas y salidas son lo más importante. Deben ser visualmente prominentes.

---

## Dashboard — Housekeeper

### Secciones
1. **Header**: "Buenos días, [nombre]" + fecha
2. **Mis tareas hoy**: 
   - Pendientes (número, color urgente si hay urgentes)
   - En progreso (número)
   - Completadas hoy (número)
3. **Lista de tareas pendientes/en progreso**: las primeras 5, ordenadas por prioridad
   - Chip de prioridad (urgente = rojo, alta = naranja, normal = azul, baja = verde)
   - Número de habitación y piso
   - Tipo de tarea
4. **Acceso rápido**: botón "Ver todas mis tareas"

### Nota de diseño
El housekeeper no necesita ver KPIs financieros ni estado general del hotel. Su dashboard es su lista de trabajo del día.

---

## Reglas de negocio

1. El estado "reserved" de habitaciones es calculado (habitación `available` con check-in HOY)
2. Los KPIs financieros usan el período del mes actual por defecto (DECISION-015)
3. "Por cobrar" = suma de `balance` de todas las `guestAccounts` con `status = 'open'`
4. El resumen de housekeeping del manager muestra tareas de TODOS los empleados

## Datos — Fuentes Firestore

| Dato | Colección | Query |
|---|---|---|
| Llegadas hoy | `bookings` | `checkInDate == hoy AND status in [confirmed, pending]` |
| Salidas hoy | `bookings` | `checkOutDate == hoy AND status == checked-in` |
| Habitaciones | `rooms` + `bookings` | stream combinado |
| Cuentas abiertas | `guestAccounts` | `status == open` |
| Mis tareas | `housekeepingTasks` | `assignedTo == uid AND status in [pending, in-progress]` |
| Ingresos | `guestAccounts` + `sales` | período del mes actual |

## UI/UX

- Pull-to-refresh en todos los dashboards
- Skeleton loading mientras cargan los datos
- Tarjetas con sombra suave, bordes redondeados
- Colores de estado consistentes con el sistema web (ver `navigation.md`)
- Números grandes y legibles para los KPIs principales
- Accesos rápidos como botones con ícono + texto

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton cards en lugar de las tarjetas reales |
| Success | Datos actualizados |
| Error | Mensaje "No se pudieron cargar los datos" + botón reintentar |
| Offline | Banner "Sin conexión — mostrando datos en caché" + datos del caché |

## Permisos

| Rol | Dashboard que ve |
|---|---|
| superadmin | Completo |
| admin | Completo |
| manager | Manager |
| receptionist | Receptionist |
| housekeeper | Housekeeper |

## Criterios de aceptación

- [ ] Superadmin ve KPIs operacionales + financieros + estado habitaciones
- [ ] Manager ve KPIs operacionales + financieros + resumen housekeeping
- [ ] Receptionist ve llegadas/salidas del día prominentes + estado habitaciones
- [ ] Housekeeper ve solo sus tareas del día
- [ ] Pull-to-refresh actualiza todos los datos
- [ ] Skeleton visible durante carga inicial
- [ ] Estado vacío muestra mensaje contextual (ej: "No hay llegadas para hoy")
- [ ] Accesos rápidos navegan a la pantalla correcta
- [ ] Datos financieros muestran el mes actual por defecto
- [ ] Banner offline visible cuando no hay conexión

## Consideraciones técnicas

- Los cálculos financieros (RevPAR, ADR, ocupación) se realizan en el cliente igual que el sistema web
- Usar `StreamProvider` para datos en tiempo real (habitaciones, tareas)
- Usar `FutureProvider` para cálculos financieros (costosos, no necesitan tiempo real)
- El dashboard del housekeeper debe ser el más liviano en términos de queries

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `KPICard`, `GlassCard`, `RoomCard`, `SkeletonLoader`, `EmptyState`, `OfflineBanner`
**Referencias**: `docs/design-references/dashboard.jpg`, `docs/design-references/general.jpg`

### Elementos REQUIRED
- Fondo: gradiente oscuro en todas las variantes de dashboard
- KPIs: componente `KPICard` con número grande (`displayMedium`) + label pequeño
- Estado de habitaciones: colores exactos de `design-tokens.md` (consistentes con sistema web)
- Skeleton: misma estructura que el contenido real, con shimmer
- Pull-to-refresh: en todos los dashboards
- Banner offline: `OfflineBanner` cuando no hay conexión
- Accesos rápidos: botones con ícono + texto, no solo íconos

### Elementos FLEXIBLE
- Composición exacta del grid de KPIs (2 columnas vs 1 columna)
- Orden de las secciones dentro de cada dashboard
- Estilo de los accesos rápidos (botones, chips, lista)
- Animación de entrada de los KPIs
