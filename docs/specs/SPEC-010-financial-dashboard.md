# SPEC-010 — Dashboard Financiero

**ID**: SPEC-010
**Nombre**: Dashboard financiero y KPIs (Manager / Superadmin)
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Manager, Superadmin, Admin

---

## Objetivo

Permitir al gerente y propietario consultar los indicadores financieros clave del hotel desde cualquier lugar, con filtros de período.

## Contexto

El gerente y propietario necesitan visibilidad financiera sin necesidad de abrir una laptop. Los cálculos son los mismos que el sistema web (FinancialReportsService). Período por defecto: mes actual (DECISION-015).

## Actores

- Manager, Superadmin, Admin

## Precondiciones

- Usuario autenticado con rol manager/superadmin/admin

---

## Pantalla: ReportsScreen (o FinancialDashboardScreen)

### Layout

```
┌─────────────────────────────────────┐
│  Reportes Financieros               │
│                                     │
│  [Hoy] [Semana] [Mes ✓] [Año]      │  ← selector de período
│                                     │
│  INGRESOS                           │
│  ┌─────────────────────────────┐    │
│  │  $12,450.00                 │    │
│  │  Mes actual                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────────┐  ┌──────────┐         │
│  │ Ocupación│  │  RevPAR  │         │
│  │  78.5%   │  │  $45.20  │         │
│  └──────────┘  └──────────┘         │
│                                     │
│  ┌──────────┐  ┌──────────┐         │
│  │   ADR    │  │Por Cobrar│         │
│  │  $57.50  │  │ $850.00  │         │
│  └──────────┘  └──────────┘         │
│                                     │
│  INGRESOS POR FUENTE                │
│  Alojamiento    $9,800  ████████    │
│  POS Directo    $1,850  ████        │
│  Servicios      $800    ██          │
│                                     │
│  CUENTAS ABIERTAS (Por cobrar)      │
│  ┌─────────────────────────────┐    │
│  │ Juan García · Hab. 205      │    │
│  │ Saldo: $450.00 · 3 días     │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

## Secciones

### 1. Selector de período
- Chips: Hoy / Semana / Mes (activo por defecto) / Año
- Al cambiar período: recalcular todos los KPIs

### 2. KPI Principal — Ingresos totales
- Número grande y prominente
- Subtítulo con el período seleccionado
- Fórmula: `Σ guestAccounts.total (cerradas en período) + Σ sales.total (en período)`

### 3. KPIs secundarios (grid 2x2)
- **Ocupación**: `(noches vendidas / noches disponibles) * 100`
- **RevPAR**: `ingresos totales / (totalRooms * días del período)`
- **ADR**: `ingresos totales / noches vendidas`
- **Por cobrar**: `Σ guestAccounts.balance WHERE status = 'open'`

### 4. Ingresos por fuente (barras horizontales simples)
- Alojamiento
- POS Directo
- Servicios
- Otros
- Sin librería de gráficos compleja — barras simples con Container + porcentaje

### 5. Cuentas abiertas (por cobrar)
- Lista de las cuentas con mayor saldo primero
- Máximo 5 en el dashboard
- Cada ítem: nombre del huésped, habitación, saldo, días abierta
- Tap → GuestAccountScreen

---

## Reglas de negocio

1. Período por defecto: mes actual (primer día del mes hasta hoy)
2. "Hoy": desde las 00:00 hasta las 23:59 del día actual
3. "Semana": últimos 7 días
4. "Mes": primer día del mes actual hasta hoy
5. "Año": primer día del año actual hasta hoy
6. Los cálculos se realizan en el cliente (igual que el sistema web)
7. "Por cobrar" siempre muestra el valor actual (no filtrado por período)

## Fórmulas de cálculo

```dart
// Ingresos totales
totalRevenue = 
  guestAccounts.where(status='closed' && closedAt IN period).sum(total) +
  sales.where(createdAt IN period).sum(total)

// Ocupación
occupancyRate = (nightsSold / nightsAvailable) * 100
nightsAvailable = activeRooms.count * daysInPeriod
nightsSold = bookings.where(status IN [checked-in, checked-out] && overlaps period)
             .sum(nightsInPeriod)

// RevPAR
revPAR = totalRevenue / (activeRooms.count * daysInPeriod)

// ADR
adr = totalRevenue / nightsSold

// Por cobrar
accountsReceivable = guestAccounts.where(status='open').sum(balance)
```

## Datos — Colecciones necesarias

| Dato | Colección |
|---|---|
| Ingresos de cuentas | `guestAccounts` (cerradas en período) |
| Ingresos POS | `sales` (en período) |
| Habitaciones activas | `rooms` (isActive = true) |
| Reservas para ocupación | `bookings` (checked-in/out que intersectan período) |
| Cuentas abiertas | `guestAccounts` (status = open) |

## UI/UX

- Pull-to-refresh
- Loading skeleton mientras calculan los KPIs
- Números formateados con separador de miles y símbolo de moneda
- Porcentajes con 1 decimal
- Barras de ingresos por fuente: proporcionales al máximo
- Lista de cuentas abiertas: ordenada por saldo descendente
- Colores: verde para métricas positivas, naranja/rojo para "por cobrar" alto

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton de tarjetas KPI |
| Success | KPIs calculados |
| Error | "No se pudieron calcular los reportes" + reintentar |
| Sin datos | "No hay datos para el período seleccionado" |
| Offline | Banner + datos del caché (pueden estar desactualizados) |

## Permisos

- Roles: `manager`, `admin`, `superadmin`
- `receptionist` y `housekeeper` NO tienen acceso a esta pantalla

## Criterios de aceptación

- [ ] KPIs se calculan correctamente para el período seleccionado
- [ ] Período por defecto es el mes actual
- [ ] Cambiar período recalcula todos los KPIs
- [ ] "Por cobrar" siempre muestra valor actual (no filtrado por período)
- [ ] Ingresos por fuente muestran barras proporcionales
- [ ] Lista de cuentas abiertas ordenada por saldo
- [ ] Tap en cuenta abierta navega a GuestAccountScreen
- [ ] Pull-to-refresh recalcula los datos
- [ ] Skeleton visible durante carga
- [ ] Receptionist y housekeeper no pueden acceder a esta pantalla

## Consideraciones técnicas

- Los cálculos son costosos (múltiples queries + procesamiento en cliente). Usar `FutureProvider.family` con el período como parámetro para cachear por período.
- Invalidar el caché al hacer pull-to-refresh
- No usar librerías de gráficos complejas para el MVP — barras simples con widgets Flutter nativos
- El cálculo de noches que intersectan un período es el mismo algoritmo que `FinancialReportsService.calculateNights()` del sistema web

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `KPICard`, `GlassCard`, `SkeletonLoader`
**Referencias**: `docs/design-references/dashboard.jpg`, `docs/design-references/general.jpg`

### Elementos REQUIRED
- Selector de período: chips horizontales (Hoy / Semana / Mes / Año), chip activo con `accentPrimary`
- KPI principal (ingresos): `displayLarge` (36px), prominente, en `GlassCard`
- Grid 2×2 de KPIs secundarios: `KPICard` con número + label
- Barras de ingresos por fuente: implementación nativa Flutter (sin librerías de gráficos)
- Lista de cuentas abiertas: `GlassCard` por cuenta, ordenadas por saldo DESC
- Números formateados: separador de miles + símbolo de moneda
- Skeleton: tarjetas KPI durante carga

### Elementos FLEXIBLE
- Estilo exacto de las barras de ingresos por fuente
- Colores de las barras (pueden usar los colores de acento)
- Animación al cambiar de período
