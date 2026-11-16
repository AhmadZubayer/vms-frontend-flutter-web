import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../vehicles/domain/vehicle_stats.dart';
import '../../../vehicles/domain/vehicle_status.dart';
import '../../../vehicles/presentation/vehicles_controller.dart';

/// Total vehicles registered, and how many sit in each status.
class VehicleTotalsCard extends ConsumerWidget {
  const VehicleTotalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FThemeData theme = context.theme;
    final AsyncValue<VehicleStats> stats = ref.watch(vehicleStatsProvider);

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Total vehicles',
                    style: theme.typography.display.md,
                  ),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  semanticsLabel: 'Refresh',
                  onPress: () => ref.invalidate(vehicleStatsProvider),
                  child: const Icon(FLucideIcons.refreshCw),
                ),
              ],
            ),
            const SizedBox(height: 4),
            stats.when(
              loading: () => const LoadingView(
                padding: EdgeInsets.symmetric(vertical: 48),
              ),
              error: (Object error, StackTrace _) => ErrorView(
                message: error is ApiException
                    ? error.message
                    : 'The registry totals could not be read.',
                onRetry: () => ref.invalidate(vehicleStatsProvider),
              ),
              data: (VehicleStats data) => _Totals(stats: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.stats});

  final VehicleStats stats;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${stats.total}',
          style: theme.typography.display.xl4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          stats.total == 1
              ? 'vehicle in the registry'
              : 'vehicles in the registry',
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 20),
        const FDivider(),
        const SizedBox(height: 16),
        Text('By status', style: theme.typography.display.sm),
        const SizedBox(height: 12),
        for (final VehicleStatus status in VehicleStatus.values)
          _StatusRow(
            label: status.label,
            count: stats.countOf(status),
            total: stats.total,
          ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final double share = total == 0 ? 0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: theme.typography.body.md)),
              Text(
                '$count',
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FDeterminateProgress(value: share),
          ),
        ],
      ),
    );
  }
}
