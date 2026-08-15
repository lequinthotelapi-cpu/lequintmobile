import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../infrastructure/firebase/booking_firebase_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingFirebaseRepository();
});

/// Reservas con check-in hoy y `status in [confirmed, pending]` — ver
/// SPEC-006.
final arrivalsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref
      .watch(bookingRepositoryProvider)
      .getArrivalsForDate(DateTime.now());
});

/// Reservas con check-out hoy y `status == checked-in` — ver SPEC-007.
final departuresProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref
      .watch(bookingRepositoryProvider)
      .getDeparturesForDate(DateTime.now());
});

/// Huéspedes en casa (`status == checked-in`, sin filtrar por fecha) — ver
/// SPEC-011 "InHouseScreen".
final inHouseProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).getByStatus([
    BookingStatus.checkedIn,
  ]);
});

Booking? findBookingById(List<Booking> bookings, String id) {
  for (final booking in bookings) {
    if (booking.id == id) return booking;
  }
  return null;
}
