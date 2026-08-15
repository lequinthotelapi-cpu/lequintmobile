import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/booking.dart';

void main() {
  group('Booking.fromMap', () {
    test('parsea un documento completo correctamente', () {
      final checkIn = DateTime(2026, 8, 20);
      final checkOut = DateTime(2026, 8, 22);
      final booking = Booking.fromMap({
        'bookingNumber': 'BK-20260814-001',
        'guestId': 'guest-1',
        'guestName': 'Juan Pérez',
        'guestEmail': 'juan@example.com',
        'guestPhone': '+50588887777',
        'roomId': 'room-1',
        'roomNumber': '101',
        'roomType': 'standard',
        'checkInDate': Timestamp.fromDate(checkIn),
        'checkOutDate': Timestamp.fromDate(checkOut),
        'nights': 2,
        'adults': 2,
        'children': 0,
        'basePrice': 100.0,
        'totalPrice': 200.0,
        'status': 'checked-in',
        'source': 'direct',
        'createdAt': Timestamp.fromDate(checkIn),
        'createdBy': 'user-1',
      }, 'booking-1');

      expect(booking.id, 'booking-1');
      expect(booking.status, BookingStatus.checkedIn);
      expect(booking.checkInDate, checkIn);
      expect(booking.checkOutDate, checkOut);
      expect(booking.nights, 2);
      expect(booking.totalPrice, 200.0);
    });

    test(
      'no lanza excepción con un mapa vacío y aplica valores por defecto',
      () {
        final booking = Booking.fromMap(const {}, 'booking-empty');

        expect(booking.id, 'booking-empty');
        expect(booking.guestName, '');
        expect(booking.status, BookingStatus.pending);
        expect(booking.nights, 0);
        expect(booking.totalPrice, 0);
        expect(booking.updatedAt, isNull);
      },
    );

    test('un valor de status desconocido cae a BookingStatus.pending', () {
      final booking = Booking.fromMap({'status': 'not-a-real-status'}, 'b1');

      expect(booking.status, BookingStatus.pending);
    });

    test('roundtrip toFirestore -> fromMap preserva los datos', () {
      final original = Booking.fromMap({
        'bookingNumber': 'BK-1',
        'guestId': 'g1',
        'guestName': 'Ana López',
        'guestEmail': 'ana@example.com',
        'guestPhone': '123',
        'roomId': 'r1',
        'roomNumber': '202',
        'roomType': 'suite',
        'checkInDate': Timestamp.fromDate(DateTime(2026, 9, 1)),
        'checkOutDate': Timestamp.fromDate(DateTime(2026, 9, 3)),
        'nights': 2,
        'adults': 1,
        'children': 1,
        'basePrice': 150.0,
        'totalPrice': 300.0,
        'status': 'confirmed',
        'source': 'booking.com',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 1)),
        'createdBy': 'admin-1',
      }, 'b1');

      final roundtripped = Booking.fromMap(original.toFirestore(), 'b1');

      expect(roundtripped.guestName, original.guestName);
      expect(roundtripped.status, original.status);
      expect(roundtripped.checkInDate, original.checkInDate);
      expect(roundtripped.totalPrice, original.totalPrice);
    });
  });
}
