import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Centred spinner for a section that is still loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.padding = const EdgeInsets.all(32)});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Center(child: FCircularProgress()),
    );
  }
}

/// A failure the person can retry, with the reason spelled out.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            FLucideIcons.circleAlert,
            size: 32,
            color: theme.colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.typography.body.base,
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 16),
            FButton(variant: FButtonVariant.outline, mainAxisSize: MainAxisSize.min,
              onPress: onRetry,
              prefix: const Icon(FLucideIcons.refreshCw),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Nothing to show yet, with the reason spelled out.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon ?? FLucideIcons.inbox,
            size: 32,
            color: theme.colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.typography.body.base.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
