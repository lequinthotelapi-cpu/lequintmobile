import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/front_desk/arrival_detail_screen.dart';

Booking _booking({required BookingStatus status}) {
  final now = DateTime(2026, 8, 14);
  return Booking(
    id: 'booking-1',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    guestEmail: 'juan@example.com',
    guestPhone: '123',
    roomId: 'room-1',
    roomNumber: '205',
    roomType: 'Suite',
    checkInDate: now,
    checkOutDate: now.add(const Duration(days: 3)),
    nights: 3,
    adults: 2,
    children: 0,
    basePrice: 150,
    totalPrice: 450,
    status: status,
    source: 'direct',
    createdAt: now,
    createdBy: 'admin-1',
  );
}

final _receptionist = User(
  uid: 'user-1',
  firstName: 'Ana',
  lastName: 'López',
  email: 'ana@lequint.com',
  document: '123',
  gender: 'femenino',
  role: UserRole.receptionist,
  active: true,
  createdAt: DateTime(2026, 8, 14),
);

Future<void> _pumpScreen(WidgetTester tester, Booking booking) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        arrivalsProvider.overrideWith((ref) => Stream.value([booking])),
        currentUserProvider.overrideWithValue(_receptionist),
      ],
      child: MaterialApp(home: ArrivalDetailScreen(bookingId: booking.id)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'el botón de check-in está deshabilitado si la reserva no está confirmada',
    (tester) async {
      await _pumpScreen(tester, _booking(status: BookingStatus.pending));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Realizar Check-In'),
      );
      expect(button.onPressed, isNull);
      expect(
        find.text('La reserva debe estar confirmada para hacer check-in'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'el botón de check-in está habilitado si la reserva está confirmada',
    (tester) async {
      await _pumpScreen(tester, _booking(status: BookingStatus.confirmed));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Realizar Check-In'),
      );
      expect(button.onPressed, isNotNull);
    },
  );
}
