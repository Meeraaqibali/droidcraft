
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
