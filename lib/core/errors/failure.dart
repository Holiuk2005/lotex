import '../i18n/lotex_i18n.dart';

abstract class Failure implements Exception {
  const Failure();

  String message(LotexLanguage lang);

  @override
  String toString() => runtimeType.toString();
}

class AuthRequiredFailure extends Failure {
  const AuthRequiredFailure();

  @override
  String message(LotexLanguage lang) => LotexI18n.tr(lang, 'authRequired');
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure();

  @override
  String message(LotexLanguage lang) =>
      LotexI18n.tr(lang, 'errorPermissionDenied');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();

  @override
  String message(LotexLanguage lang) => LotexI18n.tr(lang, 'errorNotFound');
}

class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  String message(LotexLanguage lang) => LotexI18n.tr(lang, 'errorNetwork');
}

class ValidationFailure extends Failure {
  final String details;

  const ValidationFailure(this.details);

  @override
  String message(LotexLanguage lang) {
    final d = details.trim();
    if (d.isEmpty) return LotexI18n.tr(lang, 'errorTryAgain');
    return LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', d);
  }
}

class UnknownFailure extends Failure {
  final Object error;

  const UnknownFailure(this.error);

  @override
  String message(LotexLanguage lang) {
    return LotexI18n.tr(lang, 'errorWithDetails')
        .replaceFirst('{details}', error.toString());
  }
}
