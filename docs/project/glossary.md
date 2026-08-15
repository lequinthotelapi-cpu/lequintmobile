# GLOSARIO — Le Quint Mobile App

---

## Términos del dominio

| Término | Definición |
|---|---|
| **Check-in** | Registro de llegada de un huésped. Cambia la reserva a `checked-in`, la habitación a `occupied`, y crea una Guest Account con cargo de alojamiento. |
| **Check-out** | Registro de salida de un huésped. Cambia la reserva a `checked-out` y la habitación a `dirty`. Requiere balance = 0. |
| **Guest Account** | Folio de la estadía del huésped. Acumula cargos (alojamiento, consumos, servicios) y pagos. |
| **Balance** | Saldo pendiente de pago en una Guest Account. `balance = total - paid`. |
| **Housekeeper** | Personal de limpieza y mantenimiento del hotel. Rol en el sistema: `housekeeper`. |
| **Tarea** | Unidad de trabajo asignada a un housekeeper. Tipos: cleaning, deep-cleaning, maintenance, inspection. |
| **Estado de habitación** | Estado físico/operacional: available, reserved (calculado), occupied, dirty, cleaning, maintenance, blocked. |
| **Estado `reserved`** | Estado visual calculado. Una habitación `available` con check-in programado para HOY muestra `reserved`. No se guarda en base de datos. |
| **RevPAR** | Revenue Per Available Room. `RevPAR = ingresos totales / (habitaciones activas × días del período)`. |
| **ADR** | Average Daily Rate. Tarifa promedio diaria. `ADR = ingresos totales / noches vendidas`. |
| **Ocupación** | `ocupación = (noches vendidas / noches disponibles) × 100`. |
| **FCM** | Firebase Cloud Messaging. Sistema de notificaciones push. |
| **Heartbeat** | Señal periódica (cada 5 min) que la app envía a Firestore para indicar que la sesión está activa. En móvil solo se envía cuando la app está en foreground. |
| **Sesión** | Instancia de login activa. Un usuario puede tener múltiples sesiones hasta el límite `maxSessions`. Superadmin no tiene límite. |
| **WriteBatch** | Operación atómica de Firestore que ejecuta múltiples escrituras como una sola transacción. Usado en check-in, check-out, completar tarea y agregar cargo. |

---

## Roles del sistema

| Rol | Nombre en UI | Perfil de negocio |
|---|---|---|
| `superadmin` | Super Administrador | Propietario del hotel. Acceso total. |
| `admin` | Administrador | Acceso a casi todos los módulos. |
| `manager` | Gerente | Supervisión operacional y financiera. |
| `receptionist` | Recepcionista | Operaciones de recepción. |
| `housekeeper` | Camarera / Personal de limpieza | Gestión de tareas de limpieza. |
| `guest` | Huésped | Sin acceso en MVP. Release futuro. |

---

## Términos técnicos

| Término | Definición |
|---|---|
| **Firestore** | Base de datos NoSQL en tiempo real de Firebase. Backend principal del sistema. |
| **FlutterFire** | Conjunto de plugins oficiales de Firebase para Flutter. |
| **Riverpod** | Librería de state management para Flutter. Usa `StreamProvider`, `FutureProvider`, `StateProvider`. |
| **GoRouter** | Librería de navegación declarativa para Flutter. Soporta deep linking. |
| **Provider (Riverpod)** | Unidad de estado reactivo en Riverpod. |
| **Deep link** | URL que abre una pantalla específica de la app. Usado en notificaciones push. |
| **AppLifecycleObserver** | Mecanismo Flutter para detectar cuando la app va a background/foreground. Usado para el heartbeat. |
| **Offline persistence** | Capacidad de Firestore de servir datos desde caché local cuando no hay conexión. |

---

## Colores de estado de habitaciones

| Estado | Color hex |
|---|---|
| available | #10b981 (verde) |
| reserved | #8b5cf6 (morado) |
| occupied | #ef4444 (rojo) |
| dirty | #f59e0b (naranja) |
| cleaning | #3b82f6 (azul) |
| maintenance | #6366f1 (índigo) |

---

## Colores de prioridad de tareas

| Prioridad | Color hex |
|---|---|
| urgent | #ef4444 (rojo) |
| high | #f59e0b (naranja) |
| normal | #3b82f6 (azul) |
| low | #10b981 (verde) |
