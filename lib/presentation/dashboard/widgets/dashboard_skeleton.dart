import 'package:flutter/material.dart';

import '../../shared/widgets/loading_widget.dart';

/// Skeleton compartido por los 4 dashboards mientras cargan sus datos —
/// ver SPEC-003 "Estados de pantalla".
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: SkeletonList(count: 4, itemHeight: 100),
    );
  }
}
