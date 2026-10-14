import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../registry.dart';
import '../renderer.dart';
import '../services.dart';
import '../widgets/phone_frame.dart';
import 'preview_screen.dart';

class EditorScreen extends StatefulWidget {
  final Project project;
  const EditorScreen({super.key, required this.project});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Project _project;
  String? _screenId;
  String? _selectedId;

  ScreenModel get _screen => _project.screens
      .firstWhere((s) => s.id == _screenId, orElse: () => _project.screens.first);

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _screenId = _project.screens.isNotEmpty ? _project.screens.first.id : null;
  }

  Future<void> _persist() async {
    _project.updatedAt = DateTime.now();
    try {
      await context.read<ProjectService>().save(_project);
    } catch (_) {}
  }

  void _addComponent(String type) {
    final c = makeComponent(type);
    setState(() {
      _screen.components.add(c);
      _selectedId = c.id;
    });
    _persist();
  }

  void _selectScreen(String id) {
    setState(() {
      _screenId = id;
      _selectedId = null;
    });
  }

  void _onReorderScreens(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final s = _project.screens.removeAt(oldIndex);
      _project.screens.insert(newIndex, s);
    });
    _persist();
  }

  void _mutate(int idx, String act) {
    final comps = _screen.components;
    setState(() {
      if (act == 'del') {
        comps.removeAt(idx);
        _selectedId = null;
      } else if (act == 'dup') {
        comps.insert(idx + 1, comps[idx].clone());
        _selectedId = comps[idx + 1].id;
      } else if (act == 'up' && idx > 0) {
        final t = comps[idx - 1];
        comps[idx - 1] = comps[idx];
        comps[idx] = t;
      } else if (act == 'down' && idx < comps.length - 1) {
        final t = comps[idx + 1];
        comps[idx + 1] = comps[idx];
        comps[idx] = t;
      }
    });
    _persist();
  }

  Future<void> _addScreen() async {
    final name = await _prompt('New screen', 'Name your new screen',
        'Screen ${_project.screens.length + 1}');
    if (name == null || name.isEmpty) return;
    final s = ScreenModel(id: uid(), name: name);
    setState(() {
      _project.screens.add(s);
      _screenId = s.id;
      _selectedId = null;
    });
    _persist();
  }

  Future<String?> _prompt(String title, String sub, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    TextField(controller: ctrl, autofocus: true),
                  ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, ctrl.text.trim()),
                    child: const Text('Save')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text(_project.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addScreen),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      PreviewScreen(project: _project, startId: _screenId))),
              child: const Text('Preview',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _buildScreenTabs(),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: PhoneFrame(
              title: _screen.name,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _screen.components.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                            child: Text(
                          'Tap the + button below to place your first widget on this screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        )),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children:
                            List.generate(_screen.components.length, (i) {
                          final c = _screen.components[i];
                          final selected = c.id == _selectedId;
                          final linkId = (c.props['link'] ?? '').toString();
                          final linked = linkId.isNotEmpty;
                          final linkName = linked
                              ? _project.screens
                                  .firstWhere((s) => s.id == linkId,
                                      orElse: () => _screen)
                                  .name
                              : '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(clipBehavior: Clip.none, children: [
                              InkWell(
                                onTap: () {
                                  if (_selectedId == c.id) {
                                    _openProps(c);
                                  } else {
                                    setState(() => _selectedId = c.id);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF4F46E5)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: selected
                                        ? const Color(0xFFF0FDF4)
                                        : null,
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ComponentRenderer(component: c),
                                        if (selected)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  _iconBtn(Icons.arrow_upward,
                                                      () => _mutate(i, 'up')),
                                                  _iconBtn(Icons.arrow_downward,
                                                      () => _mutate(i, 'down')),
                                                  _iconBtn(Icons.copy,
                                                      () => _mutate(i, 'dup')),
                                                  _iconBtn(
                                                      Icons.delete_outline,
                                                      () => _mutate(i, 'del'),
                                                      danger: true),
                                                ]),
                                          ),
                                      ]),
                                ),
                              ),
                              if (linked)
                                Positioned(
                                  top: -8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('🔗 $linkName',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                            ]),
                          );
                        }),
                      ),
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _openLibrary,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _toolbarBtn('Text', () => _addComponent('text')),
            _toolbarBtn('Button', () => _addComponent('button')),
            _toolbarBtn('Input', () => _addComponent('input')),
            _toolbarBtn('Image', () => _addComponent('image')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: _openLibrary,
                child: const Text('+ More'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildScreenTabs() {
    return SizedBox(
      height: 56,
      child: Row(children: [
        Expanded(
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: _project.screens.length,
            onReorder: _onReorderScreens,
            itemBuilder: (ctx, i) {
              final s = _project.screens[i];
              final active = s.id == _screenId;
              return ReorderableDelayedDragStartListener(
                key: ValueKey(s.id),
                index: i,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: active
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _selectScreen(s.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(children: [
                          if (i == 0)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                            ),
                          Text(s.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              )),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _openScreenMenu(s.id),
                            child: Icon(Icons.more_horiz,
                                size: 16,
                                color: active
                                    ? Colors.white70
                                    : Colors.grey.shade500),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton.icon(
            onPressed: _addScreen,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Screen',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool danger = false}) =>
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(6)),
            child: Icon(icon,
                size: 16,
                color: danger ? const Color(0xFFEF4444) : Colors.grey.shade800),
          ),
        ),
      );

  Widget _toolbarBtn(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ActionChip(
          backgroundColor: const Color(0xFFEEF2FF),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5))),
          onPressed: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );

  void _openLibrary() {
    final cats = <String, List<MapEntry<String, ComponentDef>>>{};
    registry.forEach((k, v) {
      cats.putIfAbsent(v.category, () => []).add(MapEntry(k, v));
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Add Widget',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Tap a widget to place it on "${_screen.name}"',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            ...cats.entries.map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(e.key.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1)),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                      children: e.value.map((entry) {
                        final def = entry.value;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(context);
                            _addComponent(entry.key);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              border: Border.all(
                                  color: const Color(0xFFE5E7EB), width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(def.icon,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(def.name,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _openProps(ComponentModel c) async {
    final def = registry[c.type]!;
    final props = c.props;
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${def.icon}  ${def.name}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Edit widget properties - changes apply instantly',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 18),
                  if (def.fields.contains('text'))
                    _input('Text', props['text']?.toString() ?? '',
                        (v) => setSt(() => props['text'] = v)),
                  if (def.fields.contains('color'))
                    _colorRow(
                        'Text color',
                        props['color']?.toString() ?? '#111827',
                        (v) => setSt(() => props['color'] = v)),
                  if (def.fields.contains('bg'))
                    _colorRow(
                        'Background',
                        props['bg']?.toString() ?? '#6200EE',
                        (v) => setSt(() => props['bg'] = v)),
                  if (def.fields.contains('size'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                              'Size - ${(props['size'] ?? 14)}px',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey)),
                        ),
                        Slider(
                          value: ((props['size'] ?? 14) as num).toDouble(),
                          min: 8,
                          max: 40,
                          divisions: 32,
                          activeColor: const Color(0xFF4F46E5),
                          onChanged: (v) => setSt(
                              () => props['size'] = v.round()),
                        ),
                      ],
                    ),
                  if (def.fields.contains('on'))
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enabled',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      value: props['on'] == true,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (v) => setSt(() => props['on'] = v),
                    ),
                  if (def.fields.contains('align'))
                    _segRow(
                        'Alignment',
                        ['left', 'center', 'right'],
                        props['align']?.toString() ?? 'left',
                        (v) => setSt(() => props['align'] = v)),
                  if (def.fields.contains('link'))
                    _dropdown(
                        'Tap → go to screen',
                        props['link']?.toString() ?? '',
                        _project.screens,
                        (v) => setSt(() => props['link'] = v)),
                  const SizedBox(height: 20),
                  Row(children: [
                    OutlinedButton(
                      onPressed: () {
                        final i = _screen.components
                            .indexWhere((x) => x.id == c.id);
                        if (i >= 0) _screen.components.removeAt(i);
                        _selectedId = null;
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('Delete'),
                    ),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5)),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Done'),
                    ),
                  ]),
                ]),
          ),
        ),
      ),
    );
    if (updated == true) {
      setState(() {});
      _persist();
    }
  }

  Widget _input(String label, String value, ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.8)),
          ),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.5)),
            ),
          ),
        ]),
      );

  Widget _colorRow(String label, String value, ValueChanged<String> onChanged) {
    final options = [
      '#111827', '#6B7280', '#FFFFFF', '#6200EE', '#4F46E5', '#EF4444', '#10B981', '#F59E0B'
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.8)),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: options.map((c) {
          final sel = c.toLowerCase() == value.toLowerCase();
          return GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: parseColor(c),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? const Color(0xFF4F46E5) : Colors.black12,
                    width: sel ? 3 : 1),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _segRow(String label, List<String> options, String value,
          ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.8)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Row(children: options.map((o) {
              final on = o == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(o),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: on ? const Color(0xFF4F46E5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                        o[0].toUpperCase() + o.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: on ? Colors.white : Colors.grey)),
                  ),
                ),
              );
            }).toList()),
          ),
        ]),
      );

  Widget _dropdown(String label, String value, List<ScreenModel> screens,
          ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.8)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: screens.any((s) => s.id == value) ? value : '',
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: '', child: Text('None')),
                  ...screens.map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) => onChanged(v ?? ''),
              ),
            ),
          ),
        ]),
      );

  Future<void> _openScreenMenu(String sid) async {
    final idx = _project.screens.indexWhere((s) => s.id == sid);
    if (idx < 0) return;
    final s = _project.screens[idx];
    final action = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(22),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(s.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Screen ${idx + 1} of ${_project.screens.length}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename'),
                    onTap: () => Navigator.pop(context, 'rename')),
                ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Duplicate'),
                    onTap: () => Navigator.pop(context, 'duplicate')),
                ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Set as start'),
                    onTap: () => Navigator.pop(context, 'start')),
                ListTile(
                    leading: const Icon(Icons.delete,
                        color: Color(0xFFEF4444)),
                    title: const Text('Delete',
                        style: TextStyle(color: Color(0xFFEF4444))),
                    onTap: () => Navigator.pop(context, 'delete')),
              ]),
            ));

    if (action == 'rename') {
      final v =
          await _prompt('Rename screen', 'Give this screen a new name', s.name);
      if (v != null && v.isNotEmpty) {
        setState(() => s.name = v);
        _persist();
      }
    } else if (action == 'duplicate') {
      setState(() => _project.screens.insert(idx + 1, s.clone()));
      _persist();
    } else if (action == 'start') {
      setState(() {
        final m = _project.screens.removeAt(idx);
        _project.screens.insert(0, m);
      });
      _persist();
    } else if (action == 'delete') {
      if (_project.screens.length <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You need at least one screen')));
        }
        return;
      }
      setState(() {
        _project.screens.removeAt(idx);
        if (_screenId == sid) _screenId = _project.screens.first.id;
        _selectedId = null;
      });
      _persist();
    }
  }
}
