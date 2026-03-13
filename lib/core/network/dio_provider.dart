import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/network/dio_client.dart';

/// Використовуйте цей провайдер для HTTP-запитів до вашого власного серверного модуля.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.create();
});
