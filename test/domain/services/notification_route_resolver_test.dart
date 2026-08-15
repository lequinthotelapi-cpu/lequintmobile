import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/notification.dart';
import 'package:lequintmobile/domain/services/notification_route_resolver.dart';

AppNotification _notification({
  NotificationType type = NotificationType.system,
  String? actionUrl,
  NotificationMetadata? metadata,
}) {
  return AppNotification(
    id: 'notif-1',
    userId: 'user-1',
    type: type,
    title: 'Título',
    message: 'Mensaje',
    read: false,
    createdAt: DateTime(2026, 8, 14),
    priority: NotificationPriority.medium,
    actionUrl: actionUrl,
    metadata: metadata,
  );
}

void main() {
  group('resolveNotificationRoute — actionUrl reconocido', () {
    test('/bookings + check-in + bookingId -> ArrivalDetailScreen', () {
      final notification = _notification(
        type: NotificationType.checkIn,
        actionUrl: '/bookings',
        metadata: const NotificationMetadata(bookingId: 'booking-1'),
      );

      expect(resolveNotificationRoute(notification), '/arrivals/booking-1');
    });

    test('/bookings + check-out + bookingId -> DepartureDetailScreen', () {
      final notification = _notification(
        type: NotificationType.checkOut,
        actionUrl: '/bookings',
        metadata: const NotificationMetadata(bookingId: 'booking-1'),
      );

      expect(resolveNotificationRoute(notification), '/departures/booking-1');
    });

    test('/bookings sin bookingId -> ArrivalsScreen (lista)', () {
      final notification = _notification(
        type: NotificationType.booking,
        actionUrl: '/bookings',
      );

      expect(resolveNotificationRoute(notification), '/arrivals');
    });

    test('/housekeeping + taskId -> TaskDetailScreen', () {
      final notification = _notification(
        actionUrl: '/housekeeping',
        metadata: const NotificationMetadata(taskId: 'task-1'),
      );

      expect(resolveNotificationRoute(notification), '/tasks/task-1');
    });

    test('/housekeeping sin taskId -> null', () {
      final notification = _notification(actionUrl: '/housekeeping');

      expect(resolveNotificationRoute(notification), isNull);
    });

    test('/guest-accounts + roomId -> GuestAccountScreen', () {
      final notification = _notification(
        actionUrl: '/guest-accounts',
        metadata: const NotificationMetadata(roomId: 'room-1'),
      );

      expect(resolveNotificationRoute(notification), '/accounts/room-1');
    });
  });

  group('resolveNotificationRoute — respaldo por tipo (sin actionUrl)', () {
    test('check-in + bookingId -> ArrivalDetailScreen', () {
      final notification = _notification(
        type: NotificationType.checkIn,
        metadata: const NotificationMetadata(bookingId: 'booking-1'),
      );

      expect(resolveNotificationRoute(notification), '/arrivals/booking-1');
    });

    test('check-out + bookingId -> DepartureDetailScreen', () {
      final notification = _notification(
        type: NotificationType.checkOut,
        metadata: const NotificationMetadata(bookingId: 'booking-1'),
      );

      expect(resolveNotificationRoute(notification), '/departures/booking-1');
    });

    test('housekeeping + taskId -> TaskDetailScreen', () {
      final notification = _notification(
        type: NotificationType.housekeeping,
        metadata: const NotificationMetadata(taskId: 'task-1'),
      );

      expect(resolveNotificationRoute(notification), '/tasks/task-1');
    });

    test('booking -> ArrivalsScreen', () {
      final notification = _notification(type: NotificationType.booking);

      expect(resolveNotificationRoute(notification), '/arrivals');
    });

    test('payment + roomId -> GuestAccountScreen', () {
      final notification = _notification(
        type: NotificationType.payment,
        metadata: const NotificationMetadata(roomId: 'room-1'),
      );

      expect(resolveNotificationRoute(notification), '/accounts/room-1');
    });

    test('payment sin roomId -> null', () {
      final notification = _notification(type: NotificationType.payment);

      expect(resolveNotificationRoute(notification), isNull);
    });

    test('inventory -> null (fuera de MVP móvil)', () {
      final notification = _notification(type: NotificationType.inventory);

      expect(resolveNotificationRoute(notification), isNull);
    });

    test('system -> null', () {
      final notification = _notification();

      expect(resolveNotificationRoute(notification), isNull);
    });
  });
}
