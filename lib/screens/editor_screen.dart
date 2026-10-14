import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../exporter.dart';
import '../models.dart';
import '../nav.dart';
import '../registry.dart';
import '../renderer.dart';
import '../services.dart';
import '../theme.dart';
import '../widgets/phone_frame.dart';
import '../widgets/pressable.dart';
import 'code_editor_screen.dart';
import 'flow_screen.dart';
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
                        style: TextStyle(color: DC.muted(context), fontSize: 12)),
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
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () => Navigator.of(context).push(slideUpRoute(CodeEditorScreen(
                    project: _project,
                    screen: _screen,
                    onChanged: () {
                      if (mounted) setState(() {});
                      _persist();
                    }))),
            tooltip: 'Edit Code',
          ),
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => Navigator.of(context).push(slideRoute(FlowScreen(
                project: _project,
                onChanged: () {
                  if (mounted) setState(() {});
                  _persist();
                }))),
            tooltip: 'App Flow',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => showExportSheet(context, _project, _screen),
            tooltip: 'Export',
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: _addScreen),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () => Navigator.of(context).push(slideRoute(
                  PreviewScreen(project: _project, startId: _screenId))),
              child: const Text('Preview',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _buildScreenTabs(),
        Divider(height: 1, color: DC.border(context)),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.05, 0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic))
                    .animate(anim),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey(_screen.id),
              padding: const EdgeInsets.only(bottom: 120),
              child: PhoneFrame(
              title: _screen.name,
              screenBg: parseColor(_screen.bg, Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _screen.components.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                            child: Text(
                          'Tap the + button below to place your first widget on this screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: DC.muted(context)),
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
                                          ? AppTheme.primary
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
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _openLibrary,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: DC.surface(context),
          border: Border(top: BorderSide(color: DC.border(context))),
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
                    backgroundColor: AppTheme.primary,
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
    return Container(
      color: DC.surface(context),
      child: SizedBox(
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
                          ? AppTheme.primary
                          : DC.subtle(context),
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
                                      : DC.muted(context),
                                )),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _openScreenMenu(s.id),
                              child: Icon(Icons.more_horiz,
                                  size: 16,
                                  color: active
                                      ? Colors.white70
                                      : DC.muted(context)),
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
      ),
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
                size: 16, color: danger ? AppTheme.danger : Colors.grey.shade800),
          ),
        ),
      );

  Widget _toolbarBtn(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ActionChip(
          backgroundColor: AppTheme.primary.withOpacity(0.12),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
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
      backgroundColor: DC.surface(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Text('Add Widget',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DC.text(ctx))),
            const SizedBox(height: 4),
            Text('Tap a widget to place it on "${_screen.name}"',
                style: TextStyle(color: DC.muted(ctx), fontSize: 12)),
            const SizedBox(height: 16),
            ...cats.entries.map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(e.key.toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: DC.muted(ctx),
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
                              color: DC.subtle(ctx),
                              border:
                                  Border.all(color: DC.border(ctx), width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(def.icon,
                                      size: 24, color: AppTheme.primary),
                                  const SizedBox(height: 6),
                                  Text(def.name,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: DC.text(ctx))),
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
      backgroundColor: DC.surface(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${def.name}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DC.text(ctx))),
                  const SizedBox(height: 4),
                  Text('Edit widget properties - changes apply instantly',
                      style: TextStyle(color: DC.muted(ctx), fontSize: 12)),
                  const SizedBox(height: 18),
                  if (c.type == 'image')
                    _imagePickerRow(ctx, c, props, setSt),
                  if (def.fields.contains('text'))
                    _input(ctx, 'Text', props['text']?.toString() ?? '',
                        (v) => setSt(() => props['text'] = v)),
                  if (def.fields.contains('color'))
                    _colorRow(ctx, 'Text color',
                        props['color']?.toString() ?? '#111827',
                        (v) => setSt(() => props['color'] = v)),
                  if (def.fields.contains('bg'))
                    _colorRow(ctx, 'Background',
                        props['bg']?.toString() ?? '#6200EE',
                        (v) => setSt(() => props['bg'] = v)),
                  if (def.fields.contains('size'))
                    _sliderRow(
                        ctx,
                        'Size',
                        '${(props['size'] ?? 14).toInt()}px',
                        ((props['size'] ?? 14) as num).toDouble(),
                        8,
                        40,
                        32,
                        (v) => setSt(() => props['size'] = v.round())),
                  if (def.fields.contains('radius'))
                    _sliderRow(
                        ctx,
                        'Corner radius',
                        '${(props['radius'] ?? 0).toInt()}px',
                        ((props['radius'] ?? 0) as num).toDouble(),
                        0,
                        40,
                        40,
                        (v) => setSt(() => props['radius'] = v.round())),
                  if (def.fields.contains('padding'))
                    _sliderRow(
                        ctx,
                        'Padding',
                        '${(props['padding'] ?? 0).toInt()}px',
                        ((props['padding'] ?? 0) as num).toDouble(),
                        0,
                        24,
                        24,
                        (v) => setSt(() => props['padding'] = v.round())),
                  if (def.fields.contains('bold'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('STYLE',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: DC.muted(ctx),
                                    letterSpacing: 0.8)),
                          ),
                          Row(children: [
                            Expanded(
                              child: _styleToggle(ctx, 'Bold',
                                  Icons.format_bold, props['bold'] == true,
                                  () => setSt(() => props['bold'] =
                                      props['bold'] != true)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _styleToggle(ctx, 'Italic',
                                  Icons.format_italic, props['italic'] == true,
                                  () => setSt(() => props['italic'] =
                                      props['italic'] != true)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _styleToggle(ctx, 'Underline',
                                  Icons.format_underlined,
                                  props['underline'] == true,
                                  () => setSt(() => props['underline'] =
                                      props['underline'] != true)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  if (def.fields.contains('letterSpacing'))
                    _sliderRow(
                        ctx,
                        'Letter spacing',
                        ((props['letterSpacing'] ?? 0) as num).toStringAsFixed(1),
                        ((props['letterSpacing'] ?? 0) as num).toDouble(),
                        -2,
                        8,
                        20,
                        (v) => setSt(() => props['letterSpacing'] =
                            double.parse(v.toStringAsFixed(1)))),
                  if (def.fields.contains('lineHeight'))
                    _sliderRow(
                        ctx,
                        'Line height',
                        ((props['lineHeight'] ?? 1.4) as num).toStringAsFixed(1),
                        ((props['lineHeight'] ?? 1.4) as num).toDouble(),
                        0.8,
                        3.0,
                        22,
                        (v) => setSt(() => props['lineHeight'] =
                            double.parse(v.toStringAsFixed(1)))),
                  if (def.fields.contains('on'))
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Enabled',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: DC.text(ctx))),
                      value: props['on'] == true,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setSt(() => props['on'] = v),
                    ),
                  if (def.fields.contains('align'))
                    _segRow(
                        ctx,
                        'Alignment',
                        ['left', 'center', 'right'],
                        props['align']?.toString() ?? 'left',
                        (v) => setSt(() => props['align'] = v)),
                  if (def.fields.contains('link'))
                    _dropdown(ctx, 'Tap to go to screen',
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
                          backgroundColor: AppTheme.primary),
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

  Widget _imagePickerRow(BuildContext ctx, ComponentModel c,
      Map<String, dynamic> props, void Function(void Function()) setSt) {
    final path = (props['path'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('IMAGE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DC.muted(ctx),
                    letterSpacing: 0.8)),
          ),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                onPressed: () async {
                  final picker = ImagePicker();
                  final x = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1600);
                  if (x != null) {
                    setSt(() => props['path'] = x.path);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                label: Text(path.isEmpty ? 'Pick from gallery' : 'Change image'),
              ),
            ),
            if (path.isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                onPressed: () => setSt(() => props['path'] = ''),
              ),
            ],
          ]),
          if (path.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(path.split('/').last,
                  style: TextStyle(
                      fontSize: 10, color: DC.muted(ctx)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  Widget _sliderRow(BuildContext ctx, String label, String valueText,
      double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('$label - $valueText',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: DC.muted(ctx))),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _styleToggle(BuildContext ctx, String label, IconData icon, bool on,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: on
              ? AppTheme.primary.withOpacity(0.12)
              : DC.subtle(ctx),
          border: Border.all(
            color: on ? AppTheme.primary : DC.border(ctx),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon,
              size: 20,
              color: on ? AppTheme.primary : DC.muted(ctx)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: on ? AppTheme.primary : DC.muted(ctx),
              )),
        ]),
      ),
    );
  }

  Widget _input(BuildContext ctx, String label, String value,
          ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DC.muted(ctx),
                    letterSpacing: 0.8)),
          ),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            style: TextStyle(color: DC.text(ctx)),
            decoration: InputDecoration(
              filled: true,
              fillColor: DC.inputFill(ctx),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: DC.border(ctx), width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: DC.border(ctx), width: 1.5)),
            ),
          ),
        ]),
      );

  Widget _colorRow(BuildContext ctx, String label, String value,
      ValueChanged<String> onChanged) {
    final options = [
      '#111827',
      '#6B7280',
      '#FFFFFF',
      '#6200EE',
      '#4F46E5',
      '#EF4444',
      '#10B981',
      '#F59E0B'
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: DC.muted(ctx),
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
                    color: sel ? AppTheme.primary : DC.border(ctx),
                    width: sel ? 3 : 1),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }

  Widget _segRow(BuildContext ctx, String label, List<String> options,
          String value, ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DC.muted(ctx),
                    letterSpacing: 0.8)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DC.subtle(ctx),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DC.border(ctx), width: 1.5),
            ),
            child: Row(children: options.map((o) {
              final on = o == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(o),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: on ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(o[0].toUpperCase() + o.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: on ? Colors.white : DC.muted(ctx))),
                  ),
                ),
              );
            }).toList()),
          ),
        ]),
      );

  Widget _dropdown(BuildContext ctx, String label, String value,
          List<ScreenModel> screens, ValueChanged<String> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DC.muted(ctx),
                    letterSpacing: 0.8)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: DC.inputFill(ctx),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DC.border(ctx), width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: screens.any((s) => s.id == value) ? value : '',
                isExpanded: true,
                dropdownColor: DC.surface(ctx),
                style: TextStyle(color: DC.text(ctx)),
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

  Future<String?> _pickScreenColor(String current) {
    const options = [
      '#FFFFFF', '#F5F6FA', '#111827', '#0F172A',
      '#6200EE', '#4F46E5', '#EF4444', '#10B981',
      '#F59E0B', '#FEF3C7', '#FCE7F3', '#DBEAFE',
    ];
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: DC.surface(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Screen background',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DC.text(context))),
            const SizedBox(height: 4),
            Text('Choose a background color for this screen',
                style: TextStyle(color: DC.muted(context), fontSize: 12)),
            const SizedBox(height: 18),
            Wrap(spacing: 10, runSpacing: 10, children: options.map((c) {
              final sel = c.toLowerCase() == current.toLowerCase();
              return GestureDetector(
                onTap: () => Navigator.pop(context, c),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: parseColor(c, Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? AppTheme.primary : DC.border(context),
                      width: sel ? 3 : 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 4),
                    ],
                  ),
                  child: sel
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Future<void> _openScreenMenu(String sid) async {
    final idx = _project.screens.indexWhere((s) => s.id == sid);
    if (idx < 0) return;
    final s = _project.screens[idx];
    final action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: DC.surface(context),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => Padding(
              padding: const EdgeInsets.all(22),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(s.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DC.text(context))),
                const SizedBox(height: 4),
                Text('Screen ${idx + 1} of ${_project.screens.length}',
                    style: TextStyle(color: DC.muted(context))),
                const SizedBox(height: 16),
                ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Background color'),
                    onTap: () => Navigator.pop(context, 'bg')),
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
                    leading: const Icon(Icons.delete, color: AppTheme.danger),
                    title: const Text('Delete',
                        style: TextStyle(color: AppTheme.danger)),
                    onTap: () => Navigator.pop(context, 'delete')),
              ]),
            ));

    if (action == 'bg') {
      final pick = await _pickScreenColor(s.bg);
      if (pick != null) {
        setState(() => s.bg = pick);
        _persist();
      }
    } else if (action == 'rename') {
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
