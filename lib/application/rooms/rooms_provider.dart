import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/booking.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../../infrastructure/firebase/room_firebase_repository.dart';
import '../bookings/bookings_provider.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomFirebaseRepository();
});

final _allRoomsStreamProvider = StreamProvider.autoDispose<List<Room>>((ref) {
  return ref.watch(roomRepositoryProvider).getAll();
});

final _allBookingsStreamProvider = StreamProvider.autoDispose<List<Booking>>((
  ref,
) {
  return ref.watch(bookingRepositoryProvider).getAll();
});

/// Habitaciones con `displayStatus` calculado — igual lógica que
/// `RoomStatusService` del sistema web (ver SPEC-008). Combina los streams
/// de rooms y bookings a través del grafo reactivo de Riverpod (sin
/// depender de rxdart). Compartido con el dashboard (TASK-007).
final roomsWithStatusProvider =
    Provider.autoDispose<AsyncValue<List<RoomWithStatus>>>((ref) {
      final roomsAsync = ref.watch(_allRoomsStreamProvider);
      final bookingsAsync = ref.watch(_allBookingsStreamProvider);

      if (roomsAsync.isLoading || bookingsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (roomsAsync.hasError) {
        return AsyncValue.error(roomsAsync.error!, roomsAsync.stackTrace!);
      }
      if (bookingsAsync.hasError) {
        return AsyncValue.error(
          bookingsAsync.error!,
          bookingsAsync.stackTrace!,
        );
      }

      final rooms = roomsAsync.value ?? const [];
      final bookings = bookingsAsync.value ?? const [];
      return AsyncValue.data(calculateRoomsWithStatus(rooms, bookings));
    });

/// Estado calculado para mostrar en pantalla (`reserved` no es un valor de
/// [RoomStatus] — ver room.dart): si `room.status != available`, se
/// muestra tal cual; si es `available` y existe una reserva
/// `confirmed`/`pending` con check-in exactamente hoy, se muestra
/// `'reserved'`. Réplica de `room-status.service.ts` (sistema web).
List<RoomWithStatus> calculateRoomsWithStatus(
  List<Room> rooms,
  List<Booking> bookings,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return rooms.map((room) {
    if (room.status == RoomStatus.occupied) {
      // SPEC-008: el nombre del huésped en habitaciones ocupadas sale del
      // booking activo (status == checked-in) — sin query adicional.
      Booking? checkedInBooking;
      for (final booking in bookings) {
        if (booking.roomId == room.id &&
            booking.status == BookingStatus.checkedIn) {
          checkedInBooking = booking;
          break;
        }
      }
      return RoomWithStatus.fromRoom(
        room,
        displayStatus: room.status.value,
        activeBooking: checkedInBooking,
      );
    }
    if (room.status != RoomStatus.available) {
      return RoomWithStatus.fromRoom(room, displayStatus: room.status.value);
    }

    Booking? activeBooking;
    for (final booking in bookings) {
      if (booking.roomId != room.id) continue;
      if (booking.status != BookingStatus.confirmed &&
          booking.status != BookingStatus.pending) {
        continue;
      }
      final checkIn = booking.checkInDate;
      final checkInDay = DateTime(checkIn.year, checkIn.month, checkIn.day);
      if (checkInDay == today) {
        activeBooking = booking;
        break;
      }
    }

    return RoomWithStatus.fromRoom(
      room,
      displayStatus: activeBooking != null
          ? 'reserved'
          : RoomStatus.available.value,
      activeBooking: activeBooking,
    );
  }).toList();
}

/// `null` = todos los estados (sin filtrar).
final roomStatusFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// Orden de estados para `RoomStatusSummary` (dashboard, TASK-007) — igual
/// que SPEC-003: Disponibles, Reservadas, Ocupadas, Sucias, En limpieza,
/// Mantenimiento. Duplica el orden de `roomStatusFilters`
/// (presentation/rooms/room_status_display.dart) a propósito: esta es la
/// capa de aplicación y no debe depender de la de presentación.
const dashboardRoomStatusOrder = [
  'available',
  'reserved',
  'occupied',
  'dirty',
  'cleaning',
  'maintenance',
];

/// Conteo por `displayStatus` — usado por `RoomStatusSummary` (dashboard,
/// TASK-007).
Map<String, int> countRoomsByDisplayStatus(List<RoomWithStatus> rooms) {
  final counts = {for (final status in dashboardRoomStatusOrder) status: 0};
  for (final room in rooms) {
    counts.update(room.displayStatus, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}
