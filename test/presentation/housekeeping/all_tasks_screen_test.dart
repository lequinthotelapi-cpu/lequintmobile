import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/presentation/housekeeping/all_tasks_screen.dart';

HousekeepingTask _task({
  required String id,
  required TaskStatus status,
  String? assignedTo,
  String? assignedToName,
}) {
  final now = DateTime(2026, 8, 14);
  return HousekeepingTask(
    id: id,
    roomId: 'room-$id',
    roomNumber: id,
    floor: 1,
    taskType: TaskType.cleaning,
    status: status,
    priority: TaskPriority.normal,
    scheduledDate: now,
    estimatedDuration: 30,
    createdAt: now,
    createdBy: 'admin-1',
    updatedAt: now,
    updatedBy: 'admin-1',
    assignedTo: assignedTo,
    assignedToName: assignedToName,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<HousekeepingTask> tasks,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [allTasksProvider.overrideWith((ref) => Stream.value(tasks))],
      child: const MaterialApp(home: AllTasksScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('muestra todas las tareas, no solo las de un usuario', (
    tester,
  ) async {
    await _pump(
      tester,
      tasks: [
        _task(
          id: '1',
          status: TaskStatus.pending,
          assignedTo: 'emp-1',
          assignedToName: 'María',
        ),
        _task(
          id: '2',
          status: TaskStatus.inProgress,
          assignedTo: 'emp-2',
          assignedToName: 'Ana',
        ),
      ],
    );

    expect(find.text('Hab. 1'), findsOneWidget);
    expect(find.text('Hab. 2'), findsOneWidget);
    expect(find.text('Asignado a: María'), findsOneWidget);
    expect(find.text('Asignado a: Ana'), findsOneWidget);
  });

  testWidgets('filtro Pendiente muestra solo tareas pending', (tester) async {
    await _pump(
      tester,
      tasks: [
        _task(id: '1', status: TaskStatus.pending),
        _task(id: '2', status: TaskStatus.completed),
      ],
    );

    await tester.tap(find.text('Pendiente').first);
    await tester.pump();

    expect(find.text('Hab. 1'), findsOneWidget);
    expect(find.text('Hab. 2'), findsNothing);
  });

  testWidgets('estado vacío cuando no hay tareas', (tester) async {
    await _pump(tester, tasks: const []);

    expect(find.text('No hay tareas registradas'), findsOneWidget);
  });

  testWidgets('toggle cambia a vista por empleado', (tester) async {
    await _pump(
      tester,
      tasks: [
        _task(
          id: '1',
          status: TaskStatus.pending,
          assignedTo: 'emp-1',
          assignedToName: 'María',
        ),
      ],
    );

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pump();

    expect(find.text('María'), findsOneWidget);
  });
}
