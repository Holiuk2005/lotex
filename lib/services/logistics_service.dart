import 'package:dio/dio.dart';

class City {
  final String ref;
  final String name;

  const City({
    required this.ref,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    final ref = (json['DeliveryCity'] ?? json['Ref'] ?? '').toString();
    final name = (json['Present'] ?? json['Description'] ?? json['MainDescription'] ?? '').toString();
    return City(ref: ref, name: name);
  }
}

class Branch {
  final String ref;
  final String description;

  const Branch({
    required this.ref,
    required this.description,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final ref = (json['Ref'] ?? '').toString();
    final description = (json['Description'] ?? json['ShortAddress'] ?? '').toString();
    return Branch(ref: ref, description: description);
  }
}

class NovaPoshtaException implements Exception {
  final String message;

  const NovaPoshtaException(this.message);

  @override
  String toString() => message;
}

class LogisticsService {
  static const String baseUrl = 'https://api.novaposhta.ua/v2.0/json/';

  /// Recommended: provide via `--dart-define=NOVA_POSHTA_API_KEY=...`.
  static const String apiKey = String.fromEnvironment('NOVA_POSHTA_API_KEY', defaultValue: '');

  final Dio _dio;
  final String _apiKey;

  LogisticsService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: const <String, dynamic>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ),
        _apiKey = (apiKey ?? LogisticsService.apiKey).trim();

  /// TASK-2: Address/getSettlements
  Future<List<City>> searchCities(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final jsonMap = await _post(
      modelName: 'Address',
      calledMethod: 'getSettlements',
      methodProperties: <String, dynamic>{
        'FindByString': q,
        'Limit': '20',
      },
    );

    final data = jsonMap['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((e) => City.fromJson(e.cast<String, dynamic>()))
        .where((c) => c.ref.isNotEmpty && c.name.isNotEmpty)
        .toList(growable: false);
  }

  /// TASK-2: Address/getWarehouses
  Future<List<Branch>> getWarehouses(String cityRef) async {
    final ref = cityRef.trim();
    if (ref.isEmpty) return const [];

    final jsonMap = await _post(
      modelName: 'Address',
      calledMethod: 'getWarehouses',
      methodProperties: <String, dynamic>{
        'CityRef': ref,
      },
    );

    final data = jsonMap['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((e) => Branch.fromJson(e.cast<String, dynamic>()))
        .where((b) => b.ref.isNotEmpty && b.description.isNotEmpty)
        .toList(growable: false);
  }

  /// TASK-2: InternetDocument/getPrice
  Future<double> calculateShippingPrice({
    required String citySender,
    required String cityRecipient,
    required double weight,
    required double cost,
  }) async {
    final sender = citySender.trim();
    final recipient = cityRecipient.trim();
    if (sender.isEmpty || recipient.isEmpty) return 0;

    final jsonMap = await _post(
      modelName: 'InternetDocument',
      calledMethod: 'getPrice',
      methodProperties: <String, dynamic>{
        'CitySender': sender,
        'CityRecipient': recipient,
        'Weight': weight,
        'ServiceType': 'WarehouseWarehouse',
        'Cost': cost,
        'CargoType': 'Cargo',
        'SeatsAmount': '1',
      },
    );

    final data = jsonMap['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final value = first['Cost'];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
      }
    }

    throw const NovaPoshtaException('Nova Poshta response did not contain Cost.');
  }

  // Backwards-compatible API (used by existing UI widgets).
  Future<List<City>> searchCity(String query) => searchCities(query);
  Future<List<Branch>> getBranches(String cityRef) => getWarehouses(cityRef);
  Future<double> calculateShippingCost({
    required String citySender,
    required String cityReceiver,
    required double weight,
    required double cost,
  }) =>
      calculateShippingPrice(
        citySender: citySender,
        cityRecipient: cityReceiver,
        weight: weight,
        cost: cost,
      );

  /// Still mocked: a full `InternetDocument/save` request requires many fields
  /// (sender/recipient contact, addresses, date, cargo details, etc.).
  ///
  /// TODO: Integrate Nova Poshta InternetDocument/save API here.
  Future<String> createTTN({
    required String senderRef,
    required String receiverRef,
  }) async {
    return '20450548923341';
  }

  Future<Map<String, dynamic>> _post({
    required String modelName,
    required String calledMethod,
    required Map<String, dynamic> methodProperties,
  }) async {
    if (_apiKey.isEmpty) {
      throw const NovaPoshtaException(
        'Nova Poshta API key is missing. Provide it via --dart-define=NOVA_POSHTA_API_KEY=...'
      );
    }

    final body = <String, dynamic>{
      'apiKey': _apiKey,
      'modelName': modelName,
      'calledMethod': calledMethod,
      'methodProperties': methodProperties,
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '',
        data: body,
        options: Options(responseType: ResponseType.json),
      );

      final decoded = response.data;
      if (decoded == null) {
        throw const NovaPoshtaException('Unexpected Nova Poshta response format.');
      }

      final success = decoded['success'];
      if (success == false) {
        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          throw NovaPoshtaException(errors.join('\n'));
        }
        final warnings = decoded['warnings'];
        if (warnings is List && warnings.isNotEmpty) {
          throw NovaPoshtaException(warnings.join('\n'));
        }
        throw const NovaPoshtaException('Nova Poshta request failed.');
      }

      return decoded;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final bodyText = e.response?.data;
      throw NovaPoshtaException('Nova Poshta HTTP ${status ?? '-'}: ${bodyText ?? e.message}');
    }
  }
}
