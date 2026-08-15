import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/dashboard/widgets/housekeeper_dashboard.dart';

final _housekeeper = User(
  uid: 'hk-1',
  firstName: 'María',
  lastName: 'Gómez',
  email: 'maria@lequint.com',
  document: '123',
  gender: 'femenino',
  role: UserRole.housekeeper,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

HousekeepingTask _task(String id, TaskStatus status) {
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
      overrides: [
        currentUserProvider.overrideWithValue(_housekeeper),
        myAllTasksProvider.overrideWith((ref) => Stream.value(tasks)),
      ],
      child: const MaterialApp(home: Scaffold(body: HousekeeperDashboard())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('saluda por nombre y muestra la primera tarea pendiente', (
    tester,
  ) async {
    await _pump(
      tester,
      tasks: [
        _task('101', TaskStatus.pending),
        _task('102', TaskStatus.inProgress),
      ],
    );

    expect(find.textContaining('María'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('En progreso'), findsWidgets);
    expect(find.text('Hab. 101'), findsOneWidget);
    expect(find.text('Ver todas mis tareas'), findsOneWidget);
  });

  testWidgets('estado vacío cuando no hay tareas pendientes/en progreso', (
    tester,
  ) async {
    await _pump(tester, tasks: const []);

    expect(find.text('No tienes tareas pendientes'), findsOneWidget);
  });

  testWidgets('no muestra KPIs financieros ni de habitaciones', (tester) async {
    await _pump(tester, tasks: const []);

    expect(find.text('Ingresos del mes'), findsNothing);
    expect(find.text('Estado de habitaciones'), findsNothing);
  });
}
