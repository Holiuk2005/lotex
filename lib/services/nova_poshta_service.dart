import 'dart:convert';

import 'package:http/http.dart' as http;

class NovaPoshtaService {
  final String apiKey;
  final String _url = 'https://api.novaposhta.ua/v2.0/json/';

  NovaPoshtaService({required this.apiKey});

  Future<List<String>> searchCities(String query) async {
    final body = {
      'apiKey': apiKey,
      'modelName': 'Address',
      'calledMethod': 'searchSettlements',
      'methodProperties': {
        'CityName': query,
        'Limit': '20',
      }
    };

    final res = await http.post(Uri.parse(_url), body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) throw Exception('NovaPoshta API error: ${res.statusCode}');

    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'];
    if (data == null || data is! List) return <String>[];

    final List<String> results = [];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        // Many responses include 'Present' or nested 'Addresses' with 'Present'
        if (item['Present'] is String) {
          results.add(item['Present'] as String);
        } else if (item['Addresses'] is List) {
          for (final a in item['Addresses']) {
            if (a is Map && a['Present'] is String) results.add(a['Present'] as String);
          }
        } else if (item['Description'] is String) {
          results.add(item['Description'] as String);
        }
      }
    }

    // return unique
    return results.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
  }

  Future<List<String>> searchWarehouses(String cityName) async {
    final body = {
      'apiKey': apiKey,
      'modelName': 'Address',
      'calledMethod': 'getWarehouses',
      'methodProperties': {
        'CityName': cityName,
      }
    };

    final res = await http.post(Uri.parse(_url), body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) throw Exception('NovaPoshta API error: ${res.statusCode}');

    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'];
    if (data == null || data is! List) return <String>[];

    final List<String> results = [];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        // Warehouse objects often contain 'Description' or 'DescriptionRu' or 'ShortAddress'
        if (item['Description'] is String) {
          results.add(item['Description'] as String);
        } else if (item['DescriptionRu'] is String) {
          results.add(item['DescriptionRu'] as String);
        } else if (item['ShortAddress'] is String) {
          results.add(item['ShortAddress'] as String);
        } else {
          results.add(item.toString());
        }
      }
    }

    return results.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
  }
}
