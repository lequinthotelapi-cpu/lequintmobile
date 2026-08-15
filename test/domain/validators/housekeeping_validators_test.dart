import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/errors/app_exception.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/domain/validators/housekeeping_validators.dart';

const _currentUserId = 'user-1';

HousekeepingTask _task({
  required TaskStatus status,
  String? assignedTo = _currentUserId,
}) {
  final now = DateTime(2026, 8, 14);
  return HousekeepingTask(
    id: 'task-1',
    roomId: 'room-1',
    roomNumber: '101',
    floor: 1,
    assignedTo: assignedTo,
    taskType: TaskType.cleaning,
    status: status,
    priority: TaskPriority.normal,
    scheduledDate: now,
    estimatedDuration: 30,
    createdAt: now,
    createdBy: 'admin-1',
    updatedAt: now,
    updatedBy: 'admin-1',
  );
}

void main() {
  group('validateStartTask', () {
    test('no lanza si la tarea está pending y asignada al usuario', () {
      expect(
        () => validateStartTask(
          task: _task(status: TaskStatus.pending),
          userId: _currentUserId,
        ),
        returnsNormally,
      );
    });

    test('lanza TaskNotAssignedException si no está asignada al usuario', () {
      expect(
        () => validateStartTask(
          task: _task(status: TaskStatus.pending, assignedTo: 'otro-user'),
          userId: _currentUserId,
        ),
        throwsA(isA<TaskNotAssignedException>()),
      );
    });

    test('lanza TaskInvalidStatusException si la tarea no está pending', () {
      expect(
        () => validateStartTask(
          task: _task(status: TaskStatus.inProgress),
          userId: _currentUserId,
        ),
        throwsA(isA<TaskInvalidStatusException>()),
      );
    });
  });

  group('validateCompleteTask', () {
    test('no lanza si la tarea está in-progress, asignada, y duración > 0', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.inProgress),
          userId: _currentUserId,
          actualDuration: 30,
        ),
        returnsNormally,
      );
    });

    test('no lanza si la tarea está pending (se inicia automáticamente)', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.pending),
          userId: _currentUserId,
          actualDuration: 30,
        ),
        returnsNormally,
      );
    });

    test('lanza InvalidInputException si la duración es 0', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.inProgress),
          userId: _currentUserId,
          actualDuration: 0,
        ),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('lanza TaskNotAssignedException si no está asignada al usuario', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.inProgress, assignedTo: 'otro-user'),
          userId: _currentUserId,
          actualDuration: 30,
        ),
        throwsA(isA<TaskNotAssignedException>()),
      );
    });

    test('lanza TaskInvalidStatusException si la tarea ya fue completada', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.completed),
          userId: _currentUserId,
          actualDuration: 30,
        ),
        throwsA(isA<TaskInvalidStatusException>()),
      );
    });

    test('lanza TaskInvalidStatusException si la tarea fue cancelada', () {
      expect(
        () => validateCompleteTask(
          task: _task(status: TaskStatus.cancelled),
          userId: _currentUserId,
          actualDuration: 30,
        ),
        throwsA(isA<TaskInvalidStatusException>()),
      );
    });
  });
}
