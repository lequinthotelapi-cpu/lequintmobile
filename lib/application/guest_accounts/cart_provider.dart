import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product.dart';
import '../../domain/repositories/guest_account_repository.dart';

/// Carrito de AddChargeScreen — ver SPEC-011. Reutiliza [AddChargeItem]
/// (ya definido en el repositorio como el input de `addCharge`) en vez de
/// un `CartItem` propio: son el mismo dato, y así no hay que mapear entre
/// dos clases idénticas al confirmar.
class CartNotifier extends StateNotifier<List<AddChargeItem>> {
  CartNotifier() : super(const []);

  /// Suma 1 a la cantidad si el producto ya está en el carrito (respetando
  /// `product.currentStock`); si no, lo agrega con cantidad 1.
  void addItem(Product product) {
    final index = state.indexWhere((item) => item.productId == product.id);
    if (index == -1) {
      if (product.currentStock < 1) return;
      state = [
        ...state,
        AddChargeItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: 1,
        ),
      ];
      return;
    }
    updateQuantity(
      product.id,
      state[index].quantity + 1,
      maxStock: product.currentStock,
    );
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  /// [quantity] <= 0 quita el producto del carrito. Si [maxStock] se
  /// provee, la cantidad se recorta a ese máximo (SPEC-011 regla 3).
  void updateQuantity(String productId, int quantity, {double? maxStock}) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final clamped = maxStock != null && quantity > maxStock
        ? maxStock.floor()
        : quantity;
    if (clamped <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId)
          AddChargeItem(
            productId: item.productId,
            productName: item.productName,
            unitPrice: item.unitPrice,
            quantity: clamped,
          )
        else
          item,
    ];
  }

  void clear() => state = const [];

  double get total => state.fold<double>(0, (sum, item) => sum + item.subtotal);
}

final cartProvider =
    StateNotifierProvider.autoDispose<CartNotifier, List<AddChargeItem>>(
      (ref) => CartNotifier(),
    );
