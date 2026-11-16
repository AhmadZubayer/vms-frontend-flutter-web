import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Settings that change between environments.
///
/// Everything environment-specific is read from the bundled `.env` file at
/// start-up, so no URL is written into the Dart code. A `--dart-define` of the
/// same name wins over the file, which is handy in CI.
class AppConfig {
  const AppConfig._();

  /// Name of the file loaded by [load].
  static const String envFileName = '.env';

  static const String _apiBaseUrlKey = 'API_BASE_URL';
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    _apiBaseUrlKey,
  );

  /// Reads `.env`. Call this before the first request, from `main`.
  ///
  /// A missing file is not fatal on its own: a build may pass the values
  /// with `--dart-define` instead, and [apiBaseUrl] reports what is missing.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: envFileName);
    } on Object {
      // Leave the map empty; apiBaseUrl explains what to set.
      dotenv.loadFromString(envString: '');
    }
  }

  /// Base URL of the Stark VMS API, without a trailing slash.
  static String get apiBaseUrl {
    final String value = _read(_apiBaseUrlKey, _apiBaseUrlDefine);
    if (value.isEmpty) {
      throw StateError(
        'Set $_apiBaseUrlKey in $envFileName (see .env.example), or pass '
        '--dart-define=$_apiBaseUrlKey=<url> when building.',
      );
    }
    return value.endsWith('/')
        ? value.substring(0, value.length - 1)
        : value;
  }

  static String _read(String key, String define) {
    if (define.isNotEmpty) {
      return define;
    }
    return (dotenv.isInitialized ? dotenv.maybeGet(key) : null)?.trim() ?? '';
  }

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Width at or above which the dashboard shows its permanent side menu.
  static const double wideLayoutBreakpoint = 1000;

  /// Share of a desktop window the right-hand side sheet covers.
  static const double sideSheetWidthRatio = 0.4;
  static const double sideSheetMinWidth = 400;
  static const double sideSheetMaxWidth = 720;
}
