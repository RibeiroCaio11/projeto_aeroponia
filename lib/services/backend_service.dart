import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/backend_models.dart';

class BackendException implements Exception {
  final String message;
  final int? statusCode;

  const BackendException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BackendService {
  static const defaultBaseUrl =
      'https://backend-tower-e3c3czeufgb8facg.eastus-01.azurewebsites.net/dados';

  static const _configuredBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  final http.Client _client;
  final String baseUrl;

  BackendService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = _normalizeBaseUrl(baseUrl ?? _configuredBaseUrl);

  Uri _uri(String path) {
    if (baseUrl.endsWith('/dados')) {
      final root = baseUrl.substring(0, baseUrl.length - '/dados'.length);
      return Uri.parse(path == '/dados' ? baseUrl : '$root$path');
    }
    return Uri.parse('$baseUrl$path');
  }

  Future<SensorSnapshot> getDados() async {
    final json = await _getJson('/dados');
    return SensorSnapshot.fromJson(json);
  }

  Future<Map<String, double>> getThresholds() async {
    final json = await _getJson('/thresholds');
    return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  Future<Map<String, double>> updateThresholds(
    Map<String, double> thresholds,
  ) async {
    final json = await _postJson('/thresholds', thresholds);
    final updated = json['thresholds'] as Map<String, dynamic>? ?? {};
    return updated.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
  }

  Future<MotorStatus> getMotorStatus() async {
    final json = await _getJson('/motor/status');
    return MotorStatus.fromJson(json);
  }

  Future<void> iniciarCiclo({
    required int minutosLigado,
    required int minutosDesligado,
  }) async {
    await _postJson('/motor/ciclo', {
      'minutos_ligado': minutosLigado,
      'minutos_desligado': minutosDesligado,
    });
  }

  Future<void> desligarMotor() async {
    await _postJson('/motor/desligar', const {});
  }

  void close() {
    _client.close();
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _client
        .get(_uri(path))
        .timeout(const Duration(seconds: 5));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .post(
          _uri(path),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final detail = body['detail']?.toString();
    throw BackendException(
      detail?.isNotEmpty == true
          ? detail!
          : 'Backend retornou erro ${response.statusCode}.',
      statusCode: response.statusCode,
    );
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
