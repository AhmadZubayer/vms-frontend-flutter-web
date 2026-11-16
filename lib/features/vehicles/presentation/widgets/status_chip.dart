import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import '../../../../app/theme.dart';

/// Vehicle status with a green indicator for active vehicles.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final bool active = label.toUpperCase() == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.successContainer
            : theme.colors.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.border),
      ),
      child: Text(
        label,
        style: theme.typography.body.sm.copyWith(
          color: active ? AppTheme.success : theme.colors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
