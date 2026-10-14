import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class Api {
  static const String baseUrl =
      String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8000');

  String? _token;
  void setToken(String? t) => _token = t;

  Map<String, String> get _h => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  dynamic _dec(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = body is Map && body['detail'] != null
        ? body['detail'].toString()
        : 'Request failed';
    throw ApiException(r.statusCode, msg);
  }

  Future<dynamic> get(String p) async =>
      _dec(await http.get(Uri.parse('$baseUrl$p'), headers: _h));

  Future<dynamic> post(String p, Map<String, dynamic> b) async =>
      _dec(await http.post(Uri.parse('$baseUrl$p'), headers: _h, body: jsonEncode(b)));

  Future<dynamic> put(String p, Map<String, dynamic> b) async =>
      _dec(await http.put(Uri.parse('$baseUrl$p'), headers: _h, body: jsonEncode(b)));

  Future<void> del(String p) async {
    final r = await http.delete(Uri.parse('$baseUrl$p'), headers: _h);
    if (r.statusCode != 204 && r.statusCode != 200) _dec(r);
  }

  Future<dynamic> loginForm(String e, String pw) async => _dec(await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': e, 'password': pw},
      ));
}
