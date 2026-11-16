import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/platform/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The API URL comes from .env, so the same build can be pointed anywhere.
  await AppConfig.load();

  // Serves `/login` on the web instead of `/#/login`.
  applyPathUrlStrategy();

  runApp(const ProviderScope(child: StarkVmsApp()));
}
