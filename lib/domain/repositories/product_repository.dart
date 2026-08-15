import '../models/product.dart';

/// Contrato de catálogo de productos — ver SPEC-011.
abstract interface class ProductRepository {
  /// Productos con `isActive == true` y `currentStock > 0`, para el
  /// catálogo de "Agregar Cargo".
  Stream<List<Product>> getActiveWithStock();
}
