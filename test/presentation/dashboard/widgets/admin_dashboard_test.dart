import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/application/dashboard/dashboard_provider.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/application/rooms/rooms_provider.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/room.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/domain/services/financial_calculator.dart';
import 'package:lequintmobile/presentation/dashboard/widgets/admin_dashboard.dart';

final _admin = User(
  uid: 'admin-1',
  firstName: 'Ana',
  lastName: 'Ríos',
  email: 'ana@lequint.com',
  document: '123',
  gender: 'femenino',
  role: UserRole.admin,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

const _kpis = FinancialKpis(
  revenue: 12450,
  occupancyRate: 78.5,
  revPAR: 45.2,
  adr: 57.5,
  accountsReceivable: 850,
);

RoomWithStatus _room(String id, String displayStatus) {
  return RoomWithStatus(
    id: id,
    roomNumber: id,
    floor: 1,
    roomType: 'standard',
    bedType: 'double',
    capacity: 2,
    amenities: const [],
    status: RoomStatus.available,
    isActive: true,
    basePrice: 100,
    displayStatus: displayStatus,
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
        currentUserProvider.overrideWithValue(_admin),
        arrivalsProvider.overrideWith((ref) => Stream.value(const [])),
        departuresProvider.overrideWith((ref) => Stream.value(const [])),
        roomsWithStatusProvider.overrideWithValue(
          AsyncValue.data([
            _room('101', 'available'),
            _room('102', 'occupied'),
          ]),
        ),
        openGuestAccountsProvider.overrideWith(
          (ref) => Stream.value(const <GuestAccount>[]),
        ),
        financialKpisProvider.overrideWith((ref) async => _kpis),
      ],
      child: const MaterialApp(home: Scaffold(body: AdminDashboard())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('muestra saludo, KPIs operacionales y financieros', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.textContaining('Ana'), findsOneWidget);
    expect(find.text('Llegadas hoy'), findsOneWidget);
    expect(find.text('Salidas hoy'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget); // ocupadas/total
    expect(find.text('Ingresos del mes'), findsOneWidget);
    expect(find.text(r'$12,450.00'), findsOneWidget);
  });

  testWidgets('muestra accesos rápidos', (tester) async {
    await _pump(tester);

    expect(find.text('Llegadas'), findsOneWidget);
    expect(find.text('Salidas'), findsOneWidget);
    expect(find.text('Habitaciones'), findsOneWidget);
    expect(find.text('Tareas'), findsOneWidget);
  });
}
