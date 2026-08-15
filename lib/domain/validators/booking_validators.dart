import '../../core/errors/app_exception.dart';
import '../models/booking.dart';
import '../models/guest_account.dart';
import '../models/room.dart';

/// Valida las precondiciones de check-in (SPEC-006). Lanza [AppException]
/// si no se cumplen; no hace nada si son válidas.
void validateCheckIn({required Booking booking, required Room room}) {
  if (booking.status != BookingStatus.confirmed) {
    throw const BookingNotConfirmedException();
  }
  if (room.status != RoomStatus.available) {
    throw const RoomNotAvailableException();
  }
}

/// Valida las precondiciones de check-out (SPEC-007): reserva con check-in
/// activo, cuenta existente, y saldo exactamente en 0.
void validateCheckOut({
  required Booking booking,
  required GuestAccount? account,
}) {
  if (booking.status != BookingStatus.checkedIn) {
    throw const BookingNotCheckedInException();
  }
  if (account == null) {
    throw const GuestAccountNotFoundException();
  }
  if (account.balance != 0) {
    throw AccountBalancePendingException(
      'El huésped tiene saldo pendiente de '
      '\$${account.balance.toStringAsFixed(2)}. Debe saldar la cuenta '
      'antes del check-out.',
    );
  }
}
