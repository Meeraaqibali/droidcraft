import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'models.dart';

class AuthService extends ChangeNotifier {
  final Api api = Api();
  String? _token;
  Map<String, dynamic>? user;
  bool get isLoggedIn => _token != null && user != null;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final savedUrl = sp.getString('serverUrl');
    if (savedUrl != null && savedUrl.isNotEmpty) Api.baseUrl = savedUrl;
    _token = sp.getString('token');
    final u = sp.getString('user');
    if (u != null) user = Map<String, dynamic>.from(jsonDecode(u));
    api.setToken(_token);
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    Api.baseUrl = url.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('serverUrl', Api.baseUrl);
    notifyListeners();
  }

  Future<void> _persist(String token, Map<String, dynamic> u) async {
    _token = token;
    user = u;
    api.setToken(token);
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
    await sp.setString('user', jsonEncode(u));
    notifyListeners();
  }

  Future<void> login(String e, String pw) async {
    final res = await api.loginForm(e.trim().toLowerCase(), pw);
    await _persist(res['access_token'], Map<String, dynamic>.from(res['user']));
  }

  Future<void> signup(String name, String e, String pw) async {
    final res = await api.post('/auth/signup',
        {'name': name.trim(), 'email': e.trim().toLowerCase(), 'password': pw});
    await _persist(res['access_token'], Map<String, dynamic>.from(res['user']));
  }

  Future<void> logout() async {
    _token = null;
    user = null;
    api.setToken(null);
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
    await sp.remove('user');
    notifyListeners();
  }
}

class ThemeService extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString('theme') ?? 'light';
    mode = v == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  Future<void> toggle() async {
    mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('theme', mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}

class ProjectService extends ChangeNotifier {
  Api? _api;
  AuthService? _auth;
  List<Project> projects = [];
  bool loading = false;

  void setAuth(AuthService a) {
    _auth = a;
    _api = a.api;
    if (a.isLoggedIn) {
      refresh();
    } else {
      projects = [];
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_api == null || _auth?.isLoggedIn != true) return;
    loading = true;
    notifyListeners();
    try {
      final list = await _api!.get('/projects') as List;
      projects = list.map((e) => Project.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<Project> create(String name, String template, List<ScreenModel> screens) async {
    final res = await _api!.post('/projects', {
      'name': name,
      'template': template,
      'screens': screens.map((s) => s.toJson()).toList(),
    });
    final p = Project.fromJson(Map<String, dynamic>.from(res));
    projects.insert(0, p);
    notifyListeners();
    return p;
  }

  Future<void> save(Project p) async {
    p.updatedAt = DateTime.now();
    await _api!.put('/projects/${p.id}', {
      'name': p.name,
      'template': p.template,
      'screens': p.screens.map((s) => s.toJson()).toList(),
    });
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _api!.del('/projects/$id');
    projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  int get totalScreens => projects.fold(0, (n, p) => n + p.screens.length);
  int get totalComponents =>
      projects.fold(0, (n, p) => n + p.screens.fold(0, (m, s) => m + s.components.length));
}
