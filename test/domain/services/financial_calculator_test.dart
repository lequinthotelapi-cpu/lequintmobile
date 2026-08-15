import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/room.dart';
import 'package:lequintmobile/domain/models/sale.dart';
import 'package:lequintmobile/domain/services/financial_calculator.dart';

Room _room({required String id, bool isActive = true}) {
  return Room(
    id: id,
    roomNumber: id,
    floor: 1,
    roomType: 'standard',
    bedType: 'double',
    capacity: 2,
    amenities: const [],
    status: RoomStatus.available,
    isActive: isActive,
    basePrice: 100,
  );
}

Booking _booking({
  required DateTime checkIn,
  required DateTime checkOut,
  BookingStatus status = BookingStatus.checkedOut,
}) {
  return Booking(
    id: 'b-${checkIn.millisecondsSinceEpoch}',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    guestEmail: 'juan@example.com',
    guestPhone: '123',
    roomId: 'r1',
    roomNumber: '101',
    roomType: 'standard',
    checkInDate: checkIn,
    checkOutDate: checkOut,
    nights: checkOut.difference(checkIn).inDays,
    adults: 1,
    children: 0,
    basePrice: 100,
    totalPrice: 200,
    status: status,
    source: 'direct',
    createdAt: checkIn,
    createdBy: 'admin-1',
  );
}

GuestAccount _account({
  required double total,
  required double balance,
  GuestAccountStatus status = GuestAccountStatus.closed,
  DateTime? closedAt,
  List<Charge> charges = const [],
}) {
  return GuestAccount(
    id: 'acc-1',
    bookingId: 'b-1',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    roomId: 'r1',
    roomNumber: '101',
    status: status,
    checkInDate: DateTime(2026, 8, 1),
    charges: charges,
    payments: const [],
    subtotal: total,
    tax: 0,
    total: total,
    paid: total - balance,
    balance: balance,
    createdAt: DateTime(2026, 8, 1),
    createdBy: 'admin-1',
    closedAt: closedAt,
  );
}

Charge _charge(ChargeType type, double amount) {
  final now = DateTime(2026, 8, 10);
  return Charge(
    accountId: 'acc-1',
    type: type,
    description: type.value,
    amount: amount,
    quantity: 1,
    total: amount,
    date: now,
    createdBy: 'admin-1',
    createdAt: now,
  );
}

Sale _sale(double total) {
  return Sale(
    id: 'sale-${total.hashCode}',
    items: const [],
    subtotal: total,
    tax: 0,
    total: total,
    paymentMethod: 'cash',
    createdAt: DateTime(2026, 8, 10),
    createdBy: 'admin-1',
    createdByName: 'Admin',
  );
}

void main() {
  final periodStart = DateTime(2026, 8);
  final periodEnd = DateTime(2026, 8, 31, 23, 59, 59);

  group('isBookingInPeriod', () {
    test('la reserva intersecta el período', () {
      final booking = _booking(
        checkIn: DateTime(2026, 7, 30),
        checkOut: DateTime(2026, 8, 2),
      );
      expect(isBookingInPeriod(booking, periodStart, periodEnd), isTrue);
    });

    test('la reserva termina antes del período', () {
      final booking = _booking(
        checkIn: DateTime(2026, 7, 10),
        checkOut: DateTime(2026, 7, 20),
      );
      expect(isBookingInPeriod(booking, periodStart, periodEnd), isFalse);
    });

    test('la reserva empieza después del período', () {
      final booking = _booking(
        checkIn: DateTime(2026, 9, 1),
        checkOut: DateTime(2026, 9, 5),
      );
      expect(isBookingInPeriod(booking, periodStart, periodEnd), isFalse);
    });
  });

  group('calculateNights', () {
    test('reserva completamente dentro del período', () {
      final nights = calculateNights(
        DateTime(2026, 8, 5),
        DateTime(2026, 8, 8),
        periodStart,
        periodEnd,
      );
      expect(nights, 3);
    });

    test('recorta al inicio del período (check-in antes del período)', () {
      final nights = calculateNights(
        DateTime(2026, 7, 28),
        DateTime(2026, 8, 3),
        periodStart,
        periodEnd,
      );
      expect(nights, 2);
    });

    test('recorta al final del período (check-out después del período)', () {
      final nights = calculateNights(
        DateTime(2026, 8, 29),
        DateTime(2026, 9, 3),
        periodStart,
        periodEnd,
      );
      // 29 -> 31 23:59:59, redondeado hacia arriba = 3 noches.
      expect(nights, 3);
    });

    test('sin intersección retorna 0', () {
      final nights = calculateNights(
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 5),
        periodStart,
        periodEnd,
      );
      expect(nights, 0);
    });
  });

  group('getDaysBetween', () {
    test('un mes completo (agosto, 31 días) da 31 días inclusive', () {
      expect(getDaysBetween(DateTime(2026, 8), DateTime(2026, 8, 31)), 31);
    });

    test('mismo día da 1', () {
      final day = DateTime(2026, 8, 10);
      expect(getDaysBetween(day, day), 1);
    });
  });

  group('calculateOccupancyRate', () {
    test('calcula ocupación sobre habitaciones activas', () {
      final rooms = [_room(id: 'r1'), _room(id: 'r2')];
      final bookings = [
        _booking(
          checkIn: DateTime(2026, 8, 1),
          checkOut: DateTime(2026, 8, 11),
          status: BookingStatus.checkedOut,
        ),
      ];
      final rate = calculateOccupancyRate(
        rooms,
        bookings,
        DateTime(2026, 8),
        DateTime(2026, 8, 10),
      );
      // calculateNights recorta el check-out (11 ago) al fin del período
      // (10 ago): 9 noches vendidas / (2 habitaciones * 10 días) = 45%.
      expect(rate, 45);
    });

    test('ignora reservas pending/confirmed (no ocupan)', () {
      final rooms = [_room(id: 'r1')];
      final bookings = [
        _booking(
          checkIn: DateTime(2026, 8, 1),
          checkOut: DateTime(2026, 8, 5),
          status: BookingStatus.confirmed,
        ),
      ];
      final rate = calculateOccupancyRate(
        rooms,
        bookings,
        DateTime(2026, 8),
        DateTime(2026, 8, 10),
      );
      expect(rate, 0);
    });

    test('sin habitaciones activas retorna 0', () {
      final rate = calculateOccupancyRate([], [], periodStart, periodEnd);
      expect(rate, 0);
    });
  });

  group('calculateTotalRevenue', () {
    test('suma cuentas cerradas en el período + ventas', () {
      final accounts = [
        _account(total: 100, balance: 0, closedAt: DateTime(2026, 8, 15)),
        _account(total: 999, balance: 0, status: GuestAccountStatus.open),
        _account(total: 500, balance: 0, closedAt: DateTime(2026, 7, 1)),
      ];
      final sales = [_sale(50), _sale(25)];

      final revenue = calculateTotalRevenue(
        accounts,
        sales,
        periodStart,
        periodEnd,
      );

      expect(revenue, 175);
    });
  });

  group('calculateRevPAR', () {
    test('ingresos / (habitaciones activas * días)', () {
      final rooms = [_room(id: 'r1'), _room(id: 'r2')];
      final revPAR = calculateRevPAR(
        200,
        rooms,
        DateTime(2026, 8),
        DateTime(2026, 8, 10),
      );
      expect(revPAR, 10);
    });
  });

  group('calculateADR', () {
    test('ingresos / noches vendidas', () {
      final bookings = [
        _booking(
          checkIn: DateTime(2026, 8, 1),
          checkOut: DateTime(2026, 8, 5),
          status: BookingStatus.checkedOut,
        ),
      ];
      final adr = calculateADR(400, bookings, periodStart, periodEnd);
      expect(adr, 100);
    });

    test('sin noches vendidas retorna 0', () {
      final adr = calculateADR(400, [], periodStart, periodEnd);
      expect(adr, 0);
    });
  });

  group('calculateAccountsReceivable', () {
    test('suma balance de cuentas abiertas, ignora cerradas', () {
      final accounts = [
        _account(total: 100, balance: 40, status: GuestAccountStatus.open),
        _account(total: 200, balance: 60, status: GuestAccountStatus.open),
        _account(total: 500, balance: 0, closedAt: DateTime(2026, 8, 1)),
      ];
      expect(calculateAccountsReceivable(accounts), 100);
    });
  });

  group('calculateRevenueBySource', () {
    test(
      'agrupa cargos de cuentas cerradas por tipo + ventas como POS Directo',
      () {
        final accounts = [
          _account(
            total: 300,
            balance: 0,
            closedAt: DateTime(2026, 8, 15),
            charges: [
              _charge(ChargeType.accommodation, 200),
              _charge(ChargeType.service, 50),
              _charge(ChargeType.minibar, 30),
              _charge(ChargeType.pos, 20),
            ],
          ),
          // Cuenta abierta: sus cargos no cuentan.
          _account(
            total: 999,
            balance: 999,
            status: GuestAccountStatus.open,
            charges: [_charge(ChargeType.accommodation, 999)],
          ),
        ];
        final sales = [_sale(40), _sale(10)];

        final sources = calculateRevenueBySource(
          accounts,
          sales,
          periodStart,
          periodEnd,
        );

        final byLabel = {for (final s in sources) s.label: s.amount};
        expect(byLabel['Alojamiento'], 200);
        expect(byLabel['POS Directo'], 50);
        expect(byLabel['Servicios'], 50);
        expect(
          byLabel['Otros'],
          50,
        ); // minibar (30) + pos dentro de cuenta (20)
      },
    );

    test('sin cuentas ni ventas, todas las fuentes en 0', () {
      final sources = calculateRevenueBySource(
        const [],
        const [],
        periodStart,
        periodEnd,
      );
      expect(sources.every((s) => s.amount == 0), isTrue);
      expect(sources.length, 4);
    });
  });
}
