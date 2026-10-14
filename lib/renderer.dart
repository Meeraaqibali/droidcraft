import 'dart:io';
import 'package:flutter/material.dart';
import 'models.dart';

Color parseColor(dynamic v, [Color fallback = const Color(0xFF111827)]) {
  if (v == null) return fallback;
  final s = v.toString().replaceAll('#', '');
  try {
    if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
    if (s.length == 8) return Color(int.parse(s, radix: 16));
  } catch (_) {}
  return fallback;
}

double _rad(Map<String, dynamic> p, double fallback) {
  final v = (p['radius'] as num?)?.toDouble();
  if (v == null) return fallback;
  return v;
}

double _pad(Map<String, dynamic> p, double fallback) {
  final v = (p['padding'] as num?)?.toDouble();
  if (v == null) return fallback;
  return v;
}

TextAlign _alignOf(String? a) =>
    a == 'center' ? TextAlign.center : a == 'right' ? TextAlign.right : TextAlign.left;

Alignment _crossOf(String? a) =>
    a == 'center' ? Alignment.center : a == 'right' ? Alignment.centerRight : Alignment.centerLeft;

BoxFit _fitOf(String? f) {
  switch (f) {
    case 'contain': return BoxFit.contain;
    case 'fill': return BoxFit.fill;
    case 'fitWidth': return BoxFit.fitWidth;
    case 'fitHeight': return BoxFit.fitHeight;
    case 'none': return BoxFit.none;
    default: return BoxFit.cover;
  }
}

TextStyle _textStyle(Map<String, dynamic> p, Color color, double size, {double? defaultWeight}) {
  final bold = p['bold'] == true;
  final italic = p['italic'] == true;
  final underline = p['underline'] == true;
  return TextStyle(
    color: color,
    fontSize: size,
    height: (p['lineHeight'] as num?)?.toDouble() ?? 1.4,
    letterSpacing: (p['letterSpacing'] as num?)?.toDouble() ?? 0,
    fontWeight: bold ? FontWeight.w800 : (defaultWeight != null ? FontWeight.w700 : FontWeight.normal),
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    decoration: underline ? TextDecoration.underline : TextDecoration.none,
  );
}

class ComponentRenderer extends StatelessWidget {
  final ComponentModel component;
  const ComponentRenderer({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final p = component.props;
    final color = parseColor(p['color'], const Color(0xFF111827));
    final size = (p['size'] as num?)?.toDouble() ?? 14;
    final align = (p['align'] ?? 'left').toString();
    final textAlign = _alignOf(align);
    final cross = _crossOf(align);

    switch (component.type) {
      case 'heading':
        return Padding(
          padding: EdgeInsets.all(_pad(p, 0)),
          child: Text(p['text']?.toString() ?? 'Heading',
              textAlign: textAlign,
              style: _textStyle(p, color, size, defaultWeight: 700)),
        );

      case 'text':
        return Padding(
          padding: EdgeInsets.all(_pad(p, 0)),
          child: Text(p['text']?.toString() ?? 'Text',
              textAlign: textAlign,
              style: _textStyle(p, color, size)),
        );

      case 'button':
        return Align(
          alignment: cross,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 26 + _pad(p, 0),
              vertical: 12 + _pad(p, 0),
            ),
            decoration: BoxDecoration(
              color: parseColor(p['bg'], const Color(0xFF6200EE)),
              borderRadius: BorderRadius.circular(_rad(p, 10)),
              boxShadow: const [BoxShadow(color: Color(0x476200EE), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Text(p['text']?.toString() ?? 'Button',
                style: TextStyle(
                  color: color,
                  fontSize: size,
                  fontWeight: p['bold'] == true ? FontWeight.w800 : FontWeight.w700,
                )),
          ),
        );

      case 'input':
        return Container(
          padding: EdgeInsets.all(14 + _pad(p, 0)),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            borderRadius: BorderRadius.circular(_rad(p, 8)),
            color: Colors.white,
          ),
          child: Text(p['text']?.toString() ?? 'Input',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 14)),
        );

      case 'image':
        final path = (p['path'] ?? '').toString();
        final w = (p['width'] as num?)?.toDouble() ?? 0;
        final h = (p['height'] as num?)?.toDouble() ?? 160;
        final fit = _fitOf(p['fit']?.toString());
        final radius = _rad(p, 8);

        Widget placeholder = Container(
          width: w > 0 ? w : double.infinity,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 40, color: Color(0xFF9CA3AF)),
          ),
        );

        if (path.isEmpty) return placeholder;

        final file = File(path);
        if (!file.existsSync()) {
          return Container(
            width: w > 0 ? w : double.infinity,
            height: h,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: const Center(
              child: Text('Image not found', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            file,
            width: w > 0 ? w : double.infinity,
            height: h,
            fit: fit,
            errorBuilder: (_, __, ___) => Container(
              width: w > 0 ? w : double.infinity,
              height: h,
              color: const Color(0xFFFFE4E6),
              child: const Center(
                child: Text('Failed to load', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        );

      case 'avatar':
        final s = size * 4;
        final radius = _rad(p, 0);
        final pad = _pad(p, 0);
        return Align(
          alignment: cross,
          child: Container(
            width: s + pad * 2,
            height: s + pad * 2,
            decoration: BoxDecoration(
              shape: radius > 0 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
              gradient: const LinearGradient(colors: [Color(0xFF6200EE), Color(0xFF9C27B0)]),
            ),
            child: Center(
              child: Text('A',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 1.6)),
            ),
          ),
        );

      case 'divider':
        return Container(height: 1, color: const Color(0xFFE5E7EB));

      case 'spacer':
        return SizedBox(height: size);

      case 'card':
        return Container(
          padding: EdgeInsets.all(16 + _pad(p, 0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_rad(p, 12)),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p['text']?.toString() ?? 'Card title',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111827))),
              const SizedBox(height: 4),
              const Text('Supporting text for this card.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4)),
            ],
          ),
        );

      case 'appbar':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 + _pad(p, 0),
            vertical: 14 + _pad(p, 0),
          ),
          decoration: BoxDecoration(
            color: parseColor(p['bg'], const Color(0xFF6200EE)),
            borderRadius: BorderRadius.circular(_rad(p, 8)),
          ),
          child: Text(p['text']?.toString() ?? 'App Bar',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        );

      case 'tabs':
        return Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: color, width: 2.5)),
              ),
              child: Text(p['text']?.toString() ?? 'Tab One',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(width: 22),
            const Text('Tab Two',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            const SizedBox(width: 22),
            const Text('Tab Three',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
          ]),
        );

      case 'progress':
        return ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: 0.6,
            minHeight: 6,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(Color(0xFF6200EE)),
          ),
        );

      case 'slider':
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6200EE),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFF6200EE),
            trackHeight: 4,
          ),
          child: Slider(value: 0.5, onChanged: (_) {}),
        );

      case 'switch':
        return Row(
          children: [
            Expanded(child: Text(p['text']?.toString() ?? 'Switch',
                style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w500))),
            Switch(value: p['on'] == true, onChanged: (_) {}, activeColor: const Color(0xFF6200EE)),
          ],
        );

      case 'checkbox':
        return Row(children: [
          Checkbox(value: p['on'] == true, onChanged: (_) {}, activeColor: const Color(0xFF6200EE)),
          Text(p['text']?.toString() ?? 'Checkbox',
              style: TextStyle(color: color, fontSize: size)),
        ]);

      case 'radio':
        return Row(children: [
          Radio<bool>(
              value: true,
              groupValue: p['on'] == true,
              onChanged: (_) {},
              activeColor: const Color(0xFF6200EE)),
          Text(p['text']?.toString() ?? 'Radio option',
              style: TextStyle(color: color, fontSize: size)),
        ]);

      case 'chip':
        return Align(
          alignment: cross,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 + _pad(p, 0),
              vertical: 7 + _pad(p, 0),
            ),
            decoration: BoxDecoration(
              color: parseColor(p['bg'], const Color(0xFF6200EE)),
              borderRadius: BorderRadius.circular(_rad(p, 16)),
            ),
            child: Text(p['text']?.toString() ?? 'Chip',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        );

      case 'fab':
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: parseColor(p['bg'], const Color(0xFF6200EE)),
              shape: _rad(p, 0) > 0 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: _rad(p, 0) > 0 ? BorderRadius.circular(_rad(p, 0)) : null,
              boxShadow: const [BoxShadow(color: Color(0x596200EE), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.white, size: 28)),
          ),
        );

      case 'rating':
        return Text('★ ★ ★ ★ ☆',
            textAlign: textAlign, style: TextStyle(fontSize: size + 6, letterSpacing: 3));

      default:
        return const Text('Unknown component', style: TextStyle(color: Colors.grey, fontSize: 13));
    }
  }
}
