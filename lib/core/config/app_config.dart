/// Settings that change between environments.
class AppConfig {
  const AppConfig._();

  /// Base URL of the Stark VMS API.
  ///
  /// Override it at build time, for example
  /// `flutter run --dart-define=VMS_API_BASE_URL=http://10.0.2.2:8080`.
  static const String apiBaseUrl = String.fromEnvironment(
    'VMS_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Width at or above which the dashboard shows its permanent side menu.
  static const double wideLayoutBreakpoint = 1000;
}
