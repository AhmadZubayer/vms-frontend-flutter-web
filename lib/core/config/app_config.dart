import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Settings that change between environments.
///
/// Everything environment-specific is read from the bundled `app_config.env`
/// file at start-up, so no URL is in the Dart code. A `--dart-define` of the
/// same name wins over the file, which is handy in CI.
class AppConfig {
  const AppConfig._();

  /// Name of the file loaded by [load].
  ///
  /// Deliberately not a dotfile: Netlify and other static hosts refuse to
  /// publish files whose name starts with a dot, which would leave a deployed
  /// build with no configuration at all.
  static const String envFileName = 'app_config.env';

  static const String _apiBaseUrlKey = 'API_BASE_URL';
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    _apiBaseUrlKey,
  );

  /// Reads [envFileName]. Call this before the first request, from `main`.
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

  /// Whether an API URL was supplied, by the file or by `--dart-define`.
  static bool get isConfigured => _read(_apiBaseUrlKey, _apiBaseUrlDefine).isNotEmpty;

  /// What to tell someone looking at a build that was never pointed anywhere.
  static String get missingConfigMessage =>
      'Set $_apiBaseUrlKey in $envFileName (see $envFileName.example), or pass '
      '--dart-define=$_apiBaseUrlKey=<url> when building. In a published web '
      'build the file is assets/$envFileName.';

  /// Base URL of the Stark VMS API, without a trailing slash.
  static String get apiBaseUrl {
    final String value = _read(_apiBaseUrlKey, _apiBaseUrlDefine);
    if (value.isEmpty) {
      throw StateError(missingConfigMessage);
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
