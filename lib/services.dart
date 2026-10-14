import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

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
  static const _kProjects = 'dc_projects';

  List<Project> projects = [];

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kProjects);
    if (raw == null) {
      projects = [];
    } else {
      final list = jsonDecode(raw) as List;
      projects = list
          .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _kProjects,
      jsonEncode(projects.map((p) => p.toJson()).toList()),
    );
  }

  Future<Project> create(String name, String template, List<ScreenModel> screens) async {
    final p = Project(id: uid(), name: name, template: template, screens: screens);
    projects.insert(0, p);
    await _save();
    notifyListeners();
    return p;
  }

  Future<void> save(Project p) async {
    p.updatedAt = DateTime.now();
    final i = projects.indexWhere((x) => x.id == p.id);
    if (i >= 0) projects[i] = p;
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    projects.removeWhere((p) => p.id == id);
    await _save();
    notifyListeners();
  }

  int get totalScreens => projects.fold(0, (n, p) => n + p.screens.length);
  int get totalComponents =>
      projects.fold(0, (n, p) => n + p.screens.fold(0, (m, s) => m + s.components.length));
}
