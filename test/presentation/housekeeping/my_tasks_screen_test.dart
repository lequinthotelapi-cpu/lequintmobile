import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/presentation/housekeeping/my_tasks_screen.dart';

HousekeepingTask _task({
  required String id,
  required TaskStatus status,
  required TaskPriority priority,
}) {
  final now = DateTime(2026, 8, 14);
  return HousekeepingTask(
    id: id,
    roomId: 'room-$id',
    roomNumber: id,
    floor: 1,
    taskType: TaskType.cleaning,
    status: status,
    priority: priority,
    scheduledDate: now,
    estimatedDuration: 30,
    createdAt: now,
    createdBy: 'admin-1',
    updatedAt: now,
    updatedBy: 'admin-1',
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Stream<List<HousekeepingTask>> stream,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [myTasksProvider.overrideWith((ref) => stream)],
      child: const MaterialApp(home: MyTasksScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('muestra el empty state cuando no hay tareas', (tester) async {
    await _pumpScreen(tester, Stream.value(const []));

    expect(find.text('No tienes tareas asignadas por ahora'), findsOneWidget);
  });

  testWidgets(
    'muestra secciones "En progreso" y "Pendientes" con las tareas correctas',
    (tester) async {
      final tasks = [
        _task(
          id: '101',
          status: TaskStatus.pending,
          priority: TaskPriority.urgent,
        ),
        _task(
          id: '102',
          status: TaskStatus.inProgress,
          priority: TaskPriority.normal,
        ),
      ];

      await _pumpScreen(tester, Stream.value(tasks));

      expect(find.text('EN PROGRESO'), findsOneWidget);
      expect(find.text('PENDIENTES'), findsOneWidget);
      expect(find.text('Hab. 101'), findsOneWidget);
      expect(find.text('Hab. 102'), findsOneWidget);
      expect(find.text('2 tareas pendientes'), findsOneWidget);
    },
  );
}
