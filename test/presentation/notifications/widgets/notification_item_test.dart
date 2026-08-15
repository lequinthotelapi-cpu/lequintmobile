import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/constants/app_colors.dart';
import 'package:lequintmobile/domain/models/notification.dart';
import 'package:lequintmobile/presentation/notifications/widgets/notification_item.dart';

AppNotification _notification({required bool read}) {
  return AppNotification(
    id: 'notif-1',
    userId: 'user-1',
    type: NotificationType.checkIn,
    title: 'Check-in Pendiente',
    message: 'Juan García — Hab. 205',
    read: read,
    createdAt: DateTime.now(),
    priority: NotificationPriority.medium,
  );
}

void main() {
  Future<void> pump(WidgetTester tester, AppNotification notification) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationItem(notification: notification, onTap: () {}),
        ),
      ),
    );
  }

  testWidgets('muestra título y mensaje', (tester) async {
    await pump(tester, _notification(read: false));

    expect(find.text('Check-in Pendiente'), findsOneWidget);
    expect(find.text('Juan García — Hab. 205'), findsOneWidget);
  });

  testWidgets('no leída: fondo infoBg y punto azul visible', (tester) async {
    await pump(tester, _notification(read: false));

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.infoBg);

    final dot = tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.shape == BoxShape.circle;
    });
    expect(dot.length, 1);
  });

  testWidgets('leída: fondo glassSecondary y sin punto', (tester) async {
    await pump(tester, _notification(read: true));

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.glassSecondary);

    final dot = tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.shape == BoxShape.circle;
    });
    expect(dot.length, 0);
  });

  testWidgets('tap invoca onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationItem(
            notification: _notification(read: false),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(NotificationItem));
    expect(tapped, isTrue);
  });
}
