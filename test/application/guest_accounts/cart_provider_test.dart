import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/guest_accounts/cart_provider.dart';
import 'package:lequintmobile/domain/models/product.dart';

Product _product({
  required String id,
  double price = 10,
  double currentStock = 5,
}) {
  final now = DateTime(2026, 8, 14);
  return Product(
    id: id,
    code: 'CODE-$id',
    name: 'Producto $id',
    category: 'Bebidas',
    measurementUnit: 'unidad',
    currentStock: currentStock,
    minStock: 1,
    cost: price / 2,
    price: price,
    isActive: true,
    createdAt: now,
    updatedAt: now,
    createdBy: 'admin-1',
    updatedBy: 'admin-1',
  );
}

void main() {
  group('CartNotifier', () {
    test('addItem agrega el producto con cantidad 1', () {
      final notifier = CartNotifier();
      notifier.addItem(_product(id: 'p1'));

      expect(notifier.state.length, 1);
      expect(notifier.state.single.productId, 'p1');
      expect(notifier.state.single.quantity, 1);
    });

    test('addItem dos veces suma la cantidad en vez de duplicar', () {
      final notifier = CartNotifier();
      final product = _product(id: 'p1');
      notifier
        ..addItem(product)
        ..addItem(product);

      expect(notifier.state.length, 1);
      expect(notifier.state.single.quantity, 2);
    });

    test('addItem no agrega si currentStock es 0', () {
      final notifier = CartNotifier();
      notifier.addItem(_product(id: 'p1', currentStock: 0));

      expect(notifier.state, isEmpty);
    });

    test('updateQuantity respeta el stock máximo', () {
      final notifier = CartNotifier();
      final product = _product(id: 'p1', currentStock: 3);
      notifier.addItem(product);

      notifier.updateQuantity('p1', 10, maxStock: product.currentStock);

      expect(notifier.state.single.quantity, 3);
    });

    test('updateQuantity a 0 o menos quita el producto', () {
      final notifier = CartNotifier();
      notifier.addItem(_product(id: 'p1'));

      notifier.updateQuantity('p1', 0);

      expect(notifier.state, isEmpty);
    });

    test('removeItem quita el producto del carrito', () {
      final notifier = CartNotifier()
        ..addItem(_product(id: 'p1'))
        ..addItem(_product(id: 'p2'));

      notifier.removeItem('p1');

      expect(notifier.state.map((i) => i.productId), ['p2']);
    });

    test('clear vacía el carrito', () {
      final notifier = CartNotifier()..addItem(_product(id: 'p1'));

      notifier.clear();

      expect(notifier.state, isEmpty);
    });

    test('total suma unitPrice * quantity de cada ítem', () {
      final notifier = CartNotifier()
        ..addItem(_product(id: 'p1', price: 10))
        ..addItem(_product(id: 'p2', price: 5))
        ..addItem(_product(id: 'p2', price: 5));

      expect(notifier.total, 20); // 10*1 + 5*2
    });
  });
}
