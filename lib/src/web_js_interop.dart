// Web-only JS interop bindings for Telegram Web App using dart:js_interop
// This file is imported conditionally from lib/main.dart (web target only).
import 'dart:js_interop';

@JS('Telegram.WebApp')
external TelegramWebApp? get _telegramWebApp;

@JS()
@staticInterop
class TelegramWebApp {}

extension TelegramWebAppExt on TelegramWebApp {
  external String get colorScheme;
  external void setThemeParams(JSAny? params);
  external void onEvent(String event, void Function(JSAny?) cb);
}

/// Safe accessor - returns null when not present
TelegramWebApp? get telegramWebApp => _telegramWebApp;
