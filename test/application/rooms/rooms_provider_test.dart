import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/rooms/rooms_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/domain/models/room.dart';

Room _room({required String id, required RoomStatus status}) {
  return Room(
    id: id,
    roomNumber: id,
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

Booking _booking({
  required String roomId,
  required BookingStatus status,
  required DateTime checkInDate,
}) {
  final now = DateTime(2026, 8, 14);
  return Booking(
    id: 'booking-$roomId-${status.value}',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    guestEmail: 'juan@example.com',
    guestPhone: '123',
    roomId: roomId,
    roomNumber: roomId,
    roomType: 'standard',
    checkInDate: checkInDate,
    checkOutDate: checkInDate.add(const Duration(days: 2)),
    nights: 2,
    adults: 1,
    children: 0,
    basePrice: 100,
    totalPrice: 200,
    status: status,
    source: 'direct',
    createdAt: now,
    createdBy: 'admin-1',
  );
}

void main() {
  final today = DateTime.now();
  final todayNoon = DateTime(today.year, today.month, today.day, 12);
  final tomorrow = todayNoon.add(const Duration(days: 1));

  group('calculateRoomsWithStatus', () {
    test(
      'una habitación available con booking confirmed check-in hoy se muestra reserved',
      () {
        final room = _room(id: 'r1', status: RoomStatus.available);
        final booking = _booking(
          roomId: 'r1',
          status: BookingStatus.confirmed,
          checkInDate: todayNoon,
        );

        final result = calculateRoomsWithStatus([room], [booking]);

        expect(result.single.displayStatus, 'reserved');
        expect(result.single.activeBooking, booking);
      },
    );

    test(
      'una habitación available con booking confirmed check-in mañana sigue available',
      () {
        final room = _room(id: 'r1', status: RoomStatus.available);
        final booking = _booking(
          roomId: 'r1',
          status: BookingStatus.confirmed,
          checkInDate: tomorrow,
        );

        final result = calculateRoomsWithStatus([room], [booking]);

        expect(result.single.displayStatus, 'available');
        expect(result.single.activeBooking, isNull);
      },
    );

    test(
      'una habitación available con booking checked-in (no confirmed/pending) hoy sigue available',
      () {
        final room = _room(id: 'r1', status: RoomStatus.available);
        final booking = _booking(
          roomId: 'r1',
          status: BookingStatus.checkedIn,
          checkInDate: todayNoon,
        );

        final result = calculateRoomsWithStatus([room], [booking]);

        expect(result.single.displayStatus, 'available');
      },
    );

    test(
      'una habitación occupied no depende de bookings confirmed/pending',
      () {
        final room = _room(id: 'r1', status: RoomStatus.occupied);

        final result = calculateRoomsWithStatus([room], const []);

        expect(result.single.displayStatus, 'occupied');
      },
    );

    test('una habitación occupied resuelve el booking checked-in activo', () {
      final room = _room(id: 'r1', status: RoomStatus.occupied);
      final booking = _booking(
        roomId: 'r1',
        status: BookingStatus.checkedIn,
        checkInDate: todayNoon,
      );

      final result = calculateRoomsWithStatus([room], [booking]);

      expect(result.single.displayStatus, 'occupied');
      expect(result.single.activeBooking, booking);
    });

    test(
      'una habitación dirty/cleaning/maintenance conserva su status tal cual',
      () {
        final rooms = [
          _room(id: 'r1', status: RoomStatus.dirty),
          _room(id: 'r2', status: RoomStatus.cleaning),
          _room(id: 'r3', status: RoomStatus.maintenance),
        ];

        final result = calculateRoomsWithStatus(rooms, const []);

        expect(result.map((r) => r.displayStatus).toList(), [
          'dirty',
          'cleaning',
          'maintenance',
        ]);
      },
    );
  });

  group('countRoomsByDisplayStatus', () {
    test('cuenta por displayStatus y devuelve 0 para los ausentes', () {
      final rooms = [
        RoomWithStatus.fromRoom(
          _room(id: 'r1', status: RoomStatus.available),
          displayStatus: 'available',
        ),
        RoomWithStatus.fromRoom(
          _room(id: 'r2', status: RoomStatus.available),
          displayStatus: 'reserved',
        ),
        RoomWithStatus.fromRoom(
          _room(id: 'r3', status: RoomStatus.occupied),
          displayStatus: 'occupied',
        ),
        RoomWithStatus.fromRoom(
          _room(id: 'r4', status: RoomStatus.occupied),
          displayStatus: 'occupied',
        ),
      ];

      final counts = countRoomsByDisplayStatus(rooms);

      expect(counts['available'], 1);
      expect(counts['reserved'], 1);
      expect(counts['occupied'], 2);
      expect(counts['dirty'], 0);
      expect(counts['cleaning'], 0);
      expect(counts['maintenance'], 0);
    });

    test('lista vacía da todos los conteos en 0', () {
      final counts = countRoomsByDisplayStatus(const []);
      expect(counts.values.every((v) => v == 0), isTrue);
      expect(counts.length, dashboardRoomStatusOrder.length);
    });
  });
}
