import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/guest_account.dart';
import '../../domain/repositories/guest_account_repository.dart';
import '../../infrastructure/firebase/guest_account_firebase_repository.dart';

final guestAccountRepositoryProvider = Provider<GuestAccountRepository>((ref) {
  return GuestAccountFirebaseRepository();
});

/// Cuentas abiertas — usado por el dashboard (TASK-007) para el contador
/// "Cuentas abiertas".
final openGuestAccountsProvider =
    StreamProvider.autoDispose<List<GuestAccount>>(
      (ref) => ref.watch(guestAccountRepositoryProvider).getOpenAccounts(),
    );

/// Cuenta de huésped asociada a una reserva — usado por DepartureDetailScreen
/// (SPEC-007) para verificar el saldo antes del check-out.
final guestAccountByBookingProvider = FutureProvider.autoDispose
    .family<GuestAccount?, String>((ref, bookingId) {
      return ref.watch(guestAccountRepositoryProvider).getByBooking(bookingId);
    });

/// Cuenta de huésped por id — usado por GuestAccountScreen (TASK-014).
/// `getById` es `Future` (no `Stream`, a diferencia del sketch de
/// TASK-014): pull-to-refresh invalida este provider para actualizar.
final guestAccountProvider = FutureProvider.autoDispose
    .family<GuestAccount?, String>((ref, accountId) {
      return ref.watch(guestAccountRepositoryProvider).getById(accountId);
    });
