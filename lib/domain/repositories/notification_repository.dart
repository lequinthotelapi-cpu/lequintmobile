import '../models/notification.dart';

/// Contrato de notificaciones — ver SPEC-009.
abstract interface class NotificationRepository {
  /// Notificaciones de [userId], ordenadas por `createdAt DESC`, máximo 50.
  Stream<List<AppNotification>> getByUserId(String userId);

  Stream<int> getUnreadCount(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);
}
