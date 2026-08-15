import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'glass_card.dart';

/// Card de indicador clave (número + label) — ver docs/ux/components.md
/// "KPICard".
class KPICard extends StatelessWidget {
  const KPICard({
    required this.value,
    required this.label,
    this.icon,
    this.color,
    super.key,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color ?? AppColors.textTertiary),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grilla de 2 columnas para [KPICard] con alto intrínseco (cada fila mide
/// lo que su contenido necesita) — a diferencia de `GridView.count` con
/// `childAspectRatio`, que impone una altura fija y desborda en pantallas
/// angostas cuando el contenido (ej. montos largos) no entra en esa altura.
class KPIGrid extends StatelessWidget {
  const KPIGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
