import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MaterialApp, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/auth_controller.dart';
import 'router.dart';
import 'theme.dart';

class StarkVmsApp extends ConsumerWidget {
  const StarkVmsApp({super.key});
  static const String title = 'Stark VMS';

  Widget _builder(BuildContext context, Widget? child) => FTheme(
    data: AppTheme.light,
    child: FToaster(child: FTooltipGroup(child: child!)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth is AuthRestoring) {
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light.toApproximateMaterialTheme(),
        themeMode: ThemeMode.light,
        builder: _builder,
        home: const _SplashPage(),
      );
    }
    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.toApproximateMaterialTheme(),
      themeMode: ThemeMode.light,
      builder: _builder,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) => FScaffold(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(StarkVmsApp.title, style: context.theme.typography.display.xl),
          const SizedBox(height: 20),
          const FCircularProgress(),
        ],
      ),
    ),
  );
}
