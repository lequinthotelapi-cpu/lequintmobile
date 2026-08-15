import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/front_desk/departure_detail_screen.dart';

final _booking = Booking(
  id: 'booking-1',
  bookingNumber: 'BK-1',
  guestId: 'guest-1',
  guestName: 'Juan Pérez',
  guestEmail: 'juan@example.com',
  guestPhone: '123',
  roomId: 'room-1',
  roomNumber: '205',
  roomType: 'Suite',
  checkInDate: DateTime(2026, 8, 12),
  checkOutDate: DateTime(2026, 8, 15),
  nights: 3,
  adults: 2,
  children: 0,
  basePrice: 150,
  totalPrice: 450,
  status: BookingStatus.checkedIn,
  source: 'direct',
  createdAt: DateTime(2026, 8, 12),
  createdBy: 'admin-1',
);

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

GuestAccount _account({required double balance}) {
  final now = DateTime(2026, 8, 12);
  return GuestAccount(
    id: 'account-1',
    bookingId: _booking.id,
    bookingNumber: _booking.bookingNumber,
    guestId: _booking.guestId,
    guestName: _booking.guestName,
    roomId: _booking.roomId,
    roomNumber: _booking.roomNumber,
    status: GuestAccountStatus.open,
    checkInDate: now,
    charges: const [],
    payments: const [],
    subtotal: 450,
    tax: 0,
    total: 450,
    paid: 450 - balance,
    balance: balance,
    createdAt: now,
    createdBy: 'admin-1',
  );
}

Future<void> _pumpScreen(WidgetTester tester, GuestAccount? account) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        departuresProvider.overrideWith((ref) => Stream.value([_booking])),
        guestAccountByBookingProvider(
          _booking.id,
        ).overrideWith((ref) => Future.value(account)),
        currentUserProvider.overrideWithValue(_receptionist),
      ],
      child: MaterialApp(home: DepartureDetailScreen(bookingId: _booking.id)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'el botón de check-out está deshabilitado si el saldo es mayor a 0',
    (tester) async {
      await _pumpScreen(tester, _account(balance: 85));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Realizar Check-Out'),
      );
      expect(button.onPressed, isNull);
      expect(
        find.textContaining('El huésped tiene saldo pendiente de \$85.00'),
        findsOneWidget,
      );
    },
  );

  testWidgets('el botón de check-out está habilitado si el saldo es 0', (
    tester,
  ) async {
    await _pumpScreen(tester, _account(balance: 0));

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Realizar Check-Out'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'el botón de check-out está deshabilitado si no existe la cuenta',
    (tester) async {
      await _pumpScreen(tester, null);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Realizar Check-Out'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('No se encontró la cuenta del huésped'), findsOneWidget);
    },
  );
}
