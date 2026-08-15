import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/presentation/front_desk/in_house_screen.dart';

Booking _booking(String id, String guestName) {
  final now = DateTime(2026, 8, 14);
  return Booking(
    id: id,
    bookingNumber: 'BK-$id',
    guestId: 'guest-$id',
    guestName: guestName,
    guestEmail: 'guest@example.com',
    guestPhone: '123',
    roomId: 'room-$id',
    roomNumber: id,
    roomType: 'standard',
    checkInDate: now,
    checkOutDate: now.add(const Duration(days: 2)),
    nights: 2,
    adults: 1,
    children: 0,
    basePrice: 100,
    totalPrice: 200,
    status: BookingStatus.checkedIn,
    source: 'direct',
    createdAt: now,
    createdBy: 'admin-1',
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<Booking> bookings,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inHouseProvider.overrideWith((ref) => Stream.value(bookings)),
        guestAccountByBookingProvider.overrideWith(
          (ref, bookingId) async => null,
        ),
      ],
      child: const MaterialApp(home: InHouseScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('muestra los huéspedes en casa', (tester) async {
    await _pump(
      tester,
      bookings: [_booking('101', 'Juan Pérez'), _booking('102', 'Ana Ruiz')],
    );

    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text('Ana Ruiz'), findsOneWidget);
    expect(find.text('2 huéspedes en casa'), findsOneWidget);
  });

  testWidgets('filtra por nombre o habitación', (tester) async {
    await _pump(
      tester,
      bookings: [_booking('101', 'Juan Pérez'), _booking('102', 'Ana Ruiz')],
    );

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pump();

    expect(find.text('Juan Pérez'), findsNothing);
    expect(find.text('Ana Ruiz'), findsOneWidget);
  });

  testWidgets('estado vacío cuando no hay huéspedes en casa', (tester) async {
    await _pump(tester, bookings: const []);

    expect(find.text('No hay huéspedes en casa'), findsOneWidget);
  });

  testWidgets('tap sin cuenta encontrada muestra snackbar', (tester) async {
    await _pump(tester, bookings: [_booking('101', 'Juan Pérez')]);

    await tester.tap(find.text('Juan Pérez'));
    await tester.pump();

    expect(
      find.text('No se encontró la cuenta de este huésped'),
      findsOneWidget,
    );
  });
}
