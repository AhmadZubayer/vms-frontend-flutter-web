import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/platform/url_strategy.dart';

void main() {
  // Serves `/login` on the web instead of `/#/login`.
  applyPathUrlStrategy();

  runApp(const ProviderScope(child: StarkVmsApp()));
}
