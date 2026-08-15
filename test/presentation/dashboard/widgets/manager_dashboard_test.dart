import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/application/dashboard/dashboard_provider.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/application/rooms/rooms_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/domain/services/financial_calculator.dart';
import 'package:lequintmobile/presentation/dashboard/widgets/manager_dashboard.dart';

final _manager = User(
  uid: 'manager-1',
  firstName: 'Carlos',
  lastName: 'Vega',
  email: 'carlos@lequint.com',
  document: '123',
  gender: 'masculino',
  role: UserRole.manager,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

const _kpis = FinancialKpis(
  revenue: 5000,
  occupancyRate: 60,
  revPAR: 30,
  adr: 50,
  accountsReceivable: 200,
);

HousekeepingTask _task(TaskStatus status) {
  final now = DateTime(2026, 8, 14);
  return HousekeepingTask(
    id: 't-${status.value}-${status.hashCode}',
    roomId: 'room-1',
    roomNumber: '101',
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

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(_manager),
        arrivalsProvider.overrideWith((ref) => Stream.value(const [])),
        departuresProvider.overrideWith((ref) => Stream.value(const [])),
        roomsWithStatusProvider.overrideWithValue(const AsyncValue.data([])),
        financialKpisProvider.overrideWith((ref) async => _kpis),
        allTasksProvider.overrideWith(
          (ref) => Stream.value([
            _task(TaskStatus.pending),
            _task(TaskStatus.inProgress),
          ]),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: ManagerDashboard())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'muestra KPIs financieros, resumen de housekeeping y accesos rápidos',
    (tester) async {
      await _pump(tester);

      expect(find.textContaining('Carlos'), findsOneWidget);
      expect(find.text('Ingresos del mes'), findsOneWidget);
      expect(find.text('Housekeeping'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('Tareas'), findsOneWidget);
    },
  );
}
