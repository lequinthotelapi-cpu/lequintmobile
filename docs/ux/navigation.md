# ARQUITECTURA DE INFORMACIÓN Y NAVEGACIÓN — Le Quint Mobile App

**Decisiones base**: DECISION-008, DECISION-009, DECISION-010, DECISION-011

---

## 1. ESTRUCTURA DE NAVEGACIÓN GENERAL

```
App
├── Auth (público)
│   └── LoginScreen
│
└── Shell (autenticado)
    ├── BottomNavBar  ← varía por rol
    └── Screens según rol
```

---

## 2. BOTTOM NAV POR ROL

### Superadmin / Admin
```
[Dashboard] [Habitaciones] [Recepción] [Housekeeping] [Más]
```

### Manager
```
[Dashboard] [Habitaciones] [Reportes] [Housekeeping] [Más]
```

### Receptionist
```
[Inicio] [Llegadas] [Salidas] [Habitaciones] [Más]
```

### Housekeeper
```
[Mis Tareas] [Habitaciones] [Notificaciones] [Perfil]
```

El ítem **[Más]** abre un menú secundario (bottom sheet o drawer) con el resto de secciones accesibles para ese rol.

---

## 3. MAPA DE PANTALLAS COMPLETO

### AUTH
```
LoginScreen
  └── (éxito) → HomeScreen según rol
```

---

### SUPERADMIN / ADMIN — Pantallas

```
DashboardScreen (home)
  ├── KPIs operacionales: llegadas hoy, salidas hoy, ocupación, habitaciones por estado
  ├── KPIs financieros: ingresos del período, RevPAR, ADR, por cobrar
  ├── Accesos rápidos: → Llegadas, → Salidas, → Habitaciones, → Tareas
  └── Selector de período (hoy / semana / mes)

RoomsScreen
  ├── Lista/grid de habitaciones con estado visual
  ├── Filtro por estado
  └── RoomDetailScreen
        └── Info: número, tipo, piso, estado, precio, huésped actual

FrontDeskScreen (tab)
  ├── Tab: Llegadas → ArrivalsScreen
  ├── Tab: Salidas → DeparturesScreen
  └── Tab: En Casa → InHouseScreen

HousekeepingScreen
  ├── Resumen: pendientes, en progreso, completadas hoy, vencidas
  ├── Lista de todas las tareas (filtro por estado/empleado)
  └── TaskDetailScreen
        ├── Info de la tarea
        └── Acciones: asignar, cancelar

NotificationsScreen
ProfileScreen
```

---

### MANAGER — Pantallas

```
DashboardScreen (home)
  ├── KPIs operacionales: llegadas hoy, salidas hoy, ocupación
  ├── KPIs financieros: ingresos, RevPAR, ADR, por cobrar
  ├── Estado de habitaciones (resumen por estado)
  └── Selector de período

RoomsScreen
  ├── Lista/grid de habitaciones
  └── RoomDetailScreen

ReportsScreen
  ├── Ingresos del período (gráfico de barras simple)
  ├── Ocupación
  ├── RevPAR / ADR
  ├── Por cobrar (lista de cuentas abiertas)
  └── Selector de período

HousekeepingScreen
  ├── Resumen del día
  ├── Lista de tareas por empleado
  └── TaskDetailScreen

NotificationsScreen
ProfileScreen
```

---

### RECEPTIONIST — Pantallas

```
HomeScreen (home)
  ├── Llegadas hoy (contador + acceso rápido)
  ├── Salidas hoy (contador + acceso rápido)
  ├── Habitaciones por estado (resumen visual)
  └── Cuentas abiertas (contador)

ArrivalsScreen
  ├── Lista de llegadas del día (reservas confirmed/pending con check-in hoy)
  ├── Búsqueda por nombre o número de habitación
  └── ArrivalDetailScreen
        ├── Datos del huésped
        ├── Datos de la reserva (habitación, fechas, noches, total)
        ├── Solicitudes especiales
        └── Botón "Realizar Check-In"
              └── ConfirmCheckInScreen
                    ├── Resumen de la operación
                    ├── Botón "Confirmar Check-In"
                    └── (éxito) → feedback + volver a lista

DeparturesScreen
  ├── Lista de salidas del día (reservas checked-in con check-out hoy)
  └── DepartureDetailScreen
        ├── Datos del huésped
        ├── Datos de la reserva
        ├── Saldo de cuenta (balance)
        ├── Advertencia si balance > 0
        └── Botón "Realizar Check-Out"
              └── ConfirmCheckOutScreen
                    ├── Resumen de la operación
                    ├── Advertencia si hay saldo pendiente
                    ├── Botón "Confirmar Check-Out"
                    └── (éxito) → feedback + volver a lista

RoomsScreen
  ├── Lista/grid de habitaciones con estado
  ├── Filtro por estado
  └── RoomDetailScreen
        ├── Info de la habitación
        └── Si ocupada: acceso rápido a cuenta del huésped

InHouseScreen
  ├── Lista de huéspedes en casa (checked-in)
  └── GuestAccountScreen (consulta)
        ├── Cargos
        ├── Pagos
        ├── Saldo
        └── Botón "Agregar Cargo"
              └── AddChargeScreen
                    ├── Tipo de cargo
                    ├── Descripción
                    ├── Monto
                    └── Confirmar

NotificationsScreen
ProfileScreen
```

---

### HOUSEKEEPER — Pantallas

```
MyTasksScreen (home)
  ├── Resumen: pendientes, en progreso, completadas hoy
  ├── Lista de mis tareas (ordenadas por prioridad)
  │   ├── Chip de prioridad (urgente, alta, normal, baja)
  │   ├── Número de habitación y piso
  │   ├── Tipo de tarea
  │   └── Estado actual
  └── TaskDetailScreen
        ├── Info completa de la tarea
        ├── Habitación: número, piso, tipo
        ├── Prioridad y tipo
        ├── Notas del supervisor
        ├── Botón "Iniciar Tarea" (si pending)
        └── Botón "Completar Tarea" (si in-progress)
              └── CompleteTaskScreen
                    ├── Duración real (minutos) — requerido
                    ├── Notas de completación — opcional
                    ├── ¿Requiere mantenimiento? — checkbox
                    ├── Notas de mantenimiento — visible si checkbox activo
                    └── Botón "Confirmar Completación"

RoomsScreen (todas las habitaciones — DECISION-016)
  ├── Todas las habitaciones del hotel con estado visual
  └── Filtro por estado

NotificationsScreen
ProfileScreen
```

---

## 4. FLUJOS CRÍTICOS DETALLADOS

### Flujo Check-In
```
ArrivalsScreen
  → tap en reserva
  → ArrivalDetailScreen
      (muestra: nombre huésped, habitación, fechas, noches, total, solicitudes especiales)
  → tap "Realizar Check-In"
  → ConfirmCheckInScreen / modal
      (muestra resumen, botón "Confirmar")
  → loading
  → éxito: snackbar "Check-in realizado" + pop a ArrivalsScreen
  → error: mensaje de error específico (ej: "La reserva no está confirmada")
```

### Flujo Check-Out
```
DeparturesScreen
  → tap en reserva
  → DepartureDetailScreen
      (muestra: nombre huésped, habitación, saldo de cuenta)
  → si balance > 0: advertencia visible "Saldo pendiente: $XXX"
  → tap "Realizar Check-Out"
  → si balance > 0: bloquear acción con mensaje explicativo
  → si balance = 0: ConfirmCheckOutScreen / modal
  → loading
  → éxito: snackbar "Check-out realizado" + pop a DeparturesScreen
  → error: mensaje específico
```

### Flujo Completar Tarea (Housekeeper)
```
MyTasksScreen
  → tap en tarea
  → TaskDetailScreen
  → tap "Iniciar Tarea" (si pending)
      → loading → tarea pasa a in-progress → actualiza UI
  → tap "Completar Tarea" (si in-progress)
  → CompleteTaskScreen
      → ingresar duración (minutos)
      → notas opcionales
      → toggle "¿Requiere mantenimiento?"
          → si sí: campo de notas de mantenimiento
      → tap "Confirmar Completación"
      → loading
      → éxito: snackbar + pop a MyTasksScreen
      → error: mensaje específico
```

---

## 5. ESTADOS DE PANTALLA (todos los screens)

Cada pantalla debe manejar:

| Estado | Descripción |
|---|---|
| **Loading** | Skeleton o spinner mientras carga datos |
| **Success** | Contenido normal |
| **Empty** | Mensaje contextual (ej: "No hay llegadas para hoy") |
| **Error** | Mensaje de error + botón reintentar |
| **Offline** | Banner informativo + datos en caché si disponibles |

---

## 6. COMPORTAMIENTO OFFLINE

Gracias al caché de Firestore (DECISION-006):

- **Lecturas**: Funcionan offline con datos en caché (pueden estar desactualizados)
- **Escrituras**: Se encolan y sincronizan automáticamente al recuperar conexión
- **Indicador**: Banner persistente cuando no hay conexión
- **Acciones críticas** (check-in, check-out, completar tarea): Permitidas offline, se sincronizan al reconectar

---

## 7. NOTIFICACIONES PUSH — Comportamiento

| Tipo | Destinatario | Acción al tap |
|---|---|---|
| Nueva tarea asignada | Housekeeper | Abre TaskDetailScreen |
| Check-in pendiente | Receptionist | Abre ArrivalDetailScreen |
| Check-out pendiente | Receptionist | Abre DepartureDetailScreen |
| Nueva reserva | Receptionist | Abre lista de reservas |
| Pago recibido | Manager | Abre cuenta del huésped |
| Stock bajo | Admin | (fuera de MVP móvil) |

---

## 8. COLORES DE ESTADO DE HABITACIONES

Consistentes con el sistema web:

| Estado | Color |
|---|---|
| available | Verde #10b981 |
| reserved | Morado #8b5cf6 |
| occupied | Rojo #ef4444 |
| dirty | Naranja #f59e0b |
| cleaning | Azul #3b82f6 |
| maintenance | Índigo #6366f1 |

---

## 9. COLORES DE PRIORIDAD DE TAREAS

| Prioridad | Color |
|---|---|
| urgent | Rojo #ef4444 |
| high | Naranja #f59e0b |
| normal | Azul #3b82f6 |
| low | Verde #10b981 |
