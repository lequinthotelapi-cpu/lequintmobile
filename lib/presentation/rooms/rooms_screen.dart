import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/rooms/rooms_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'room_status_display.dart';
import 'widgets/room_grid_card.dart';
import 'widgets/room_list_tile.dart';
import 'widgets/room_status_filter_chips.dart';

/// Estado de habitaciones — ver SPEC-008. Todos los roles ven todas las
/// habitaciones (DECISION-016).
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsWithStatusProvider);
    final filter = ref.watch(roomStatusFilterProvider);

    return DecoratedBox(
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
            'Habitaciones',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list_outlined : Icons.grid_view,
                color: AppColors.textPrimary,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              roomsAsync.maybeWhen(
                data: (rooms) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    '${rooms.length} habitaciones · '
                    '${rooms.where((r) => r.displayStatus == 'occupied').length} ocupadas',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoomStatusFilterChips(
                  selected: filter,
                  onChanged: (value) =>
                      ref.read(roomStatusFilterProvider.notifier).state = value,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: roomsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SkeletonList(count: 4, itemHeight: 90),
                  ),
                  error: (error, stackTrace) => ErrorState(
                    message: 'No se pudieron cargar las habitaciones',
                    onRetry: () => ref.invalidate(roomsWithStatusProvider),
                  ),
                  data: (rooms) {
                    if (rooms.isEmpty) {
                      return const EmptyState(
                        icon: Icons.bed_outlined,
                        title: 'No hay habitaciones registradas',
                      );
                    }
                    final filtered = filter == null
                        ? rooms
                        : rooms
                              .where((r) => r.displayStatus == filter)
                              .toList();
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off,
                        title:
                            'No hay habitaciones con estado '
                            '${roomStatusVisuals(filter!).label.toLowerCase()}',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(roomsWithStatusProvider),
                      child: _isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final room = filtered[index];
                                return RoomGridCard(
                                  room: room,
                                  onTap: () => context.push(
                                    AppRoutes.roomDetailPath(room.id),
                                  ),
                                );
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final room = filtered[index];
                                return RoomListTile(
                                  room: room,
                                  onTap: () => context.push(
                                    AppRoutes.roomDetailPath(room.id),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
