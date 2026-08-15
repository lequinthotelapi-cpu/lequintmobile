import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';

/// Rectángulo con animación shimmer — ver docs/ux/components.md
/// "LoadingState / Skeleton".
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({required this.height, this.radius = 12, super.key});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.glassPrimary,
      highlightColor: AppColors.glassPrimaryBorder,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.glassPrimary,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// N [SkeletonCard] apiladas con el espaciado estándar entre cards
/// (`cardGap` — ver docs/ux/design-tokens.md).
class SkeletonList extends StatelessWidget {
  const SkeletonList({required this.count, this.itemHeight = 80, super.key});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          SkeletonCard(height: itemHeight),
        ],
      ],
    );
  }
}

/// Overlay semitransparente con spinner sobre [child] — para operaciones
/// como check-in/check-out/completar tarea.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
