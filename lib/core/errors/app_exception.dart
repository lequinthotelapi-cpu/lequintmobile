/// Excepciones tipadas de la app — ver docs/architecture/architecture.md
/// sección 11. Todas cargan un mensaje en español listo para mostrar al
/// usuario final (SnackBar / Dialog), tal como piden las SPECs.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

// --- Auth (SPEC-001) ---

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([
    super.message = 'Correo o contraseña incorrectos',
  ]);
}

final class UserInactiveException extends AppException {
  const UserInactiveException([
    super.message = 'Tu cuenta está inactiva. Contacta al administrador.',
  ]);
}

final class UserExpiredException extends AppException {
  const UserExpiredException([
    super.message = 'Tu cuenta ha expirado. Contacta al administrador.',
  ]);
}

final class MaxSessionsException extends AppException {
  const MaxSessionsException([
    super.message =
        'Límite de sesiones alcanzado. Cierra otra sesión e intenta nuevamente.',
  ]);
}

// --- Red ---

final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Sin conexión. Verifica tu red e intenta nuevamente.',
  ]);
}

final class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'La operación tardó demasiado. Intenta nuevamente.',
  ]);
}

// --- Reservas / check-in / check-out (SPEC-006, SPEC-007) ---

final class BookingNotConfirmedException extends AppException {
  const BookingNotConfirmedException([
    super.message = 'La reserva debe estar confirmada para hacer check-in',
  ]);
}

final class BookingNotCheckedInException extends AppException {
  const BookingNotCheckedInException([
    super.message = 'Esta reserva no tiene check-in activo',
  ]);
}

final class RoomNotAvailableException extends AppException {
  const RoomNotAvailableException([
    super.message = 'La habitación no está disponible',
  ]);
}

// --- Cuenta de huésped (SPEC-011) ---

final class AccountBalancePendingException extends AppException {
  const AccountBalancePendingException(super.message);
}

final class GuestAccountNotFoundException extends AppException {
  const GuestAccountNotFoundException([
    super.message = 'No se encontró la cuenta del huésped',
  ]);
}

final class GuestAccountClosedException extends AppException {
  const GuestAccountClosedException([
    super.message = 'Esta cuenta ya está cerrada',
  ]);
}

final class InsufficientStockException extends AppException {
  const InsufficientStockException(super.message);
}

// --- Housekeeping (SPEC-004, SPEC-005) ---

final class TaskNotFoundException extends AppException {
  const TaskNotFoundException([super.message = 'No se encontró la tarea']);
}

final class TaskNotAssignedException extends AppException {
  const TaskNotAssignedException([
    super.message = 'No tienes permiso para modificar esta tarea',
  ]);
}

final class TaskInvalidStatusException extends AppException {
  const TaskInvalidStatusException(super.message);
}

// --- Validación de entrada ---

/// Datos inválidos provistos por el usuario (ej. duración <= 0), detectados
/// como última línea de defensa en el repositorio — la UI ya debería
/// impedir el envío antes de llegar aquí.
final class InvalidInputException extends AppException {
  const InvalidInputException(super.message);
}

// --- Genérico ---

final class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Ocurrió un error. Intenta nuevamente.',
  ]);
}
