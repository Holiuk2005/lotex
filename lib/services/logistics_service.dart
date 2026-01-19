import 'dart:convert';

import 'package:http/http.dart' as http;

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
  static const String apiKey = String.fromEnvironment(
    'NOVA_POSHTA_API_KEY',
    defaultValue: 'PUT_YOUR_API_KEY_HERE',
  );

  final http.Client _client;

  LogisticsService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<City>> searchCity(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final jsonMap = await _post(
      modelName: 'Address',
      calledMethod: 'searchSettlements',
      methodProperties: <String, dynamic>{
        'CityName': q,
        'Limit': '20',
      },
    );

    final data = jsonMap['data'];
    if (data is! List || data.isEmpty) return const [];

    // searchSettlements response usually: data[0].Addresses: [{Present, DeliveryCity, ...}]
    final first = data.first;
    if (first is Map<String, dynamic>) {
      final addresses = first['Addresses'];
      if (addresses is List) {
        return addresses
            .whereType<Map>()
            .map((e) => City.fromJson(e.cast<String, dynamic>()))
            .where((c) => c.ref.isNotEmpty && c.name.isNotEmpty)
            .toList();
      }
    }

    // Fallback for getSettlements-like shapes: data: [{Ref, Description, ...}]
    return data
        .whereType<Map>()
        .map((e) => City.fromJson(e.cast<String, dynamic>()))
        .where((c) => c.ref.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }

  Future<List<Branch>> getBranches(String cityRef) async {
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
        .toList();
  }

  Future<double> calculateShippingCost({
    required String citySender,
    required String cityReceiver,
    required double weight,
    required double cost,
  }) async {
    final sender = citySender.trim();
    final receiver = cityReceiver.trim();
    if (sender.isEmpty || receiver.isEmpty) return 0;

    final jsonMap = await _post(
      modelName: 'InternetDocument',
      calledMethod: 'getDocumentPrice',
      methodProperties: <String, dynamic>{
        'CitySender': sender,
        'CityRecipient': receiver,
        'Weight': weight,
        'ServiceType': 'WarehouseWarehouse',
        'Cost': cost,
      },
    );

    final data = jsonMap['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final value = first['Cost'];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0;
      }
    }

    throw const NovaPoshtaException('Nova Poshta response did not contain Cost.');
  }

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
    if (apiKey == 'PUT_YOUR_API_KEY_HERE' || apiKey.trim().isEmpty) {
      throw const NovaPoshtaException(
        'Nova Poshta API key is missing. Provide it via --dart-define=NOVA_POSHTA_API_KEY=...'
      );
    }

    final body = <String, dynamic>{
      'apiKey': apiKey,
      'modelName': modelName,
      'calledMethod': calledMethod,
      'methodProperties': methodProperties,
    };

    final response = await _client.post(
      Uri.parse(baseUrl),
      headers: const <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NovaPoshtaException('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
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
  }
}
