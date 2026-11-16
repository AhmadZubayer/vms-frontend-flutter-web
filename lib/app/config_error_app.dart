import 'package:flutter/material.dart' show MaterialApp, ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../core/config/app_config.dart';
import 'theme.dart';

/// Shown instead of the app when the build was never told which API to call.
///
/// Without this the client would reach the sign-in screen and fail every
/// request for a reason nobody can see.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stark VMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.toApproximateMaterialTheme(),
      themeMode: ThemeMode.light,
      builder: (BuildContext context, Widget? child) =>
          FTheme(data: AppTheme.light, child: child!),
      home: Builder(
        builder: (BuildContext context) {
          final FThemeData theme = context.theme;

          return FScaffold(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Stark VMS is not configured',
                        style: theme.typography.display.xl2,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This build does not know which API to talk to, so it '
                        'cannot sign anyone in.',
                        style: theme.typography.body.md.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colors.muted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Text(
                          message,
                          style: theme.typography.body.sm,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Example: ${AppConfig.envFileName} holding '
                        'API_BASE_URL=https://api.example.com',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
