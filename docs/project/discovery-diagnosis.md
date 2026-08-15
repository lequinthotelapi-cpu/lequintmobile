# DIAGNÓSTICO DEL SISTEMA WEB — Le Quint Hotel

> Análisis del sistema web existente realizado durante la fase de descubrimiento.
> Este documento es de referencia. Las decisiones derivadas están en `decisions.md`.

---

## Stack tecnológico del sistema web

| Componente | Tecnología |
|---|---|
| Framework | Angular 16+ |
| Template UI | Fury Material Design Admin |
| Backend | Firebase (Auth + Firestore) |
| Funciones serverless | Firebase Cloud Functions |
| Notificaciones push | Firebase Cloud Messaging (FCM) |
| Hosting | Vercel + Firebase Hosting |
| PDF | jsPDF + jsPDF-AutoTable |
| Alertas | SweetAlert2 + Angular Material SnackBar |
| Idioma UI | Español |

---

## Arquitectura del sistema web

Arquitectura en capas con patrón Repository:

```
Componentes (UI)
    ↓
Servicios (Core Services)
    ↓
Repositorios (Domain Repositories — interfaces)
    ↓
Repositorios Firebase (Infrastructure — implementaciones)
    ↓
Firebase Firestore
```

La app móvil Flutter replica este mismo patrón en Dart.

---

## Roles existentes

| Rol | Jerarquía | Acceso en sistema web |
|---|---|---|
| superadmin | 6 | Todo (`*`) — mapea a Propietario en móvil |
| admin | 5 | Casi todo |
| manager | 4 | Dashboard, Reportes, Reservas, Habitaciones, Cuentas, Facturas, Caja, Movimientos, Empleados |
| receptionist | 3 | Dashboard, Recepción, Habitaciones, Reservas, Calendario, Huéspedes, Cuentas, POS, Facturas |
| housekeeper | 2 | Dashboard, Housekeeping, Habitaciones |
| guest | 1 | Sin rutas — rol futuro |

---

## Colecciones Firestore utilizadas por la app móvil

| Colección | Uso en móvil |
|---|---|
| `users` | Auth, datos de usuario, sesiones, fcmToken |
| `rooms` | Estado de habitaciones en tiempo real |
| `bookings` | Llegadas, salidas, check-in, check-out |
| `guestAccounts` | Cuentas de huéspedes, cargos, pagos, saldo |
| `housekeepingTasks` | Tareas de limpieza y mantenimiento |
| `notifications` | Notificaciones por usuario |
| `products` | Catálogo para agregar cargos a habitaciones |
| `sales` | Ingresos POS para cálculos financieros |

---

## Reglas de negocio críticas

1. **Check-in**: Solo reservas `confirmed`. Crea Guest Account automáticamente. Habitación → `occupied`.
2. **Check-out**: Solo reservas `checked-in`. Requiere balance = 0. Habitación → `dirty`.
3. **Estado `reserved`**: Calculado dinámicamente. Habitación `available` con check-in HOY → muestra `reserved`. No se guarda en BD.
4. **Housekeeping**: Crear tarea → habitación a `cleaning` o `maintenance`. Completar tarea → habitación a `available` (o `maintenance` si se reportó problema).
5. **Sesiones**: Límite por usuario (`maxSessions`). Heartbeat cada 5 min. Sesiones inactivas >15 min se limpian en el próximo login.
6. **Cargo a habitación**: No requiere caja abierta. Solo requiere cuenta de huésped abierta.

---

## Limitaciones del sistema web no aplicables a móvil

| Limitación web | Solución en móvil |
|---|---|
| Mapa SVG interactivo | Vista lista/grid con colores de estado (DECISION-019) |
| SweetAlert2 | Dialogs nativos de Flutter |
| Angular Material | Widgets nativos de Flutter |
| PDF con jsPDF | Fuera del MVP móvil |
| `setInterval` para heartbeat | `AppLifecycleObserver` + Timer |
| `window.addEventListener('beforeunload')` | `AppLifecycleState.detached` |

---

## Módulos del sistema web y su estado en móvil

| Módulo | Estado en móvil |
|---|---|
| Dashboard | MOBILE_REQUIRED — diferenciado por rol |
| Front Desk (check-in/out) | MOBILE_REQUIRED |
| Habitaciones | MOBILE_REQUIRED — lista/grid |
| Housekeeping | MOBILE_REQUIRED — vista housekeeper + manager |
| Notificaciones | MOBILE_REQUIRED — push nativo |
| Reportes financieros | MOBILE_REQUIRED — para manager/superadmin |
| Cuentas de huéspedes | MOBILE_RECOMMENDED — consulta + agregar cargo |
| Reservas (consulta) | MOBILE_OPTIONAL — Could Have |
| Perfil | MOBILE_REQUIRED — cerrar sesión |
| POS completo | WEB_ONLY — fuera del MVP |
| Caja registradora | WEB_ONLY |
| Facturación/PDF | WEB_ONLY |
| Gestión de usuarios | WEB_ONLY |
| Parámetros | WEB_ONLY |
| Permisos | WEB_ONLY |
| Empleados | WEB_ONLY |
| Inventario/Productos (gestión) | WEB_ONLY |
| Calendario | WEB_ONLY — MVP |
| Huéspedes (CRUD) | WEB_ONLY — MVP |
