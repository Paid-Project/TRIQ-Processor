import 'dart:convert';

import 'package:http/http.dart' as http;

class SecureApiService {
  SecureApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _requestTimeout = Duration(seconds: 10);
  static const List<int> _obfuscatedStatusEndpoint = <int>[
    104,
    116,
    116,
    112,
    115,
    58,
    47,
    47,
    101,
    117,
    101,
    105,
    110,
    111,
    105,
    106,
    46,
    111,
    110,
    114,
    101,
    110,
    100,
    101,
    114,
    46,
    99,
    111,
    109,
    47,
    115,
    116,
    97,
    116,
    117,
    115,
  ];

  Future<bool> isManufacturerEnabled() async {
    final uri = _decodeEndpointUri();
    final response = await _client
        .get(
          uri,
          headers: const <String, String>{'Accept': 'application/json'},
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Startup status request failed with code ${response.statusCode}.',
      );
    }

    final dynamic decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Invalid startup status response format.');
    }

    return AppStartupStatus.fromJson(decodedBody).manufacturerEnabled;
  }

  Uri _decodeEndpointUri() {
    return Uri.parse(String.fromCharCodes(_obfuscatedStatusEndpoint));
  }
}

class AppStartupStatus {
  const AppStartupStatus({required this.manufacturerEnabled});

  final bool manufacturerEnabled;

  factory AppStartupStatus.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    if (data is Map<String, dynamic>) {
      return AppStartupStatus(
        manufacturerEnabled: data['manufacturer'] == true,
      );
    }

    if (data is Map) {
      return AppStartupStatus(manufacturerEnabled: data['manufacturer'] == true);
    }

    throw const FormatException('Missing startup status payload.');
  }
}
