# SPEC-009 — Notificaciones Push

**ID**: SPEC-009
**Nombre**: Notificaciones push y centro de notificaciones
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Todos los roles

---

## Objetivo

Recibir notificaciones push en el dispositivo móvil y gestionar el centro de notificaciones (ver, marcar como leída).

## Contexto

FCM ya está configurado en el sistema web. La app móvil reutiliza la misma infraestructura. Las notificaciones push son más efectivas en móvil que en web (DECISION-007).

## Actores

- Todos los roles autenticados

## Precondiciones

- Usuario autenticado
- Permisos de notificaciones concedidos por el usuario (iOS requiere permiso explícito)
- Token FCM registrado en `users/{uid}.fcmToken`

---

## Flujo — Configuración inicial

1. Al hacer login exitoso, la app solicita permisos de notificaciones
2. iOS: dialog del sistema "¿Permitir notificaciones?"
3. Android: automático (Android 13+ requiere permiso)
4. Si el usuario concede permiso:
   a. Obtener token FCM del dispositivo
   b. Guardar en `users/{uid}.fcmToken`
5. Si el usuario deniega: la app funciona sin notificaciones push (sin bloquear el flujo)
6. Cuando el token se renueva: actualizar en Firestore automáticamente

---

## Comportamiento por estado de la app

### App en foreground
- Mostrar notificación in-app: banner en la parte superior de la pantalla
- Banner muestra: título + mensaje
- Tap en banner: navegar a la pantalla correspondiente
- Banner desaparece automáticamente después de 4 segundos

### App en background o cerrada
- El sistema operativo muestra la notificación push nativa
- Tap en notificación: abrir la app y navegar a la pantalla correspondiente (deep link)

---

## Deep links por tipo de notificación

| Tipo | Destino |
|---|---|
| `check-in` | ArrivalDetailScreen (bookingId en metadata) |
| `check-out` | DepartureDetailScreen (bookingId en metadata) |
| `housekeeping` | TaskDetailScreen (taskId en metadata) |
| `booking` | ArrivalsScreen |
| `payment` | GuestAccountScreen (accountId en metadata) |
| `inventory` | (fuera de MVP móvil — navegar a NotificationsScreen) |
| `system` | NotificationsScreen |

---

## Pantalla: NotificationsScreen

### Layout

```
┌─────────────────────────────────────┐
│  Notificaciones                     │
│                    [Marcar todas ✓] │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🔔 Check-in Pendiente       │    │  ← no leída (fondo destacado)
│  │ Juan García — Hab. 205      │    │
│  │ Hace 5 minutos              │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ✓ Nueva Tarea Asignada      │    │  ← leída (fondo normal)
│  │ Limpieza — Hab. 101         │    │
│  │ Hace 1 hora                 │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### Información por notificación
- Ícono según tipo
- Título
- Mensaje
- Tiempo relativo (hace X minutos/horas)
- Fondo diferenciado: no leída (color suave) / leída (blanco/gris)

### Acciones
- Tap en notificación: marcar como leída + navegar al destino (si tiene `actionUrl`)
- Botón "Marcar todas como leídas"
- Swipe para eliminar (opcional, Could Have)

---

## Reglas de negocio

1. Cada usuario solo ve sus propias notificaciones (`userId == uid`)
2. Las notificaciones se muestran ordenadas por `createdAt DESC`
3. Al hacer tap en una notificación, se marca como leída automáticamente
4. El badge del ícono de notificaciones en el bottom nav muestra el conteo de no leídas
5. Badge máximo: "99+"
6. El token FCM es por dispositivo. Si el usuario usa múltiples dispositivos, cada uno tiene su token. El sistema web guarda un solo `fcmToken` por usuario — esto significa que solo el último dispositivo en hacer login recibirá notificaciones push.

**Nota**: Un solo token FCM por usuario es suficiente para el MVP. Soporte de múltiples dispositivos es una mejora futura (ver OQ-012 en open-questions.md).

## Datos

**Stream notificaciones**:
```
notifications
  WHERE userId == currentUserId
  ORDER BY createdAt DESC
  LIMIT 50
```

**Conteo no leídas**:
```
notifications
  WHERE userId == currentUserId
  AND read == false
```

## UI/UX

- Lista con scroll
- Pull-to-refresh
- Notificaciones no leídas: fondo con color primario muy suave
- Notificaciones leídas: fondo blanco/gris
- Tiempo relativo: "Hace 5 min", "Hace 2 horas", "Ayer"
- Ícono por tipo de notificación
- Badge en bottom nav actualizado en tiempo real

## Estados de pantalla

| Estado | Comportamiento |
|---|---|
| Loading | Skeleton de lista |
| Success con datos | Lista de notificaciones |
| Empty | "No tienes notificaciones" |
| Error | "No se pudieron cargar las notificaciones" + reintentar |

## Permisos

- Todos los roles autenticados
- Cada usuario solo ve sus propias notificaciones (Firestore Rules ya lo garantizan)

## Criterios de aceptación

- [ ] Al hacer login, la app solicita permisos de notificaciones
- [ ] Token FCM se guarda en Firestore al hacer login
- [ ] Notificación push llega cuando la app está en background
- [ ] Tap en notificación push abre la pantalla correcta
- [ ] Notificación in-app visible cuando la app está en foreground
- [ ] NotificationsScreen muestra notificaciones del usuario actual
- [ ] Notificaciones no leídas tienen fondo diferenciado
- [ ] Tap en notificación la marca como leída
- [ ] "Marcar todas como leídas" funciona
- [ ] Badge en bottom nav muestra conteo correcto
- [ ] Badge se actualiza en tiempo real

## Consideraciones técnicas

- Usar `firebase_messaging` para FCM
- Para notificaciones in-app en foreground, implementar un overlay propio o usar un paquete como `overlay_support`
- El `actionUrl` del modelo de notificación existente es una ruta web (ej: `/bookings`). En la app móvil, mapear estas rutas a las rutas de GoRouter correspondientes.
- Configurar `AndroidNotificationChannel` para Android
- Configurar APNs para iOS (requiere certificado en Apple Developer Console)

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md` — `NotificationItem`, `SkeletonLoader`, `EmptyState`
**Referencias**: `docs/design-references/general.jpg`

### Elementos REQUIRED
- `NotificationItem`: fondo diferenciado no leída (`infoBg`) vs leída (`glassSecondary`)
- Punto azul para notificaciones no leídas
- Ícono por tipo de notificación
- Tiempo relativo ("Hace 5 min", "Hace 2 horas", "Ayer")
- Banner in-app (foreground): `GlassCard.elevated()` en la parte superior, 4 segundos
- Badge en bottom nav: círculo rojo, máximo "99+"

### Elementos FLEXIBLE
- Implementación exacta del banner in-app (overlay nativo vs paquete)
- Animación de entrada/salida del banner
- Swipe para descartar notificaciones (Could Have)
