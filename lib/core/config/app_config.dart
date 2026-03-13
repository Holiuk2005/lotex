/// Параметри конфігурації для всього додатка.
///
/// Використовуйте `--dart-define=API_BASE_URL=https://...`, щоб вказати базову URL-адресу серверної частини.
class AppConfig {
  /// Базова URL-адреса вашого власного серверного модуля (JWT/REST). Залиште поле порожнім, щоб вимкнути цю функцію.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Публічний ключ Stripe (лише для мобільних пристроїв, для веб-версії не налаштовано).
  /// Вкажіть за допомогою: --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Ім'я, що відображається в PaymentSheet.
  /// Вказати за допомогою: --dart-define=STRIPE_MERCHANT_DISPLAY_NAME=«Lotex»
  static const String stripeMerchantDisplayName = String.fromEnvironment(
    'STRIPE_MERCHANT_DISPLAY_NAME',
    defaultValue: 'Lotex',
  );

  /// Прапор тестового середовища Google Pay.
  /// Вказується за допомогою: --dart-define=STRIPE_GOOGLE_PAY_TEST_ENV=true|false
  static const bool stripeGooglePayTestEnv = bool.fromEnvironment(
    'STRIPE_GOOGLE_PAY_TEST_ENV',
    defaultValue: true,
  );
}
