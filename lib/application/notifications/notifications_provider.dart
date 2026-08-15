import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../infrastructure/firebase/notification_firebase_repository.dart';
import '../../infrastructure/services/fcm_service.dart';
import '../auth/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationFirebaseRepository();
});

/// Ver TASK-012: renovación de token FCM y handlers de mensajes en
/// foreground/tap.
final fcmServiceProvider = Provider<FCMService>((ref) {
  final service = FCMService(ref.watch(authRepositoryProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Conteo de notificaciones no leídas del usuario actual — usado por el
/// badge del bottom nav (SPEC-002) y por NotificationsScreen (TASK-012).
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid);
});

/// Notificaciones del usuario actual, ordenadas por `createdAt DESC` — ver
/// SPEC-009.
final notificationsProvider = StreamProvider.autoDispose<List<AppNotification>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Stream.value(const []);
    return ref.watch(notificationRepositoryProvider).getByUserId(user.uid);
  },
);
