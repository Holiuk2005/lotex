/// App-wide configuration values.
///
/// Use `--dart-define=API_BASE_URL=https://...` to provide a backend base URL.
class AppConfig {
  /// Base URL of your custom backend (JWT/REST). Leave empty to disable.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Stripe publishable key (mobile only, web not configured).
  /// Provide via: --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Display name shown in PaymentSheet.
  /// Provide via: --dart-define=STRIPE_MERCHANT_DISPLAY_NAME="Lotex"
  static const String stripeMerchantDisplayName = String.fromEnvironment(
    'STRIPE_MERCHANT_DISPLAY_NAME',
    defaultValue: 'Lotex',
  );

  /// Google Pay test environment flag.
  /// Provide via: --dart-define=STRIPE_GOOGLE_PAY_TEST_ENV=true|false
  static const bool stripeGooglePayTestEnv = bool.fromEnvironment(
    'STRIPE_GOOGLE_PAY_TEST_ENV',
    defaultValue: true,
  );
}
