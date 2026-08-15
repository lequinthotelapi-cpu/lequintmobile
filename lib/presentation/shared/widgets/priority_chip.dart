import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/housekeeping_task.dart';

/// Chip de prioridad de tarea — ver docs/ux/components.md "PriorityChip"
/// (misma especificación que StatusChip, con colores de prioridad).
class PriorityChip extends StatelessWidget {
  const PriorityChip({required this.priority, super.key});

  final TaskPriority priority;

  static Color colorFor(TaskPriority priority) => switch (priority) {
    TaskPriority.urgent => AppColors.priorityUrgent,
    TaskPriority.high => AppColors.priorityHigh,
    TaskPriority.normal => AppColors.priorityNormal,
    TaskPriority.low => AppColors.priorityLow,
  };

  static String labelFor(TaskPriority priority) => switch (priority) {
    TaskPriority.urgent => 'Urgente',
    TaskPriority.high => 'Alta',
    TaskPriority.normal => 'Normal',
    TaskPriority.low => 'Baja',
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(priority);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            labelFor(priority),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
