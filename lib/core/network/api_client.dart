import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

/// The backend address. It is not written in the code: pass it when you run the app, for example
///   flutter run --dart-define=API_URL=http://10.0.2.2:8000/vesper
const apiBaseUrl = String.fromEnvironment('API_URL');

/// For testing before the login API is hosted. Pass an officer's email when you run the app:
///   flutter run --dart-define=API_URL=... --dart-define=TEST_USER=officer@example.com
/// The app then skips Sign In and sends this email in the X-Test-User header, like the dashboard.
/// Leave it out and the normal Sign In screen comes back.
const testUser = String.fromEnvironment('TEST_USER');
bool get skipSignIn => testUser.isNotEmpty;

/// An error from the backend, or from not reaching it.
/// statusCode is null when the server could not be reached at all.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isOffline => statusCode == null;

  @override
  String toString() => message;
}

/// The only class that talks to the backend. Repositories use it; screens never do.
class ApiClient {
  ApiClient({required this.baseUrl, required this.tokens, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final TokenStorage tokens;
  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  Future<dynamic> get(String path, {String? token}) => _send('GET', path, token: token);

  Future<dynamic> post(String path, {Object? body, String? token}) => _send('POST', path, body: body, token: token);

  Future<dynamic> patch(String path, {Object? body}) => _send('PATCH', path, body: body);

  Future<dynamic> _send(String method, String path, {Object? body, String? token}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    // Use the token given (right after sign-in) or the one saved on the phone
    final bearer = token ?? await tokens.readAccess();
    if (bearer != null) headers['Authorization'] = 'Bearer $bearer';
    if (bearer == null && skipSignIn) headers['X-Test-User'] = testUser;

    final request = http.Request(method, Uri.parse('$baseUrl$path'))..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request).timeout(_timeout));
    } on TimeoutException {
      throw ApiException('The server took too long to answer. Try again.');
    } on SocketException {
      throw ApiException('The server could not be reached. Check your connection.');
    } on http.ClientException {
      throw ApiException('The server could not be reached. Check your connection.');
    }

    final data = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    throw ApiException(_detail(data) ?? 'Request failed (${response.statusCode})', statusCode: response.statusCode);
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  String? _detail(dynamic data) {
    if (data is Map && data['detail'] is String) return data['detail'] as String;
    return null;
  }
}
