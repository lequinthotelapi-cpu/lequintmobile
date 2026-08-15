import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/housekeeping/housekeeping_provider.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';

HousekeepingTask _task({
  required String id,
  required TaskStatus status,
  required TaskPriority priority,
  DateTime? scheduledDate,
  DateTime? completedAt,
  String? assignedTo,
  String? assignedToName,
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
    completedAt: completedAt,
    assignedTo: assignedTo,
    assignedToName: assignedToName,
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

  group('countHousekeepingTasks', () {
    test('cuenta pendientes, en progreso, y completadas hoy', () {
      final tasks = [
        _task(id: '1', status: TaskStatus.pending, priority: TaskPriority.low),
        _task(id: '2', status: TaskStatus.pending, priority: TaskPriority.low),
        _task(
          id: '3',
          status: TaskStatus.inProgress,
          priority: TaskPriority.low,
        ),
        _task(
          id: '4',
          status: TaskStatus.completed,
          priority: TaskPriority.low,
          completedAt: DateTime.now(),
        ),
        _task(
          id: '5',
          status: TaskStatus.completed,
          priority: TaskPriority.low,
          completedAt: DateTime(2020),
        ),
        _task(
          id: '6',
          status: TaskStatus.cancelled,
          priority: TaskPriority.low,
        ),
      ];

      final counts = countHousekeepingTasks(tasks);

      expect(counts.pending, 2);
      expect(counts.inProgress, 1);
      expect(counts.completedToday, 1);
    });

    test('lista vacía da todos los conteos en 0', () {
      final counts = countHousekeepingTasks(const []);
      expect(counts.pending, 0);
      expect(counts.inProgress, 0);
      expect(counts.completedToday, 0);
    });
  });

  group('groupTasksByEmployee', () {
    test('agrupa por assignedTo y usa "unassigned" para las sin asignar', () {
      final tasks = [
        _task(
          id: '1',
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          assignedTo: 'emp-1',
        ),
        _task(
          id: '2',
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          assignedTo: 'emp-1',
        ),
        _task(
          id: '3',
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          assignedTo: 'emp-2',
        ),
        _task(id: '4', status: TaskStatus.pending, priority: TaskPriority.low),
      ];

      final grouped = groupTasksByEmployee(tasks);

      expect(grouped['emp-1']!.map((t) => t.id).toList(), ['1', '2']);
      expect(grouped['emp-2']!.map((t) => t.id).toList(), ['3']);
      expect(grouped['unassigned']!.map((t) => t.id).toList(), ['4']);
    });
  });

  group('isTaskOverdue', () {
    final now = DateTime(2026, 8, 14, 15);

    test('pending con scheduledDate en el pasado está vencida', () {
      final task = _task(
        id: '1',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
        scheduledDate: DateTime(2026, 8, 10),
      );
      expect(isTaskOverdue(task, now), isTrue);
    });

    test('in-progress con scheduledDate en el pasado está vencida', () {
      final task = _task(
        id: '1',
        status: TaskStatus.inProgress,
        priority: TaskPriority.normal,
        scheduledDate: DateTime(2026, 8, 10),
      );
      expect(isTaskOverdue(task, now), isTrue);
    });

    test('scheduledDate hoy no está vencida', () {
      final task = _task(
        id: '1',
        status: TaskStatus.pending,
        priority: TaskPriority.normal,
        scheduledDate: DateTime(2026, 8, 14, 8),
      );
      expect(isTaskOverdue(task, now), isFalse);
    });

    test('completed no está vencida aunque scheduledDate sea pasado', () {
      final task = _task(
        id: '1',
        status: TaskStatus.completed,
        priority: TaskPriority.normal,
        scheduledDate: DateTime(2026, 8, 10),
      );
      expect(isTaskOverdue(task, now), isFalse);
    });
  });

  group('countOverdueTasks', () {
    test('cuenta solo las vencidas', () {
      final now = DateTime(2026, 8, 14);
      final tasks = [
        _task(
          id: '1',
          status: TaskStatus.pending,
          priority: TaskPriority.normal,
          scheduledDate: DateTime(2026, 8, 10),
        ),
        _task(
          id: '2',
          status: TaskStatus.pending,
          priority: TaskPriority.normal,
          scheduledDate: DateTime(2026, 8, 14),
        ),
      ];

      expect(countOverdueTasks(tasks, now), 1);
    });
  });

  group('filterTasksForSupervision', () {
    final tasks = [
      _task(id: '1', status: TaskStatus.pending, priority: TaskPriority.low),
      _task(
        id: '2',
        status: TaskStatus.inProgress,
        priority: TaskPriority.normal,
      ),
      _task(
        id: '3',
        status: TaskStatus.completed,
        priority: TaskPriority.normal,
      ),
      _task(id: '4', status: TaskStatus.pending, priority: TaskPriority.urgent),
    ];

    test('all devuelve todas', () {
      expect(
        filterTasksForSupervision(tasks, TaskSupervisionFilter.all).length,
        4,
      );
    });

    test('pending filtra por status pending', () {
      final result = filterTasksForSupervision(
        tasks,
        TaskSupervisionFilter.pending,
      );
      expect(result.map((t) => t.id).toList(), ['1', '4']);
    });

    test('urgent filtra por prioridad, no por status', () {
      final result = filterTasksForSupervision(
        tasks,
        TaskSupervisionFilter.urgent,
      );
      expect(result.map((t) => t.id).toList(), ['4']);
    });

    test('completed filtra por status completed', () {
      final result = filterTasksForSupervision(
        tasks,
        TaskSupervisionFilter.completed,
      );
      expect(result.map((t) => t.id).toList(), ['3']);
    });
  });
}
