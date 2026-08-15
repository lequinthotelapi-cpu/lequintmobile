import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'arrivals_screen.dart';
import 'departures_screen.dart';
import 'in_house_screen.dart';

/// Contenedor con tabs de Recepción (admin/superadmin) — ver
/// docs/ux/navigation.md: Llegadas / Salidas / En Casa. Sin SPEC propia
/// (TASK-005 ya lo documentaba así); reutiliza las 3 pantallas ya
/// construidas por SPEC-006/SPEC-007/SPEC-011 sin duplicar su contenido.
class FrontDeskScreen extends StatelessWidget {
  const FrontDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientTop,
              AppColors.backgroundGradientBottom,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Recepción',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            bottom: const TabBar(
              indicatorColor: AppColors.accentPrimary,
              labelColor: AppColors.accentPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'Llegadas'),
                Tab(text: 'Salidas'),
                Tab(text: 'En Casa'),
              ],
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                ArrivalsScreen(embedded: true),
                DeparturesScreen(embedded: true),
                InHouseScreen(embedded: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
