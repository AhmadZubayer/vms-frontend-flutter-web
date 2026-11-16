import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'widgets/server_status_card.dart';
import 'widgets/vehicle_totals_card.dart';

/// Landing page of the dashboard: registry totals beside the server status.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  /// Below this width the two cards stack instead of sitting side by side.
  static const double _twoColumnBreakpoint = 820;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= _twoColumnBreakpoint;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Dashboard', style: theme.typography.display.xl2),
              const SizedBox(height: 4),
              Text(
                'Registry totals and the state of the backend.',
                style: theme.typography.body.md.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              if (twoColumns)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: VehicleTotalsCard()),
                    SizedBox(width: 24),
                    Expanded(flex: 2, child: ServerStatusCard()),
                  ],
                )
              else
                const Column(
                  children: <Widget>[
                    VehicleTotalsCard(),
                    SizedBox(height: 16),
                    ServerStatusCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
