import '../models/housekeeping_task.dart';

/// Contrato de tareas de housekeeping — ver SPEC-004, SPEC-005.
abstract interface class HousekeepingRepository {
  /// Tareas asignadas a [employeeId] con `status in [pending, in-progress]`.
  Stream<List<HousekeepingTask>> getByEmployee(String employeeId);

  /// Todas las tareas (para manager/admin — supervisión).
  Stream<List<HousekeepingTask>> getAll();

  /// Marca la tarea `in-progress` y registra `startedAt`.
  ///
  /// Lanza [TaskNotFoundException], [TaskNotAssignedException] si
  /// `assignedTo != userId`, o [TaskInvalidStatusException] si
  /// `status != pending`.
  Future<void> startTask({required String taskId, required String userId});

  /// Completa la tarea de forma atómica (WriteBatch): actualiza la tarea,
  /// y la habitación pasa a `maintenance` (+ nueva tarea de mantenimiento)
  /// o `available` según [requiresMaintenance].
  ///
  /// Si la tarea está `pending`, la inicia automáticamente antes de
  /// completarla (igual que el sistema web). Lanza [TaskNotFoundException],
  /// [TaskNotAssignedException], o [TaskInvalidStatusException] si ya está
  /// `completed`/`cancelled`.
  Future<void> completeTask({
    required String taskId,
    required String userId,
    required int actualDuration,
    String? completionNotes,
    bool requiresMaintenance = false,
    String? maintenanceNotes,
  });
}
