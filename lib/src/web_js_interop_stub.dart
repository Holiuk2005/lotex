// Stub for non-web platforms: provides `telegramWebApp` accessor that is null.
import 'dart:core';

class TelegramWebApp {
	String get colorScheme => '';
	void setThemeParams(Object? _) {}
	void onEvent(String event, void Function(Object?) cb) {}
}

TelegramWebApp? get telegramWebApp => null;
