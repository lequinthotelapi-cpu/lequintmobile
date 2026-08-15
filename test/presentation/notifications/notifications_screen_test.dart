import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/notifications/notifications_provider.dart';
import 'package:lequintmobile/domain/models/notification.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/domain/repositories/notification_repository.dart';
import 'package:lequintmobile/presentation/notifications/notifications_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

final _currentUser = User(
  uid: 'user-1',
  firstName: 'María',
  lastName: 'Gómez',
  email: 'maria@lequint.com',
  document: '123',
  gender: 'femenino',
  role: UserRole.admin,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

AppNotification _notification({
  required String id,
  required bool read,
  NotificationType type = NotificationType.system,
}) {
  return AppNotification(
    id: id,
    userId: 'user-1',
    type: type,
    title: 'Notificación $id',
    message: 'Mensaje $id',
    read: read,
    createdAt: DateTime(2026, 8, 14, 10),
    priority: NotificationPriority.medium,
  );
}

void main() {
  late _MockNotificationRepository repository;

  setUp(() {
    repository = _MockNotificationRepository();
    when(() => repository.markAsRead(any())).thenAnswer((_) async {});
    when(() => repository.markAllAsRead(any())).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required List<AppNotification> notifications,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(_currentUser),
          notificationRepositoryProvider.overrideWithValue(repository),
          notificationsProvider.overrideWith(
            (ref) => Stream.value(notifications),
          ),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('muestra el estado vacío cuando no hay notificaciones', (
    tester,
  ) async {
    await pumpScreen(tester, notifications: const []);

    expect(find.text('No tienes notificaciones'), findsOneWidget);
  });

  testWidgets('muestra la lista de notificaciones ordenadas', (tester) async {
    await pumpScreen(
      tester,
      notifications: [
        _notification(id: '1', read: false),
        _notification(id: '2', read: true),
      ],
    );

    expect(find.text('Notificación 1'), findsOneWidget);
    expect(find.text('Notificación 2'), findsOneWidget);
  });

  testWidgets('tap en notificación no leída sin destino la marca como leída', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      notifications: [_notification(id: '1', read: false)],
    );

    await tester.tap(find.text('Notificación 1'));
    await tester.pump();

    verify(() => repository.markAsRead('1')).called(1);
  });

  testWidgets('tap en notificación ya leída no vuelve a marcarla', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      notifications: [_notification(id: '1', read: true)],
    );

    await tester.tap(find.text('Notificación 1'));
    await tester.pump();

    verifyNever(() => repository.markAsRead(any()));
  });

  testWidgets('"Marcar todas ✓" solo aparece si hay no leídas', (tester) async {
    await pumpScreen(
      tester,
      notifications: [_notification(id: '1', read: true)],
    );

    expect(find.text('Marcar todas ✓'), findsNothing);
  });

  testWidgets('"Marcar todas ✓" llama a markAllAsRead', (tester) async {
    await pumpScreen(
      tester,
      notifications: [_notification(id: '1', read: false)],
    );

    await tester.tap(find.text('Marcar todas ✓'));
    await tester.pump();

    verify(() => repository.markAllAsRead('user-1')).called(1);
  });
}
