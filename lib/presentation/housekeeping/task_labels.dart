import '../../domain/models/housekeeping_task.dart';

/// Labels en español para los enums de [HousekeepingTask] — ver SPEC-004.
extension TaskTypeLabel on TaskType {
  String get label => switch (this) {
    TaskType.cleaning => 'Limpieza',
    TaskType.deepCleaning => 'Limpieza profunda',
    TaskType.maintenance => 'Mantenimiento',
    TaskType.inspection => 'Inspección',
  };
}

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.pending => 'Pendiente',
    TaskStatus.inProgress => 'En progreso',
    TaskStatus.completed => 'Completada',
    TaskStatus.cancelled => 'Cancelada',
  };
}
