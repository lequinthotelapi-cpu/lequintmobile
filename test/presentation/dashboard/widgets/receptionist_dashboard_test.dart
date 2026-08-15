import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/application/rooms/rooms_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/dashboard/widgets/receptionist_dashboard.dart';

final _receptionist = User(
  uid: 'reception-1',
  firstName: 'Laura',
  lastName: 'Díaz',
  email: 'laura@lequint.com',
  document: '123',
  gender: 'femenino',
  role: UserRole.receptionist,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

Booking _booking(String id) {
  final now = DateTime(2026, 8, 14);
  return Booking(
    id: id,
    bookingNumber: 'BK-$id',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    guestEmail: 'juan@example.com',
    guestPhone: '123',
    roomId: 'room-1',
    roomNumber: '205',
    roomType: 'standard',
    checkInDate: now,
    checkOutDate: now.add(const Duration(days: 2)),
    nights: 2,
    adults: 1,
    children: 0,
    basePrice: 100,
    totalPrice: 200,
    status: BookingStatus.confirmed,
    source: 'direct',
    createdAt: now,
    createdBy: 'admin-1',
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
        currentUserProvider.overrideWithValue(_receptionist),
        arrivalsProvider.overrideWith((ref) => Stream.value([_booking('a1')])),
        departuresProvider.overrideWith((ref) => Stream.value(const [])),
        roomsWithStatusProvider.overrideWithValue(const AsyncValue.data([])),
        openGuestAccountsProvider.overrideWith(
          (ref) => Stream.value(const <GuestAccount>[]),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: ReceptionistDashboard())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('muestra llegadas/salidas prominentes y la reserva de ejemplo', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.textContaining('Laura'), findsOneWidget);
    expect(find.text('Llegadas hoy'), findsOneWidget);
    expect(find.text('Salidas hoy'), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);
  });

  testWidgets('muestra accesos rápidos sin Reportes (fuera de alcance)', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Llegadas'), findsOneWidget);
    expect(find.text('Salidas'), findsOneWidget);
    expect(find.text('Habitaciones'), findsOneWidget);
    expect(find.text('Reportes'), findsNothing);
  });
}
