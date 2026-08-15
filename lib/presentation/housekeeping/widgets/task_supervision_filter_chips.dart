import 'package:flutter/material.dart';

import '../../../application/housekeeping/housekeeping_provider.dart';
import '../../../core/constants/app_colors.dart';

const _filterLabels = {
  TaskSupervisionFilter.all: 'Todos',
  TaskSupervisionFilter.pending: 'Pendiente',
  TaskSupervisionFilter.inProgress: 'En progreso',
  TaskSupervisionFilter.completed: 'Completada',
  TaskSupervisionFilter.urgent: 'Urgentes',
};

/// Filtros de AllTasksScreen — ver TASK-016.
class TaskSupervisionFilterChips extends StatelessWidget {
  const TaskSupervisionFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final TaskSupervisionFilter selected;
  final ValueChanged<TaskSupervisionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final filter in TaskSupervisionFilter.values) ...[
            if (filter != TaskSupervisionFilter.values.first)
              const SizedBox(width: 8),
            _Chip(
              label: _filterLabels[filter]!,
              isSelected: selected == filter,
              isUrgent: filter == TaskSupervisionFilter.urgent,
              onTap: () => onChanged(filter),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.isUrgent,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isUrgent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isUrgent ? AppColors.priorityUrgent : AppColors.accentPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppColors.glassPrimary,
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : AppColors.glassPrimaryBorder,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
