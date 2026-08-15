# TASK-012 — Notificaciones push y centro de notificaciones

**ID**: TASK-012
**SPEC**: SPEC-009
**Dependencias**: TASK-004, TASK-005
**Estado**: CÓDIGO COMPLETO — pendiente configuración manual de APNs

> Todo el código (FCMService, NotificationsScreen, banner in-app, canal
> Android, entitlements iOS) está implementado y probado. Falta un paso
> externo que solo el usuario puede hacer: generar la APNs Auth Key en
> Apple Developer Console y subirla a Firebase Console, luego probar en
> un dispositivo físico. Ver conversación — acordado retomarlo después.

---

## Objetivo

Implementar la recepción de notificaciones push con FCM, el comportamiento en foreground/background, deep linking, y el centro de notificaciones.

## Alcance

### FCMService (lib/infrastructure/services/fcm_service.dart)

```dart
class FCMService {
  // initialize(): solicitar permisos, obtener token, configurar handlers
  // saveToken(uid, token): guardar en users/{uid}.fcmToken
  // handleForegroundMessage(message): mostrar banner in-app
  // handleNotificationTap(message): navegar según actionUrl/tipo
  // _mapActionUrlToRoute(actionUrl, metadata): mapear ruta web → ruta GoRouter
}
```

**Mapeo de rutas**:
```dart
String _mapActionUrlToRoute(String? actionUrl, Map? metadata) {
  if (actionUrl == '/bookings' && metadata?['bookingId'] != null) {
    return '/arrivals/${metadata!['bookingId']}';
  }
  if (actionUrl == '/housekeeping' && metadata?['taskId'] != null) {
    return '/tasks/${metadata!['taskId']}';
  }
  if (actionUrl == '/guest-accounts' && metadata?['roomId'] != null) {
    return '/accounts/${metadata!['roomId']}';
  }
  return '/notifications'; // fallback
}
```

### Provider

```dart
// notifications_provider.dart

final notificationsProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUserProvider).value?.uid;
  return ref.read(notificationRepositoryProvider).getByUserId(uid!);
});

final unreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final uid = ref.watch(currentUserProvider).value?.uid;
  return ref.read(notificationRepositoryProvider).getUnreadCount(uid!);
});
```

### Pantalla: NotificationsScreen

- Lista de notificaciones ordenadas por fecha DESC
- Fondo diferenciado: no leída vs leída
- Tiempo relativo (hace X min/horas/días)
- Ícono por tipo de notificación
- Tap: marcar como leída + navegar si tiene actionUrl
- Botón "Marcar todas como leídas"
- Pull-to-refresh
- Empty state: "No tienes notificaciones"

### Banner in-app (foreground)

```dart
// Usar overlay o paquete overlay_support
// Banner en la parte superior, desaparece en 4 segundos
// Tap en banner: navegar al destino
```

### Configuración Android

- Crear `AndroidNotificationChannel` con importancia alta
- Configurar en `AndroidManifest.xml`

### Configuración iOS

- Configurar APNs en `AppDelegate.swift`
- Solicitar permisos con `UNAuthorizationOptions`

## Criterios de aceptación

- [ ] Al hacer login, la app solicita permisos de notificaciones
- [ ] Token FCM se guarda en Firestore
- [ ] Notificación push llega cuando la app está en background
- [ ] Tap en notificación push abre la pantalla correcta (deep link)
- [ ] Banner in-app visible cuando la app está en foreground
- [ ] NotificationsScreen muestra notificaciones del usuario
- [ ] Notificaciones no leídas tienen fondo diferenciado
- [ ] Tap en notificación la marca como leída
- [ ] "Marcar todas como leídas" funciona
- [ ] Badge en bottom nav muestra conteo correcto y se actualiza en tiempo real
- [ ] Token se actualiza en Firestore cuando FCM lo renueva

## Notas

- Para el banner in-app, evaluar `overlay_support` o implementar con `OverlayEntry` nativo de Flutter
- La configuración de APNs para iOS requiere un certificado en Apple Developer Console — documentar este paso para el desarrollador
- El campo `fcmToken` en Firestore es un solo string. Si el usuario usa múltiples dispositivos, solo el último token registrado recibirá notificaciones. Esto es aceptable para el MVP (OQ-012 pendiente).
