import '../../core/errors/app_exception.dart';
import '../models/housekeeping_task.dart';

/// Valida las precondiciones para iniciar una tarea (SPEC-005): asignada al
/// usuario actual y en estado `pending`.
void validateStartTask({
  required HousekeepingTask task,
  required String userId,
}) {
  if (task.assignedTo != userId) {
    throw const TaskNotAssignedException();
  }
  if (task.status != TaskStatus.pending) {
    throw const TaskInvalidStatusException(
      'Solo se pueden iniciar tareas pendientes',
    );
  }
}

/// Valida las precondiciones para completar una tarea (SPEC-005): asignada
/// al usuario actual, no completada/cancelada, y duración real > 0.
///
/// Una tarea `pending` es válida (SPEC-005 regla 3: se inicia
/// automáticamente antes de completarla).
void validateCompleteTask({
  required HousekeepingTask task,
  required String userId,
  required int actualDuration,
}) {
  if (actualDuration <= 0) {
    throw const InvalidInputException('La duración debe ser mayor a 0');
  }
  if (task.assignedTo != userId) {
    throw const TaskNotAssignedException();
  }
  switch (task.status) {
    case TaskStatus.completed:
      throw const TaskInvalidStatusException('Esta tarea ya fue completada');
    case TaskStatus.cancelled:
      throw const TaskInvalidStatusException('Esta tarea fue cancelada');
    case TaskStatus.pending:
    case TaskStatus.inProgress:
      break;
  }
}
