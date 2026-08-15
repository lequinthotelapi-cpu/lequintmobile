import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../room_status_display.dart';

/// Chips de filtro por estado, scroll horizontal — ver SPEC-008.
class RoomStatusFilterChips extends StatelessWidget {
  const RoomStatusFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Todos',
            isSelected: selected == null,
            color: AppColors.accentPrimary,
            onTap: () => onChanged(null),
          ),
          for (final status in roomStatusFilters) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: roomStatusVisuals(status).label,
              isSelected: selected == status,
              color: roomStatusVisuals(status).color,
              onTap: () => onChanged(status),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
