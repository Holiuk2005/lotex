import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/network/dio_client.dart';

/// Use this provider for HTTP calls to your custom backend.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.create();
});
