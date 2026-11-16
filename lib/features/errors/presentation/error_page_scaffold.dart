import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Shared frame for the error routes: one icon, a headline, an explanation,
/// and the way out.
class ErrorPageScaffold extends StatelessWidget {
  const ErrorPageScaffold({
    super.key,
    required this.icon,
    required this.code,
    required this.title,
    required this.message,
    required this.actions,
  });

  final IconData icon;
  final String code;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: <Widget>[
                  Icon(icon, size: 40, color: theme.colors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(
                    code,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.typography.display.xl2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.base.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
