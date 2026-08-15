import '../models/booking.dart';

/// Contrato de acceso a reservas y ejecución de check-in/check-out — ver
/// SPEC-006, SPEC-007.
abstract interface class BookingRepository {
  Stream<List<Booking>> getAll();

  /// Reservas con `checkInDate` dentro de [date] (día completo) y
  /// `status in [confirmed, pending]`.
  Stream<List<Booking>> getArrivalsForDate(DateTime date);

  /// Reservas con `checkOutDate` dentro de [date] (día completo) y
  /// `status == checked-in`.
  Stream<List<Booking>> getDeparturesForDate(DateTime date);

  Stream<List<Booking>> getByStatus(List<BookingStatus> statuses);

  /// Ejecuta el check-in de forma atómica (WriteBatch): crea la
  /// `guestAccount` con el cargo de alojamiento, marca la habitación
  /// `occupied` y la reserva `checked-in`.
  ///
  /// Lanza [BookingNotConfirmedException] si `booking.status != confirmed`,
  /// [RoomNotAvailableException] si la habitación no está disponible.
  /// Es idempotente: si ya existe una `guestAccount` para la reserva, no
  /// crea una segunda.
  Future<void> checkIn({required String bookingId, required String userId});

  /// Ejecuta el check-out de forma atómica (WriteBatch): marca la
  /// habitación `dirty` y la reserva `checked-out`.
  ///
  /// Lanza [BookingNotCheckedInException] si `booking.status != checked-in`,
  /// [GuestAccountNotFoundException] si no existe la cuenta, o
  /// [AccountBalancePendingException] si `guestAccount.balance != 0`.
  Future<void> checkOut({required String bookingId, required String userId});
}
