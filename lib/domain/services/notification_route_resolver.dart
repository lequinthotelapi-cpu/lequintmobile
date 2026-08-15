import '../../core/constants/app_routes.dart';
import '../models/notification.dart';

/// Mapea una [AppNotification] a la ruta de GoRouter correspondiente — ver
/// SPEC-009 "Deep links por tipo de notificación" y el pseudocódigo
/// `_mapActionUrlToRoute` de TASK-012.
///
/// El sistema web escribe `actionUrl` como una ruta web (ej. `/bookings`).
/// Esa ruta identifica el área; el `type` de la notificación desambigua
/// check-in vs. check-out dentro del área `/bookings` (TASK-012 no cubre
/// este caso explícitamente, pero la tabla de deep links de SPEC-009 sí
/// distingue ambos tipos).
///
/// Retorna `null` cuando no hay un destino específico (se debe permanecer
/// en NotificationsScreen).
String? resolveNotificationRoute(AppNotification notification) {
  final metadata = notification.metadata;

  switch (notification.actionUrl) {
    case '/bookings':
      final bookingId = metadata?.bookingId;
      if (bookingId == null) return AppRoutes.arrivals;
      return notification.type == NotificationType.checkOut
          ? AppRoutes.departureDetailPath(bookingId)
          : AppRoutes.arrivalDetailPath(bookingId);
    case '/housekeeping':
      final taskId = metadata?.taskId;
      return taskId == null ? null : AppRoutes.taskDetailPath(taskId);
    case '/guest-accounts':
      final roomId = metadata?.roomId;
      return roomId == null ? null : AppRoutes.accountDetailPath(roomId);
  }

  // Sin actionUrl reconocido: usar el tipo como respaldo (cubre el caso en
  // que el backend aún no setea actionUrl para ciertos tipos).
  switch (notification.type) {
    case NotificationType.checkIn:
      final bookingId = metadata?.bookingId;
      return bookingId == null ? null : AppRoutes.arrivalDetailPath(bookingId);
    case NotificationType.checkOut:
      final bookingId = metadata?.bookingId;
      return bookingId == null
          ? null
          : AppRoutes.departureDetailPath(bookingId);
    case NotificationType.housekeeping:
      final taskId = metadata?.taskId;
      return taskId == null ? null : AppRoutes.taskDetailPath(taskId);
    case NotificationType.booking:
      return AppRoutes.arrivals;
    case NotificationType.payment:
      final roomId = metadata?.roomId;
      return roomId == null ? null : AppRoutes.accountDetailPath(roomId);
    case NotificationType.inventory:
    case NotificationType.system:
      return null;
  }
}
