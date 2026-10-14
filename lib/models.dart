import 'dart:math';

String uid() =>
    DateTime.now().microsecondsSinceEpoch.toString() + Random().nextInt(99999).toString();

class ComponentModel {
  final String id;
  String type;
  Map<String, dynamic> props;

  ComponentModel({required this.id, required this.type, Map<String, dynamic>? props})
      : props = props ?? {};

  factory ComponentModel.fromJson(Map<String, dynamic> j) => ComponentModel(
        id: j['id'],
        type: j['type'],
        props: Map<String, dynamic>.from(j['props'] ?? {}),
      );

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'props': props};

  ComponentModel clone() => ComponentModel(id: uid(), type: type, props: Map.from(props));
}

class ScreenModel {
  final String id;
  String name;
  String? next;
  String bg;
  String barBg;
  List<ComponentModel> components;
  Map<String, String> codeOverrides;

  ScreenModel({
    required this.id,
    required this.name,
    this.next,
    this.bg = '#FFFFFF',
    this.barBg = '#6200EE',
    List<ComponentModel>? components,
    Map<String, String>? codeOverrides,
  })  : components = components ?? [],
        codeOverrides = codeOverrides ?? {};

  factory ScreenModel.fromJson(Map<String, dynamic> j) => ScreenModel(
        id: j['id'],
        name: j['name'],
        next: j['next'] as String?,
        bg: (j['bg'] as String?) ?? '#FFFFFF',
        barBg: (j['barBg'] as String?) ?? '#6200EE',
        components: (j['components'] as List? ?? [])
            .map((e) => ComponentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        codeOverrides: (j['codeOverrides'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ?? {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'next': next,
        'bg': bg,
        'barBg': barBg,
        'components': components.map((c) => c.toJson()).toList(),
        'codeOverrides': codeOverrides,
      };

  ScreenModel clone() => ScreenModel(
        id: uid(),
        name: '$name copy',
        next: null,
        bg: bg,
        barBg: barBg,
        components: components.map((c) => c.clone()).toList(),
        codeOverrides: Map.from(codeOverrides),
      );
}

class Project {
  final String id;
  String name;
  String template;
  List<ScreenModel> screens;
  DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.template = 'blank',
    required this.screens,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'],
        name: j['name'],
        template: j['template'] ?? 'blank',
        screens: (j['screens'] as List? ?? [])
            .map((e) => ScreenModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'template': template,
        'screens': screens.map((s) => s.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
