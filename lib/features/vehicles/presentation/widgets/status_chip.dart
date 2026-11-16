import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../../app/theme.dart';

/// Status of a vehicle as a single-line badge: a quiet tint for the live
/// status, neutral for the rest.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;
    final bool active = label.toUpperCase() == 'ACTIVE';

    final Color background = active
        ? AppTheme.successContainer
        : theme.colors.muted;
    final Color foreground = active
        ? AppTheme.success
        : theme.colors.mutedForeground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.body.xs.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
