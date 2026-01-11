/// App-wide configuration values.
///
/// Use `--dart-define=API_BASE_URL=https://...` to provide a backend base URL.
class AppConfig {
  /// Base URL of your custom backend (JWT/REST). Leave empty to disable.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
