import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/errors/app_exception.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/room.dart';
import 'package:lequintmobile/domain/validators/booking_validators.dart';

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
    roomNumber: '101',
    roomType: 'standard',
    checkInDate: now,
    checkOutDate: now.add(const Duration(days: 2)),
    nights: 2,
    adults: 2,
    children: 0,
    basePrice: 100,
    totalPrice: 200,
    status: status,
    source: 'direct',
    createdAt: now,
    createdBy: 'user-1',
  );
}

Room _room({required RoomStatus status}) {
  return Room(
    id: 'room-1',
    roomNumber: '101',
    floor: 1,
    roomType: 'standard',
    bedType: 'double',
    capacity: 2,
    amenities: const [],
    status: status,
    isActive: true,
    basePrice: 100,
  );
}

GuestAccount _account({required double balance}) {
  final now = DateTime(2026, 8, 14);
  return GuestAccount(
    id: 'acc-1',
    bookingId: 'booking-1',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    roomId: 'room-1',
    roomNumber: '101',
    status: GuestAccountStatus.open,
    checkInDate: now,
    charges: const [],
    payments: const [],
    subtotal: balance,
    tax: 0,
    total: balance,
    paid: 0,
    balance: balance,
    createdAt: now,
    createdBy: 'user-1',
  );
}

void main() {
  group('validateCheckIn', () {
    test(
      'no lanza si la reserva está confirmada y la habitación disponible',
      () {
        expect(
          () => validateCheckIn(
            booking: _booking(status: BookingStatus.confirmed),
            room: _room(status: RoomStatus.available),
          ),
          returnsNormally,
        );
      },
    );

    test(
      'lanza BookingNotConfirmedException si la reserva no está confirmada',
      () {
        expect(
          () => validateCheckIn(
            booking: _booking(status: BookingStatus.pending),
            room: _room(status: RoomStatus.available),
          ),
          throwsA(isA<BookingNotConfirmedException>()),
        );
      },
    );

    test(
      'lanza RoomNotAvailableException si la habitación no está disponible',
      () {
        expect(
          () => validateCheckIn(
            booking: _booking(status: BookingStatus.confirmed),
            room: _room(status: RoomStatus.occupied),
          ),
          throwsA(isA<RoomNotAvailableException>()),
        );
      },
    );
  });

  group('validateCheckOut', () {
    test('no lanza si la reserva está checked-in y el saldo es 0', () {
      expect(
        () => validateCheckOut(
          booking: _booking(status: BookingStatus.checkedIn),
          account: _account(balance: 0),
        ),
        returnsNormally,
      );
    });

    test(
      'lanza BookingNotCheckedInException si la reserva no tiene check-in activo',
      () {
        expect(
          () => validateCheckOut(
            booking: _booking(status: BookingStatus.confirmed),
            account: _account(balance: 0),
          ),
          throwsA(isA<BookingNotCheckedInException>()),
        );
      },
    );

    test('lanza GuestAccountNotFoundException si no existe la cuenta', () {
      expect(
        () => validateCheckOut(
          booking: _booking(status: BookingStatus.checkedIn),
          account: null,
        ),
        throwsA(isA<GuestAccountNotFoundException>()),
      );
    });

    test('lanza AccountBalancePendingException si el saldo es mayor a 0', () {
      expect(
        () => validateCheckOut(
          booking: _booking(status: BookingStatus.checkedIn),
          account: _account(balance: 85),
        ),
        throwsA(
          isA<AccountBalancePendingException>().having(
            (e) => e.message,
            'message',
            contains('85.00'),
          ),
        ),
      );
    });
  });
}
