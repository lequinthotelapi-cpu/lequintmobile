import '../models/room.dart';

/// Contrato de acceso a habitaciones — ver SPEC-008.
abstract interface class RoomRepository {
  /// Stream de todas las habitaciones (todos los roles ven todas —
  /// DECISION-016). El cálculo de `displayStatus` (RoomWithStatus) vive en
  /// la capa de aplicación, combinando este stream con el de reservas.
  Stream<List<Room>> getAll();
}
