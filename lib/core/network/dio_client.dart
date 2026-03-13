import 'dart:async';

import 'package:dio/dio.dart';
import 'package:lotex/core/config/app_config.dart';
import 'package:lotex/services/secure_storage_service.dart';

/// Створює клієнт [Dio], налаштований для серверної частини JWT.
///
/// - Автоматично додає `Authorization: Bearer <accessToken>`.
/// - За бажанням оновлює токени при коді 401, якщо існує `refreshToken`.
///
/// ПРИМІТКА: Вважається, що кінцева точка/форма оновлення має вигляд:
/// POST `/auth/refresh` -> { accessToken: string, refreshToken: string }
/// Налаштуйте після того, як стане відомий ваш бекенд-контракт.
class DioClient {
  static Dio create({Dio? base}) {
    final dio = base ?? Dio();

    dio.options = dio.options.copyWith(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );

    final refreshCoordinator = _RefreshCoordinator(dio);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Якщо apiBaseUrl не налаштовано, нічого не додавати.
          if (dio.options.baseUrl.isEmpty) {
            return handler.next(options);
          }

          final token = await SecureStorageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Спробувати оновлення лише у разі помилки 401 з нашого налаштованого сервера.
          if (dio.options.baseUrl.isEmpty) return handler.next(error);

          final status = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final alreadyRetried = requestOptions.extra['__retried'] == true;
          if (status != 401 || alreadyRetried) {
            return handler.next(error);
          }

          final refreshed = await refreshCoordinator.tryRefreshTokens();
          if (!refreshed) {
            return handler.next(error);
          }

          // Повторити початковий запит із новим токеном.
          final newToken = await SecureStorageService.getAccessToken();
          final retryOptions = requestOptions;
          retryOptions.extra['__retried'] = true;
          if (newToken != null && newToken.isNotEmpty) {
            retryOptions.headers['Authorization'] = 'Bearer $newToken';
          }

          try {
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        },
      ),
    );

    return dio;
  }
}

class _RefreshCoordinator {
  final Dio _dio;

  Completer<bool>? _inFlight;

  _RefreshCoordinator(this._dio);

  Future<bool> tryRefreshTokens() async {
    final existing = _inFlight;
    if (existing != null) return existing.future;

    final completer = Completer<bool>();
    _inFlight = completer;

    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(false);
        return completer.future;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          // Запобігання нескінченним циклам: не підключайте тут неактуальний токен доступу.
          headers: <String, dynamic>{},
          extra: const {'__retried': true},
        ),
      );

      final data = response.data;
      final access = data?['accessToken'] as String?;
      final refresh = data?['refreshToken'] as String?;

      if (access == null || access.isEmpty) {
        completer.complete(false);
        return completer.future;
      }

      await SecureStorageService.setAccessToken(access);
      if (refresh != null && refresh.isNotEmpty) {
        await SecureStorageService.setRefreshToken(refresh);
      }

      completer.complete(true);
      return completer.future;
    } catch (_) {
      // Якщо оновлення не вдалося, видалити токени, щоб інтерфейс міг виконати повторну автентифікацію
      await SecureStorageService.deleteAllTokens();
      completer.complete(false);
      return completer.future;
    } finally {
      _inFlight = null;
    }
  }
}
