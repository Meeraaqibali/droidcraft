import 'models.dart';
import 'registry.dart';

List<ComponentModel> parseXmlToComponents(String xml) {
  final out = <ComponentModel>[];
  final clean = xml.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

  final re = RegExp(
    r'<(TextView|Button|EditText|ImageView|View|Space|ProgressBar|SeekBar|Switch|CheckBox|RadioButton|RatingBar|androidx\.cardview\.widget\.CardView|com\.google\.android\.material\.chip\.Chip|com\.google\.android\.material\.floatingactionbutton\.FloatingActionButton)\b([^>]*?)/?>',
    dotAll: true,
  );

  for (final m in re.allMatches(clean)) {
    final fullTag = m.group(1)!;
    final attrs = _parseAttrs(m.group(2) ?? '');
    final short = fullTag.split('.').last;
    final type = _tagToType(short, attrs);
    if (type == null) continue;
    final c = makeComponent(type);
    _applyProps(c, attrs, type);
    out.add(c);
  }

  return out;
}

Map<String, String> _parseAttrs(String s) {
  final map = <String, String>{};
  final re = RegExp(r'([\w:]+)\s*=\s*"([^"]*)"');
  for (final m in re.allMatches(s)) {
    map[m.group(1)!] = m.group(2)!;
  }
  return map;
}

String? _tagToType(String short, Map<String, String> a) {
  switch (short) {
    case 'TextView':
      final size = _num(a['android:textSize']);
      final bold = (a['android:textStyle'] ?? '').contains('bold');
      if (size >= 20 || (bold && size >= 18)) return 'heading';
      return 'text';
    case 'Button': return 'button';
    case 'EditText': return 'input';
    case 'ImageView': return 'image';
    case 'View': return 'divider';
    case 'Space': return 'spacer';
    case 'CardView': return 'card';
    case 'TabLayout': return 'tabs';
    case 'ProgressBar': return 'progress';
    case 'SeekBar': return 'slider';
    case 'Switch': return 'switch';
    case 'CheckBox': return 'checkbox';
    case 'RadioButton': return 'radio';
    case 'Chip': return 'chip';
    case 'FloatingActionButton': return 'fab';
    case 'RatingBar': return 'rating';
  }
  return null;
}

double _num(String? s) {
  if (s == null) return 0;
  final m = RegExp(r'-?\d+(\.\d+)?').firstMatch(s);
  return m == null ? 0 : double.tryParse(m.group(0)!) ?? 0;
}

String _hex(String v) {
  final s = v.replaceAll('#', '').toUpperCase();
  if (s.length == 8) return '#' + s.substring(2);
  if (s.length == 6) return '#' + s;
  return '#111827';
}

void _applyProps(ComponentModel c, Map<String, String> a, String type) {
  final p = c.props;
  if (a['android:text'] != null) p['text'] = a['android:text'];
  if (a['android:hint'] != null) p['text'] = a['android:hint'];
  if (a['android:textColor'] != null) p['color'] = _hex(a['android:textColor']!);
  if (a['android:backgroundTint'] != null) p['bg'] = _hex(a['android:backgroundTint']!);
  if (a['android:background'] != null) {
    final v = a['android:background']!.replaceAll('#', '').toUpperCase();
    if (v != '00000000' && v != '000000' && v.length >= 6) p['bg'] = _hex(a['android:background']!);
  }
  if (a['android:textSize'] != null) p['size'] = _num(a['android:textSize']).round();
  final style = a['android:textStyle'] ?? '';
  p['bold'] = style.contains('bold');
  p['italic'] = style.contains('italic');
  if (a['android:gravity'] != null) {
    final g = a['android:gravity']!;
    if (g.contains('center')) p['align'] = 'center';
    else if (g.contains('end') || g.contains('right')) p['align'] = 'right';
  }
  if (a['android:layout_gravity'] != null) {
    final g = a['android:layout_gravity']!;
    if (g.contains('center')) p['align'] = 'center';
    else if (g.contains('end') || g.contains('right')) p['align'] = 'right';
  }
  if (a['android:checked'] != null) p['on'] = a['android:checked'] == 'true';
  if (a['android:padding'] != null) p['padding'] = _num(a['android:padding']).round();
  if (a['app:cardCornerRadius'] != null) p['radius'] = _num(a['app:cardCornerRadius']).round();
  if (a['android:layout_height'] != null && (type == 'image' || type == 'spacer')) {
    final h = _num(a['android:layout_height']!);
    if (h > 0) p['height'] = h;
    if (type == 'spacer') p['size'] = h.round();
  }
  if (a['android:layout_width'] != null && type == 'image') {
    final w = _num(a['android:layout_width']!);
    if (w > 0) p['width'] = w;
  }
}


/// Reads common Kotlin property patterns and applies them to the given components.
/// Supported:
///   findViewById<X>(R.id.TYPE_N).text = "..."
///   findViewById<X>(R.id.TYPE_N).textSize = 18f
///   findViewById<X>(R.id.TYPE_N).setTextColor(Color.RED)
///   findViewById<X>(R.id.TYPE_N).setBackgroundColor(Color.RED)
///   findViewById<X>(R.id.TYPE_N).visibility = View.GONE
///   findViewById<X>(R.id.TYPE_N).isChecked = true
/// Colors accept Color.RED, Color.parseColor("#FF0000"), 0xFF0000FF.toInt()
void parseKotlinOverrides(String kotlin, List<ComponentModel> components) {
  // Strip comments
  final clean = kotlin
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .replaceAll(RegExp(r'//[^\n]*'), '');

  // Map id -> component
  final byId = <String, ComponentModel>{};
  for (var i = 0; i < components.length; i++) {
    byId['${components[i].type}_$i'] = components[i];
  }

  // .text = "..."
  for (final m in RegExp(r'R\.id\.(\w+)\)\s*\.text\s*=\s*"([^"]*)"').allMatches(clean)) {
    byId[m.group(1)!]?.props['text'] = m.group(2)!;
  }

  // .textSize = 18f  or  18.5f
  for (final m in RegExp(r'R\.id\.(\w+)\)\s*\.textSize\s*=\s*([\d.]+)f').allMatches(clean)) {
    final c = byId[m.group(1)!];
    if (c != null) c.props['size'] = double.parse(m.group(2)!).round();
  }

  // .isChecked = true|false
  for (final m in RegExp(r'R\.id\.(\w+)\)\s*\.isChecked\s*=\s*(true|false)').allMatches(clean)) {
    byId[m.group(1)!]?.props['on'] = m.group(2) == 'true';
  }

  // visibility = View.GONE  -> clear components
  for (final m in RegExp(r'R\.id\.(\w+)\)\s*\.visibility\s*=\s*View\.GONE').allMatches(clean)) {
    final c = byId[m.group(1)!];
    if (c != null) c.props['_hidden'] = true;
  }

  // setTextColor(...) / setBackgroundColor(...)
  final colorRe = RegExp(
    r'R\.id\.(\w+)\)\s*\.(setTextColor|setBackgroundColor)\s*\(\s*([^)]+)\)',
  );
  for (final m in colorRe.allMatches(clean)) {
    final id = m.group(1)!;
    final which = m.group(2)!;
    final arg = m.group(3)!.trim();
    final hex = _kotlinColor(arg);
    if (hex == null) continue;
    final c = byId[id];
    if (c == null) continue;
    if (which == 'setTextColor') {
      c.props['color'] = hex;
    } else {
      c.props['bg'] = hex;
    }
  }

  // Remove hidden components
  components.removeWhere((c) => c.props['_hidden'] == true);
  for (final c in components) {
    c.props.remove('_hidden');
  }
}

String? _kotlinColor(String arg) {
  // Color.RED, Color.BLUE, etc.
  final nameMatch = RegExp(r'^Color\.([A-Z_]+)$').firstMatch(arg);
  if (nameMatch != null) {
    const named = {
      'RED': '#EF4444',
      'BLUE': '#3B82F6',
      'GREEN': '#10B981',
      'BLACK': '#000000',
      'WHITE': '#FFFFFF',
      'YELLOW': '#F59E0B',
      'CYAN': '#06B6D4',
      'MAGENTA': '#D946EF',
      'GRAY': '#6B7280',
      'GREY': '#6B7280',
      'DKGRAY': '#374151',
      'LTGRAY': '#D1D5DB',
    };
    return named[nameMatch.group(1)!];
  }
  // Color.parseColor("#FF0000")
  final parseMatch = RegExp(r'Color\.parseColor\("([^"]+)"\)').firstMatch(arg);
  if (parseMatch != null) return _hex(parseMatch.group(1)!);
  // 0xFF0000FF.toInt() or 0xFF0000FF
  final intMatch = RegExp(r'0x([0-9A-Fa-f]{8})').firstMatch(arg);
  if (intMatch != null) return '#' + intMatch.group(1)!.substring(2);
  return null;
}
