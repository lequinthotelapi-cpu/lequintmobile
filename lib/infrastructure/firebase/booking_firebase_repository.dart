import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/guest_account.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/validators/booking_validators.dart';
import 'firestore_error_mapper.dart';

/// Implementación Firebase de [BookingRepository] — ver SPEC-006, SPEC-007.
class BookingFirebaseRepository implements BookingRepository {
  BookingFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Booking>> getAll() {
    final stream = _firestore
        .collection('bookings')
        .snapshots()
        .map((snap) => snap.docs.map(Booking.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<List<Booking>> getArrivalsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final stream = _firestore
        .collection('bookings')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('checkInDate', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: ['confirmed', 'pending'])
        .snapshots()
        .map((snap) => snap.docs.map(Booking.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<List<Booking>> getDeparturesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final stream = _firestore
        .collection('bookings')
        .where(
          'checkOutDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('checkOutDate', isLessThan: Timestamp.fromDate(end))
        .where('status', isEqualTo: BookingStatus.checkedIn.value)
        .snapshots()
        .map((snap) => snap.docs.map(Booking.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<List<Booking>> getByStatus(List<BookingStatus> statuses) {
    final stream = _firestore
        .collection('bookings')
        .where('status', whereIn: statuses.map((s) => s.value).toList())
        .snapshots()
        .map((snap) => snap.docs.map(Booking.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Future<void> checkIn({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingSnap = await bookingRef.get();
      if (!bookingSnap.exists) {
        throw const UnknownException('No se encontró la reserva');
      }
      final booking = Booking.fromFirestore(bookingSnap);

      final roomRef = _firestore.collection('rooms').doc(booking.roomId);
      final roomSnap = await roomRef.get();
      if (!roomSnap.exists) {
        throw const RoomNotAvailableException();
      }
      final room = Room.fromFirestore(roomSnap);

      validateCheckIn(booking: booking, room: room);

      // Idempotente: si ya existe una guestAccount para esta reserva, no
      // se crea otra (SPEC-006, regla 2).
      final existingAccounts = await _firestore
          .collection('guestAccounts')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      final batch = _firestore.batch();
      final now = DateTime.now();

      if (existingAccounts.docs.isEmpty) {
        final accountRef = _firestore.collection('guestAccounts').doc();
        final nights = booking.nights;
        final pricePerNight = booking.basePrice;
        final accommodationSubtotal = pricePerNight * nights;

        final charge = Charge(
          accountId: accountRef.id,
          type: ChargeType.accommodation,
          description: 'Alojamiento - $nights noche(s)',
          amount: pricePerNight,
          quantity: nights,
          total: accommodationSubtotal,
          date: now,
          createdBy: userId,
          createdAt: now,
        );

        // DECISION-005: la app móvil no calcula IVA en el MVP — se usa 0
        // hasta que la inconsistencia 13%/19% se resuelva en el sistema web.
        const tax = 0.0;
        final total = accommodationSubtotal + tax;

        final account = GuestAccount(
          id: accountRef.id,
          bookingId: booking.id,
          bookingNumber: booking.bookingNumber,
          guestId: booking.guestId,
          guestName: booking.guestName,
          roomId: booking.roomId,
          roomNumber: booking.roomNumber,
          status: GuestAccountStatus.open,
          checkInDate: booking.checkInDate,
          charges: [charge],
          payments: const [],
          subtotal: accommodationSubtotal,
          tax: tax,
          total: total,
          paid: 0,
          balance: total,
          createdAt: now,
          createdBy: userId,
        );

        batch.set(accountRef, account.toFirestore());
      }

      final nowTimestamp = Timestamp.fromDate(now);
      batch.update(roomRef, {
        'status': RoomStatus.occupied.value,
        'updatedBy': userId,
        'updatedAt': nowTimestamp,
      });
      batch.update(bookingRef, {
        'status': BookingStatus.checkedIn.value,
        'updatedBy': userId,
        'updatedAt': nowTimestamp,
      });

      await batch.commit();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> checkOut({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingSnap = await bookingRef.get();
      if (!bookingSnap.exists) {
        throw const UnknownException('No se encontró la reserva');
      }
      final booking = Booking.fromFirestore(bookingSnap);

      final accountQuery = await _firestore
          .collection('guestAccounts')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();
      final account = accountQuery.docs.isEmpty
          ? null
          : GuestAccount.fromFirestore(accountQuery.docs.first);

      validateCheckOut(booking: booking, account: account);

      final roomRef = _firestore.collection('rooms').doc(booking.roomId);
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      batch.update(roomRef, {
        'status': RoomStatus.dirty.value,
        'updatedBy': userId,
        'updatedAt': now,
      });
      batch.update(bookingRef, {
        'status': BookingStatus.checkedOut.value,
        'updatedBy': userId,
        'updatedAt': now,
      });

      await batch.commit();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
