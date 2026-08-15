import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';

HousekeepingTask _task({
  required String id,
  required TaskStatus status,
  required TaskPriority priority,
  DateTime? scheduledDate,
}) {
  final now = scheduledDate ?? DateTime(2026, 8, 14);
  return HousekeepingTask(
    id: id,
    roomId: 'room-$id',
    roomNumber: id,
    floor: 1,
    taskType: TaskType.cleaning,
    status: status,
    priority: priority,
    scheduledDate: now,
    estimatedDuration: 30,
    createdAt: now,
    createdBy: 'admin-1',
    updatedAt: now,
    updatedBy: 'admin-1',
  );
}

void main() {
  group('sortTasksForDisplay', () {
    test('las tareas in-progress aparecen antes que las pending', () {
      final pending = _task(
        id: '1',
        status: TaskStatus.pending,
        priority: TaskPriority.urgent,
      );
      final inProgress = _task(
        id: '2',
        status: TaskStatus.inProgress,
        priority: TaskPriority.low,
      );

      final sorted = sortTasksForDisplay([pending, inProgress]);

      expect(sorted.first.id, '2');
      expect(sorted.last.id, '1');
    });

    test('dentro de pending, ordena urgent > high > normal > low', () {
      final low = _task(
        id: 'low',
        status: TaskStatus.pending,
        priority: TaskPriority.low,
      );
      final urgent = _task(
        id: 'urgent',
        status: TaskStatus.pending,
        priority: TaskPriority.urgent,
      );
      final normal = _task(
        id: 'normal',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
      );
      final high = _task(
        id: 'high',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
      );

      final sorted = sortTasksForDisplay([low, urgent, normal, high]);

      expect(sorted.map((t) => t.id).toList(), [
        'urgent',
        'high',
        'normal',
        'low',
      ]);
    });

    test(
      'dentro de la misma prioridad, ordena por scheduledDate ascendente',
      () {
        final later = _task(
          id: 'later',
          status: TaskStatus.pending,
          priority: TaskPriority.normal,
          scheduledDate: DateTime(2026, 8, 15),
        );
        final earlier = _task(
          id: 'earlier',
          status: TaskStatus.pending,
          priority: TaskPriority.normal,
          scheduledDate: DateTime(2026, 8, 14),
        );

        final sorted = sortTasksForDisplay([later, earlier]);

        expect(sorted.map((t) => t.id).toList(), ['earlier', 'later']);
      },
    );
  });

  group('findTaskById', () {
    test('devuelve la tarea con el id correspondiente', () {
      final a = _task(
        id: 'a',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
      );
      final b = _task(
        id: 'b',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
      );

      expect(findTaskById([a, b], 'b'), b);
    });

    test('devuelve null si no existe', () {
      final a = _task(
        id: 'a',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
      );

      expect(findTaskById([a], 'missing'), isNull);
    });
  });
}
