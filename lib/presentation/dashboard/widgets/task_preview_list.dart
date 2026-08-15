import 'package:flutter/material.dart';

import '../../../domain/models/housekeeping_task.dart';
import '../../housekeeping/widgets/task_card.dart';

/// Primeras 5 tareas del housekeeper, ya ordenadas por
/// `sortTasksForDisplay` — ver SPEC-003 (dashboard housekeeper). Reutiliza
/// [TaskCard] (MyTasksScreen, TASK-004) — misma tarjeta, sin duplicarla.
class TaskPreviewList extends StatelessWidget {
  const TaskPreviewList({
    required this.tasks,
    required this.onTaskTap,
    super.key,
  });

  final List<HousekeepingTask> tasks;
  final void Function(HousekeepingTask task) onTaskTap;

  @override
  Widget build(BuildContext context) {
    final preview = tasks.take(5).toList();
    return Column(
      children: [
        for (final task in preview) ...[
          TaskCard(task: task, onTap: () => onTaskTap(task)),
          if (task != preview.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
