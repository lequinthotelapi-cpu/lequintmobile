import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/domain/repositories/housekeeping_repository.dart';
import 'package:lequintmobile/presentation/housekeeping/complete_task_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockHousekeepingRepository extends Mock
    implements HousekeepingRepository {}

void main() {
  late _MockHousekeepingRepository repository;
  late HousekeepingTask task;
  late User currentUser;

  setUp(() {
    repository = _MockHousekeepingRepository();
    final now = DateTime(2026, 8, 14);
    task = HousekeepingTask(
      id: 'task-1',
      roomId: 'room-1',
      roomNumber: '101',
      floor: 1,
      assignedTo: 'user-1',
      taskType: TaskType.cleaning,
      status: TaskStatus.inProgress,
      priority: TaskPriority.normal,
      scheduledDate: now,
      estimatedDuration: 30,
      createdAt: now,
      createdBy: 'admin-1',
      updatedAt: now,
      updatedBy: 'admin-1',
    );
    currentUser = User(
      uid: 'user-1',
      firstName: 'María',
      lastName: 'Gómez',
      email: 'maria@lequint.com',
      document: '123',
      gender: 'femenino',
      role: UserRole.housekeeper,
      active: true,
      createdAt: now,
    );
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myTasksProvider.overrideWith((ref) => Stream.value([task])),
          currentUserProvider.overrideWithValue(currentUser),
          housekeepingRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(home: CompleteTaskScreen(taskId: task.id)),
      ),
    );
    await tester.pump();
  }

  ElevatedButton confirmButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar Completación'),
      );

  testWidgets('el botón está deshabilitado si la duración está vacía', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('el botón está deshabilitado si la duración es 0', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pump();

    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('el botón se habilita con una duración mayor a 0', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '30');
    await tester.pump();

    expect(confirmButton(tester).onPressed, isNotNull);
  });

  testWidgets(
    'con mantenimiento activo, el botón exige notas de mantenimiento',
    (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).first, '30');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(confirmButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'Fuga de agua');
      await tester.pump();

      expect(confirmButton(tester).onPressed, isNotNull);
    },
  );
}
