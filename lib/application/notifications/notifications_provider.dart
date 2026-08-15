import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../infrastructure/firebase/notification_firebase_repository.dart';
import '../auth/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationFirebaseRepository();
});

/// Conteo de notificaciones no leídas del usuario actual — usado por el
/// badge del bottom nav (SPEC-002) y, más adelante, por NotificationsScreen
/// (TASK-012).
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid);
});
