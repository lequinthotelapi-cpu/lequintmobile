import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';

void main() {
  group('GuestAccount.fromMap', () {
    test('parsea un documento completo con cargos y pagos', () {
      final now = DateTime(2026, 8, 14);
      final account = GuestAccount.fromMap({
        'bookingId': 'booking-1',
        'bookingNumber': 'BK-1',
        'guestId': 'guest-1',
        'guestName': 'Juan Pérez',
        'roomId': 'room-1',
        'roomNumber': '101',
        'status': 'open',
        'checkInDate': Timestamp.fromDate(now),
        'charges': [
          {
            'accountId': 'acc-1',
            'type': 'accommodation',
            'description': 'Alojamiento',
            'amount': 100.0,
            'quantity': 1,
            'total': 100.0,
            'date': Timestamp.fromDate(now),
            'createdBy': 'system',
            'createdAt': Timestamp.fromDate(now),
          },
        ],
        'payments': [
          {
            'accountId': 'acc-1',
            'method': 'card',
            'amount': 50.0,
            'date': Timestamp.fromDate(now),
            'createdBy': 'receptionist-1',
            'createdAt': Timestamp.fromDate(now),
          },
        ],
        'subtotal': 100.0,
        'tax': 13.0,
        'total': 113.0,
        'paid': 50.0,
        'balance': 63.0,
        'createdAt': Timestamp.fromDate(now),
        'createdBy': 'system',
      }, 'acc-1');

      expect(account.status, GuestAccountStatus.open);
      expect(account.charges, hasLength(1));
      expect(account.charges.first.type, ChargeType.accommodation);
      expect(account.payments, hasLength(1));
      expect(account.payments.first.method, PaymentMethod.card);
      expect(account.balance, 63.0);
    });

    test(
      'no lanza excepción con un mapa vacío y aplica valores por defecto',
      () {
        final account = GuestAccount.fromMap(const {}, 'acc-empty');

        expect(account.id, 'acc-empty');
        expect(account.status, GuestAccountStatus.closed);
        expect(account.charges, isEmpty);
        expect(account.payments, isEmpty);
        expect(account.subtotal, 0);
        expect(account.balance, 0);
      },
    );

    test('un método de pago desconocido cae a PaymentMethod.cash', () {
      final account = GuestAccount.fromMap({
        'payments': [
          {'method': 'bitcoin', 'amount': 10.0},
        ],
      }, 'acc-2');

      expect(account.payments.single.method, PaymentMethod.cash);
    });

    test('roundtrip toFirestore -> fromMap preserva los datos', () {
      final now = DateTime(2026, 8, 14);
      final original = GuestAccount.fromMap({
        'bookingId': 'booking-2',
        'bookingNumber': 'BK-2',
        'guestId': 'guest-2',
        'guestName': 'Ana López',
        'roomId': 'room-2',
        'roomNumber': '202',
        'status': 'closed',
        'checkInDate': Timestamp.fromDate(now),
        'checkOutDate': Timestamp.fromDate(now),
        'charges': [],
        'payments': [],
        'subtotal': 200.0,
        'tax': 26.0,
        'total': 226.0,
        'paid': 226.0,
        'balance': 0.0,
        'createdAt': Timestamp.fromDate(now),
        'createdBy': 'system',
        'closedAt': Timestamp.fromDate(now),
        'closedBy': 'admin-1',
      }, 'acc-3');

      final roundtripped = GuestAccount.fromMap(
        original.toFirestore(),
        'acc-3',
      );

      expect(roundtripped.status, original.status);
      expect(roundtripped.balance, original.balance);
      expect(roundtripped.closedBy, original.closedBy);
    });
  });
}
