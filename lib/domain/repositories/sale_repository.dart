import '../models/sale.dart';

/// Contrato mínimo de ventas POS — ver SPEC-010. El módulo POS completo
/// (crear ventas, carrito, caja) está fuera del alcance del MVP móvil; solo
/// se necesita lectura para el cálculo de ingresos del dashboard
/// (TASK-007/TASK-013).
abstract interface class SaleRepository {
  /// Ventas creadas dentro de `[start, end]`, ambos inclusive.
  Future<List<Sale>> getByDateRange(DateTime start, DateTime end);
}
