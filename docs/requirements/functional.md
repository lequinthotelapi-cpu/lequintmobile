# INVENTARIO DE FUNCIONALIDADES — Le Quint Mobile App

**Basado en**: Análisis del sistema web + personas definidas

---

## Clasificaciones

- **MOBILE_REQUIRED**: Debe estar en el MVP. Sin esto la app no tiene valor.
- **MOBILE_RECOMMENDED**: Agrega valor significativo. Incluir si el alcance lo permite.
- **MOBILE_OPTIONAL**: Útil pero no crítico para el MVP.
- **WEB_ONLY**: No tiene sentido en móvil o es demasiado complejo para el MVP.
- **FUTURE**: Para releases posteriores.
- **UNKNOWN**: Requiere más información para clasificar.

---

## F-001 — Dashboard Operacional del Día

| Campo | Valor |
|---|---|
| Módulo | Dashboard |
| Descripción | Vista resumen del estado operacional: llegadas hoy, salidas hoy, habitaciones por estado, cuentas abiertas |
| Usuarios | Receptionist, Manager, Superadmin |
| Frecuencia | Varias veces al día (inicio de turno, consultas rápidas) |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | Firestore directo — datos disponibles |
| Candidato móvil | SÍ |
| Razón | Primera pantalla al abrir la app. Responde "¿cómo está el hotel ahora?" |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-002 — Dashboard Financiero / KPIs

| Campo | Valor |
|---|---|
| Módulo | Reports |
| Descripción | KPIs financieros: ingresos del período, ocupación, RevPAR, ADR, por cobrar, efectivo en caja |
| Usuarios | Manager, Superadmin |
| Frecuencia | Diaria (gerente/propietario) |
| Importancia operacional | ALTA |
| Disponibilidad API | Firestore directo — cálculos en cliente |
| Candidato móvil | SÍ |
| Razón | Gerente y propietario necesitan visibilidad financiera desde cualquier lugar |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-003 — Ver Llegadas del Día

| Campo | Valor |
|---|---|
| Módulo | Front Desk |
| Descripción | Lista de reservas con check-in programado para hoy. Estado: confirmed, pending. |
| Usuarios | Receptionist, Manager |
| Frecuencia | Varias veces al día |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `bookings` collection — `getArrivalsForDate()` |
| Candidato móvil | SÍ |
| Razón | El recepcionista necesita saber quién llega hoy sin ir al escritorio |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-004 — Ejecutar Check-In

| Campo | Valor |
|---|---|
| Módulo | Front Desk |
| Descripción | Confirmar llegada de huésped. Cambia reserva a `checked-in`, habitación a `occupied`, crea Guest Account. |
| Usuarios | Receptionist |
| Frecuencia | Varias veces al día |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `BookingService.checkIn()` — disponible |
| Candidato móvil | SÍ |
| Razón | Operación core de recepción. Puede ocurrir lejos del escritorio. |
| Dependencias | F-003 (ver llegadas), reserva debe estar `confirmed` |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-005 — Ver Salidas del Día

| Campo | Valor |
|---|---|
| Módulo | Front Desk |
| Descripción | Lista de reservas con check-out programado para hoy. Estado: checked-in. |
| Usuarios | Receptionist, Manager |
| Frecuencia | Varias veces al día |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `bookings` collection — `getDeparturesForDate()` |
| Candidato móvil | SÍ |
| Razón | El recepcionista necesita saber quién sale hoy |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-006 — Ejecutar Check-Out

| Campo | Valor |
|---|---|
| Módulo | Front Desk |
| Descripción | Registrar salida de huésped. Cambia reserva a `checked-out`, habitación a `dirty`. Requiere balance = 0. |
| Usuarios | Receptionist |
| Frecuencia | Varias veces al día |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `BookingService.checkOut()` — disponible |
| Candidato móvil | SÍ |
| Razón | Operación core de recepción. |
| Dependencias | F-005 (ver salidas), balance de cuenta debe ser 0 |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-007 — Ver Estado de Habitaciones

| Campo | Valor |
|---|---|
| Módulo | Rooms |
| Descripción | Vista de todas las habitaciones con su estado actual: available, reserved, occupied, dirty, cleaning, maintenance. |
| Usuarios | Receptionist, Manager, Housekeeper |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Disponibilidad API | `rooms` + `bookings` collections — `RoomStatusService` |
| Candidato móvil | SÍ — como lista/grid, NO como mapa SVG |
| Razón | Consulta frecuente para todos los roles. El mapa SVG no es viable en móvil. |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-008 — Ver Mis Tareas de Housekeeping

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Lista de tareas asignadas al usuario actual. Filtradas por estado (pendiente, en progreso). |
| Usuarios | Housekeeper |
| Frecuencia | Continua durante el turno |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `housekeepingTasks` — `getByEmployee(userId)` |
| Candidato móvil | SÍ — es el caso de uso más claro de toda la app |
| Razón | El housekeeper se desplaza físicamente. Sin móvil debe ir a un escritorio para ver sus tareas. |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-009 — Completar Tarea de Housekeeping

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Marcar tarea como completada. Registrar duración real, notas, si requiere mantenimiento. Cambia habitación a `available` o `maintenance`. |
| Usuarios | Housekeeper |
| Frecuencia | Varias veces al día |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | `HousekeepingService.completeTask()` — disponible |
| Candidato móvil | SÍ — la acción ocurre físicamente en la habitación |
| Razón | Sin móvil el housekeeper no puede reportar completación en tiempo real. |
| Dependencias | F-008 (ver mis tareas), tarea debe estar `in-progress` |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-010 — Iniciar Tarea de Housekeeping

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Marcar tarea como iniciada (`in-progress`). Registra `startedAt`. |
| Usuarios | Housekeeper |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Disponibilidad API | `HousekeepingService.startTask()` — disponible |
| Candidato móvil | SÍ |
| Razón | Parte del flujo de F-009. |
| Dependencias | F-008, tarea debe estar `pending` y asignada |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-011 — Notificaciones Push

| Campo | Valor |
|---|---|
| Módulo | Notifications |
| Descripción | Recibir notificaciones push en el dispositivo. Tipos: check-in, check-out, housekeeping, booking, payment, inventory, system. |
| Usuarios | Todos |
| Frecuencia | Continua |
| Importancia operacional | MUY ALTA |
| Disponibilidad API | FCM existente — requiere adaptación para Flutter |
| Candidato móvil | SÍ — las notificaciones push son más efectivas en móvil que en web |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-012 — Ver Notificaciones

| Campo | Valor |
|---|---|
| Módulo | Notifications |
| Descripción | Lista de notificaciones del usuario. Marcar como leída. |
| Usuarios | Todos |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Disponibilidad API | `notifications` collection — disponible |
| Candidato móvil | SÍ |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-013 — Consultar Cuenta de Huésped

| Campo | Valor |
|---|---|
| Módulo | Guest Accounts |
| Descripción | Ver detalle de cuenta: cargos, pagos, saldo pendiente, estado. Solo lectura. |
| Usuarios | Receptionist, Manager |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Disponibilidad API | `guestAccounts` collection — disponible |
| Candidato móvil | SÍ — consulta rápida de saldo |
| **Clasificación** | **MOBILE_RECOMMENDED** |
| Prioridad | Should Have |

---

## F-014 — Agregar Cargo a Habitación

| Campo | Valor |
|---|---|
| Módulo | Guest Accounts / POS |
| Descripción | Registrar cargo simple a cuenta de huésped (minibar, servicio, etc.). |
| Usuarios | Receptionist |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Disponibilidad API | `GuestAccountService.addCharge()` — disponible |
| Candidato móvil | SÍ — cargo rápido sin abrir POS completo |
| Nota | Versión simplificada del POS. Solo cargo a habitación, sin venta directa. |
| **Clasificación** | **MOBILE_RECOMMENDED** |
| Prioridad | Should Have |

---

## F-015 — Supervisar Tareas de Housekeeping (Vista Manager)

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Ver todas las tareas del día, estado por empleado, tareas urgentes/vencidas. |
| Usuarios | Manager, Admin |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Disponibilidad API | `housekeepingTasks` collection — disponible |
| Candidato móvil | SÍ |
| **Clasificación** | **MOBILE_RECOMMENDED** |
| Prioridad | Should Have |

---

## F-016 — Huéspedes en Casa

| Campo | Valor |
|---|---|
| Módulo | Front Desk |
| Descripción | Lista de huéspedes actualmente en el hotel (reservas `checked-in`). |
| Usuarios | Receptionist, Manager |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Disponibilidad API | `bookings` — `getBookingsByStatus('checked-in')` |
| Candidato móvil | SÍ |
| **Clasificación** | **MOBILE_RECOMMENDED** |
| Prioridad | Should Have |

---

## F-017 — Buscar Huésped

| Campo | Valor |
|---|---|
| Módulo | Guests |
| Descripción | Buscar huésped por nombre, documento o número de habitación. Ver información básica. |
| Usuarios | Receptionist |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Disponibilidad API | `guests` collection — disponible |
| Candidato móvil | SÍ — búsqueda rápida |
| **Clasificación** | **MOBILE_RECOMMENDED** |
| Prioridad | Should Have |

---

## F-018 — Perfil de Usuario y Cerrar Sesión

| Campo | Valor |
|---|---|
| Módulo | Profile / Auth |
| Descripción | Ver datos del usuario actual. Cerrar sesión. |
| Usuarios | Todos |
| Frecuencia | Ocasional |
| Importancia operacional | MEDIA |
| Disponibilidad API | Firebase Auth + `users` collection |
| Candidato móvil | SÍ |
| **Clasificación** | **MOBILE_REQUIRED** |
| Prioridad | Must Have |

---

## F-019 — Crear Reserva

| Campo | Valor |
|---|---|
| Módulo | Bookings |
| Descripción | Crear nueva reserva: seleccionar huésped, habitación, fechas, ocupantes. |
| Usuarios | Receptionist, Admin |
| Frecuencia | Varias veces al día |
| Importancia operacional | ALTA |
| Candidato móvil | PARCIAL — formulario complejo, mejor en escritorio |
| Razón exclusión MVP | Alta complejidad de formulario en pantalla pequeña. Búsqueda de disponibilidad requiere múltiples pasos. |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-020 — Ver Lista de Reservas

| Campo | Valor |
|---|---|
| Módulo | Bookings |
| Descripción | Lista de reservas con filtros por estado. |
| Usuarios | Receptionist, Manager |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Candidato móvil | SÍ — consulta |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-021 — Confirmar / Cancelar Reserva

| Campo | Valor |
|---|---|
| Módulo | Bookings |
| Descripción | Cambiar estado de reserva: pending → confirmed, o cancelar. |
| Usuarios | Receptionist, Admin |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Candidato móvil | SÍ — acción simple |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-022 — Asignar Tarea de Housekeeping

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Asignar tarea existente a un housekeeper. |
| Usuarios | Manager, Admin |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Candidato móvil | SÍ |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-023 — Crear Tarea de Housekeeping

| Campo | Valor |
|---|---|
| Módulo | Housekeeping |
| Descripción | Crear nueva tarea de limpieza o mantenimiento. |
| Usuarios | Manager, Admin |
| Frecuencia | Varias veces al día |
| Importancia operacional | MEDIA |
| Candidato móvil | SÍ — formulario simple |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-024 — POS Completo

| Campo | Valor |
|---|---|
| Módulo | POS |
| Descripción | Punto de venta completo: catálogo de productos, carrito, venta directa con caja. |
| Usuarios | Receptionist |
| Candidato móvil | NO para MVP |
| Razón | Requiere caja abierta. Flujo complejo. Mejor en escritorio. La versión móvil útil es solo "cargar a habitación" (F-014). |
| **Clasificación** | **WEB_ONLY** |
| Prioridad | Won't Have (MVP) |

---

## F-025 — Caja Registradora

| Campo | Valor |
|---|---|
| Módulo | Cash Register |
| Descripción | Abrir/cerrar caja, registrar transacciones. |
| Usuarios | Receptionist, Admin |
| Candidato móvil | NO |
| Razón | Operación de escritorio. Requiere impresora, manejo de efectivo físico. |
| **Clasificación** | **WEB_ONLY** |
| Prioridad | Won't Have |

---

## F-026 — Facturación y PDF

| Campo | Valor |
|---|---|
| Módulo | Invoices |
| Descripción | Generar facturas, imprimir PDF, tickets térmicos. |
| Usuarios | Receptionist, Admin |
| Candidato móvil | NO para MVP |
| Razón | Generación de PDF e impresión es operación de escritorio. |
| **Clasificación** | **WEB_ONLY** |
| Prioridad | Won't Have (MVP) |

---

## F-027 — Gestión de Productos e Inventario

| Campo | Valor |
|---|---|
| Módulo | Products / Inventory |
| Descripción | CRUD de productos, movimientos de inventario, gastos. |
| Usuarios | Admin |
| Candidato móvil | NO para MVP |
| Razón | Administración. Mejor en escritorio. |
| **Clasificación** | **WEB_ONLY** |
| Prioridad | Won't Have (MVP) |

---

## F-028 — Gestión de Usuarios, Parámetros, Permisos

| Campo | Valor |
|---|---|
| Módulo | Users / Parameters / Permissions |
| Descripción | Administración del sistema. |
| Usuarios | Admin, Superadmin |
| Candidato móvil | NO |
| Razón | Administración pura. Sin valor en móvil. |
| **Clasificación** | **WEB_ONLY** |
| Prioridad | Won't Have |

---

## F-029 — Calendario de Reservas

| Campo | Valor |
|---|---|
| Módulo | Calendar |
| Descripción | Vista de calendario con reservas. |
| Usuarios | Receptionist, Manager |
| Candidato móvil | NO para MVP |
| Razón | Pantalla pequeña limita utilidad del calendario. |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Won't Have (MVP) |

---

## F-030 — Agregar Pago a Cuenta de Huésped

| Campo | Valor |
|---|---|
| Módulo | Guest Accounts |
| Descripción | Registrar pago en cuenta de huésped. |
| Usuarios | Receptionist |
| Candidato móvil | PARCIAL |
| Razón | Operación financiera sensible. Mejor en escritorio para MVP. |
| **Clasificación** | **MOBILE_OPTIONAL** |
| Prioridad | Could Have |

---

## F-031 — Funcionalidades para Huéspedes

| Campo | Valor |
|---|---|
| Descripción | Acceso del huésped, reservas online, información de estadía, solicitudes, comunicación. |
| **Clasificación** | **FUTURE** |
| Prioridad | Won't Have (MVP) — Release futuro |

---

## RESUMEN POR CLASIFICACIÓN

### MOBILE_REQUIRED (Must Have)
- F-001 Dashboard Operacional
- F-002 Dashboard Financiero / KPIs
- F-003 Ver Llegadas del Día
- F-004 Ejecutar Check-In
- F-005 Ver Salidas del Día
- F-006 Ejecutar Check-Out
- F-007 Ver Estado de Habitaciones
- F-008 Ver Mis Tareas (Housekeeper)
- F-009 Completar Tarea
- F-010 Iniciar Tarea
- F-011 Notificaciones Push
- F-012 Ver Notificaciones
- F-018 Perfil y Cerrar Sesión

### MOBILE_RECOMMENDED (Should Have)
- F-013 Consultar Cuenta de Huésped
- F-014 Agregar Cargo a Habitación
- F-015 Supervisar Tareas (Manager)
- F-016 Huéspedes en Casa
- F-017 Buscar Huésped

### MOBILE_OPTIONAL (Could Have)
- F-019 Crear Reserva
- F-020 Ver Lista de Reservas
- F-021 Confirmar/Cancelar Reserva
- F-022 Asignar Tarea
- F-023 Crear Tarea
- F-029 Calendario
- F-030 Agregar Pago

### WEB_ONLY (Won't Have)
- F-024 POS Completo
- F-025 Caja Registradora
- F-026 Facturación y PDF
- F-027 Gestión de Productos/Inventario
- F-028 Administración del Sistema

### FUTURE
- F-031 Funcionalidades para Huéspedes
