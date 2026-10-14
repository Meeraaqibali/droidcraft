import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../exporter.dart';
import '../models.dart';
import '../theme.dart';

class CodeEditorScreen extends StatefulWidget {
  final Project project;
  final ScreenModel screen;
  final VoidCallback onChanged;
  const CodeEditorScreen({
    super.key,
    required this.project,
    required this.screen,
    required this.onChanged,
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late TextEditingController _xmlCtrl;
  late TextEditingController _ktCtrl;
  bool _xmlDirty = false;
  bool _ktDirty = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);

    // If a saved override exists, use it. Otherwise generate from the design.
    final savedXml = widget.screen.codeOverrides['xml'];
    final savedKt = widget.screen.codeOverrides['kotlin'];
    _xmlCtrl = TextEditingController(text: savedXml ?? exportXml(widget.screen));
    _ktCtrl = TextEditingController(text: savedKt ?? exportKotlin(widget.project, widget.screen));

    _xmlCtrl.addListener(() => setState(() => _xmlDirty = true));
    _ktCtrl.addListener(() => setState(() => _ktDirty = true));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _xmlCtrl.dispose();
    _ktCtrl.dispose();
    super.dispose();
  }

  int _applyKotlin(List<ComponentModel> comps) {
    final before = comps.map((c) => c.props.toString()).toList();
    parseKotlinOverrides(_ktCtrl.text, comps);
    var changed = 0;
    for (var i = 0; i < comps.length; i++) {
      if (comps[i].props.toString() != before[i]) changed++;
    }
    return changed;
  }

  void _save() {
    widget.screen.codeOverrides['xml'] = _xmlCtrl.text;
    widget.screen.codeOverrides['kotlin'] = _ktCtrl.text;

    // 1. XML drives the canvas: parse it and replace all components
    final parsed = parseXmlToComponents(_xmlCtrl.text);
    if (parsed.isNotEmpty) {
      widget.screen.components.clear();
      widget.screen.components.addAll(parsed);
    }

    // 2. Kotlin overrides on top of the XML result
    final ktApplied = _applyKotlin(widget.screen.components);

    widget.onChanged();
    setState(() {
      _xmlDirty = false;
      _ktDirty = false;
    });

    final parts = <String>[];
    if (parsed.isNotEmpty) {
      parts.add('${parsed.length} widget${parsed.length == 1 ? '' : 's'}');
    }
    if (ktApplied > 0) parts.add('$ktApplied Kotlin edit${ktApplied == 1 ? '' : 's'}');
    final msg = parts.isEmpty
        ? 'Saved - nothing recognizable to sync'
        : 'Saved - synced ${parts.join(" + ")}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF10B981)),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset to generated?'),
        content: const Text('Discard your edits and regenerate from the current design.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(context);
              widget.screen.codeOverrides.clear();
              setState(() {
                _xmlCtrl.text = exportXml(widget.screen);
                _ktCtrl.text = exportKotlin(widget.project, widget.screen);
                _xmlDirty = false;
                _ktDirty = false;
              });
              widget.onChanged();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final dirty = _xmlDirty || _ktDirty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Code Editor', style: TextStyle(fontSize: 15)),
            Text(widget.screen.name,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to generated',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy current tab',
            onPressed: () => _copy(_tabs.index == 0 ? _xmlCtrl.text : _ktCtrl.text),
          ),
          if (dirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          tabs: [
            Tab(text: _xmlDirty ? 'XML •' : 'XML'),
            Tab(text: _ktDirty ? 'Kotlin •' : 'Kotlin'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _editor(_xmlCtrl),
        _editor(_ktCtrl),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.screen.codeOverrides.isEmpty
                    ? 'Auto-generated from your design'
                    : 'Custom code — edits are saved with this screen',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _editor(TextEditingController ctrl) {
    return Container(
      color: const Color(0xFF0F172A),
      child: TextField(
        controller: ctrl,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFFE2E8F0),
          height: 1.55,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: '<!-- code -->',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
