import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config_error_app.dart';
import 'core/config/app_config.dart';
import 'core/platform/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The API URL comes from app_config.env, so one build fits any host.
  await AppConfig.load();

  // Serves `/login` on the web instead of `/#/login`.
  applyPathUrlStrategy();

  // Say so plainly rather than starting an app that cannot reach anything.
  if (!AppConfig.isConfigured) {
    runApp(ConfigErrorApp(message: AppConfig.missingConfigMessage));
    return;
  }

  runApp(const ProviderScope(child: StarkVmsApp()));
}
