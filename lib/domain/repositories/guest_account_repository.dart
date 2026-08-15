import '../models/guest_account.dart';

/// Un producto seleccionado en el carrito de "Agregar Cargo" — ver
/// SPEC-011. No es un modelo persistido, solo el input de [addCharge].
class AddChargeItem {
  const AddChargeItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;
}

/// Contrato de cuentas de huésped — ver SPEC-011.
abstract interface class GuestAccountRepository {
  Future<GuestAccount?> getById(String accountId);

  Future<GuestAccount?> getByBooking(String bookingId);

  /// Cuentas con `status == open` (para dashboard/listados).
  Stream<List<GuestAccount>> getOpenAccounts();

  /// Agrega un cargo tipo `pos` de forma atómica (WriteBatch): añade el
  /// cargo a `guestAccount.charges`, recalcula subtotal/tax/total/balance,
  /// y decrementa `product.currentStock` por cada producto en [items].
  ///
  /// Lanza [GuestAccountNotFoundException], [GuestAccountClosedException]
  /// si `status != open`, o [InsufficientStockException] si algún producto
  /// no tiene stock suficiente.
  Future<void> addCharge({
    required String accountId,
    required List<AddChargeItem> items,
    required String userId,
  });
}
