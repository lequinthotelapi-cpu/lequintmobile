import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum _GlassCardVariant { normal, elevated, subtle }

const _shadowCard = [
  BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
  BoxShadow(
    color: Color(0x0DFFFFFF),
    blurRadius: 1,
    offset: Offset(0, 1),
    spreadRadius: -1,
  ),
];

/// Card base con efecto glass — ver docs/ux/components.md "GlassCard".
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : _variant = _GlassCardVariant.normal;

  const GlassCard.elevated({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : _variant = _GlassCardVariant.elevated;

  const GlassCard.subtle({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : _variant = _GlassCardVariant.subtle;

  final Widget child;
  final EdgeInsets padding;
  final _GlassCardVariant _variant;

  @override
  Widget build(BuildContext context) {
    final isSubtle = _variant == _GlassCardVariant.subtle;
    final background = isSubtle
        ? AppColors.glassSecondary
        : AppColors.glassPrimary;
    final border = isSubtle
        ? AppColors.glassSecondaryBorder
        : AppColors.glassPrimaryBorder;
    final blur = _variant == _GlassCardVariant.elevated
        ? AppColors.blurElevated
        : AppColors.blurPrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _shadowCard,
          ),
          child: child,
        ),
      ),
    );
  }
}
