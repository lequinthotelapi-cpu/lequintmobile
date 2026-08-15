import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/notification_route_resolver.dart';

/// Orquesta la recepción de mensajes FCM en foreground/background y la
/// renovación del token — ver SPEC-009 y TASK-012.
///
/// La solicitud de permisos y el guardado del token inicial ya ocurren en
/// `AuthNotifier._saveFcmToken` (TASK-004); este servicio se limita a lo
/// que TASK-004 no cubre: renovación de token, y los handlers de mensajes
/// en foreground/tap. No conoce `BuildContext` ni Overlay — expone los
/// eventos vía callbacks para que la capa de presentación decida cómo
/// mostrarlos (mantiene esta clase en `infrastructure`, sin dependencias de
/// Flutter UI).
class FCMService {
  FCMService(this._authRepository, {FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final AuthRepository _authRepository;
  final FirebaseMessaging _messaging;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// Debe llamarse una vez por sesión autenticada (uid conocido). Es
  /// seguro llamarlo de nuevo tras un logout/login: [dispose] cancela las
  /// suscripciones previas.
  Future<void> initialize({
    required String uid,
    required void Function(AppNotification notification) onForegroundMessage,
    required void Function(String route) onNavigate,
  }) async {
    dispose();

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      unawaited(_authRepository.saveFcmToken(uid, token));
    });

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      final notification = _notificationFromMessage(message);
      if (notification != null) onForegroundMessage(notification);
    });

    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleTap(message, onNavigate);
    });

    // La app se abrió tocando una notificación mientras estaba cerrada.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage, onNavigate);
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
  }

  void _handleTap(
    RemoteMessage message,
    void Function(String route) onNavigate,
  ) {
    final notification = _notificationFromMessage(message);
    if (notification == null) return;
    final route = resolveNotificationRoute(notification);
    if (route != null) onNavigate(route);
  }

  /// Los mensajes de datos de FCM son `Map<String, String>` planos — a
  /// diferencia del documento en Firestore, no hay un sub-mapa `metadata`
  /// anidado. Se asume que la función que envía el push (fuera del alcance
  /// de este repo, ya configurada en el sistema web — ver SPEC-009
  /// "Contexto") aplana esos campos directamente en `data`. Si el mensaje
  /// no trae `data` (solo `notification`), se arma un valor mínimo con el
  /// título/cuerpo nativos y sin metadata, por lo que
  /// [resolveNotificationRoute] devolverá `null` (queda en
  /// NotificationsScreen).
  AppNotification? _notificationFromMessage(RemoteMessage message) {
    final data = message.data;
    final title = data['title'] as String? ?? message.notification?.title;
    final body = data['message'] as String? ?? message.notification?.body;
    if (title == null && body == null) return null;

    return AppNotification(
      id: data['notificationId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      type: NotificationType.fromValue(data['type'] as String?),
      title: title ?? '',
      message: body ?? '',
      read: false,
      createdAt: DateTime.now(),
      priority: NotificationPriority.fromValue(data['priority'] as String?),
      actionUrl: data['actionUrl'] as String?,
      metadata: NotificationMetadata(
        bookingId: data['bookingId'] as String?,
        taskId: data['taskId'] as String?,
        roomId: data['roomId'] as String?,
        productId: data['productId'] as String?,
      ),
    );
  }
}
