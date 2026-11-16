import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/health_repository.dart';
import '../../domain/server_health.dart';

/// What `GET /api/health` says about the API and its database.
class ServerStatusCard extends ConsumerWidget {
  const ServerStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FThemeData theme = context.theme;
    final AsyncValue<ServerHealth> health = ref.watch(serverHealthProvider);

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
                    'Server status',
                    style: theme.typography.display.md,
                  ),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  semanticsLabel: 'Check again',
                  onPress: () => ref.invalidate(serverHealthProvider),
                  child: const Icon(FLucideIcons.refreshCw),
                ),
              ],
            ),
            const SizedBox(height: 8),
            health.when(
              loading: () => const LoadingView(
                padding: EdgeInsets.symmetric(vertical: 32),
              ),
              error: (Object error, StackTrace _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _StatusLine(
                    label: 'Backend',
                    reachable: false,
                    value: 'Unreachable',
                  ),
                  const _StatusLine(
                    label: 'Database',
                    reachable: false,
                    value: 'Unknown',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error is ApiException
                        ? error.message
                        : 'The health check could not be completed.',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FButton(
                    variant: FButtonVariant.outline,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => ref.invalidate(serverHealthProvider),
                    prefix: const Icon(FLucideIcons.refreshCw),
                    child: const Text('Try again'),
                  ),
                ],
              ),
              data: (ServerHealth data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _StatusLine(
                    label: 'Backend',
                    reachable: data.serverUp,
                    value: data.serverUp ? 'Running' : data.status,
                  ),
                  _StatusLine(
                    label: 'Database',
                    reachable: data.databaseConnected,
                    value: data.databaseConnected
                        ? 'Connected'
                        : 'Disconnected',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConfig.apiBaseUrl,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.label,
    required this.reachable,
    required this.value,
  });

  final String label;
  final bool reachable;
  final String value;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
            reachable ? FLucideIcons.circleCheck : FLucideIcons.circleX,
            size: 20,
            color: reachable ? AppTheme.success : theme.colors.error,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.typography.body.md)),
          Text(
            value,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
