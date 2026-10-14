import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class FlowScreen extends StatefulWidget {
  final Project project;
  final VoidCallback onChanged;
  const FlowScreen({super.key, required this.project, required this.onChanged});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  List<ScreenModel> get screens => widget.project.screens;

  void _rebuildChain() {
    for (int i = 0; i < screens.length; i++) {
      screens[i].next = (i + 1 < screens.length) ? screens[i + 1].id : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Flow')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Text('Design your navigation flow',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.text(context))),
          const SizedBox(height: 4),
          Text('Long-press the handle to drag a screen. Order rebuilds the chain.',
              style: TextStyle(color: DC.muted(context), fontSize: 12)),
          const SizedBox(height: 20),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: screens.length,
            onReorder: (oldI, newI) {
              if (newI > oldI) newI -= 1;
              setState(() {
                final moved = screens.removeAt(oldI);
                screens.insert(newI, moved);
                _rebuildChain();
              });
              widget.onChanged();
            },
            itemBuilder: (ctx, i) => _screenNode(i, screens[i]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add Screen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _screenNode(int i, ScreenModel s) {
    final isFirst = i == 0;
    final prev = i > 0 ? screens[i - 1] : null;
    final connected = prev != null && prev.next == s.id;

    return Container(
      key: ValueKey(s.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        if (!isFirst)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 2,
              height: 20,
              color: connected ? AppTheme.primary : DC.border(context),
            ),
          ]),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DC.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFirst ? AppTheme.primary : DC.border(context),
              width: 1.5,
            ),
            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: isFirst
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.12),
                child: Text('${i + 1}',
                    style: TextStyle(
                      color: isFirst ? Colors.white : AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: DC.text(context))),
              ),
              if (isFirst)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('START',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
              const SizedBox(width: 4),
              if (i > 0)
                _miniBtn(Icons.keyboard_arrow_up, () => _move(i, i - 1)),
              if (i < screens.length - 1)
                _miniBtn(Icons.keyboard_arrow_down, () => _move(i, i + 1)),
              ReorderableDragStartListener(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child:
                      Icon(Icons.drag_indicator, color: DC.muted(context), size: 22),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.widgets_outlined, size: 14, color: DC.muted(context)),
              const SizedBox(width: 6),
              Text('${s.components.length} widget${s.components.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              const Spacer(),
              GestureDetector(
                onTap: () => _renameScreen(s),
                child: const Text('Rename',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              if (!isFirst)
                GestureDetector(
                  onTap: () => _deleteScreen(s),
                  child: const Icon(Icons.delete_outline,
                      size: 16, color: AppTheme.danger),
                ),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: DC.subtle(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DC.border(context)),
              ),
              child: Row(children: [
                const Icon(Icons.arrow_forward, size: 15, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Goes to',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DC.muted(context))),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: screens.any((x) => x.id == s.next) ? s.next : null,
                      isExpanded: true,
                      isDense: true,
                      dropdownColor: DC.surface(context),
                      style: TextStyle(color: DC.text(context), fontSize: 13),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: Text('(end of flow)',
                                style: TextStyle(
                                    fontSize: 13, color: DC.muted(context)))),
                        ...screens
                            .where((x) => x.id != s.id)
                            .map((x) => DropdownMenuItem(
                                  value: x.id,
                                  child: Text(x.name,
                                      style: const TextStyle(fontSize: 13)),
                                )),
                      ],
                      onChanged: (v) {
                        setState(() => s.next = v);
                        widget.onChanged();
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(3),
          child: Icon(icon, size: 20, color: DC.muted(context)),
        ),
      );

  void _move(int from, int to) {
    if (to < 0 || to >= screens.length) return;
    setState(() {
      final m = screens.removeAt(from);
      screens.insert(to, m);
      _rebuildChain();
    });
    widget.onChanged();
  }

  void _renameScreen(ScreenModel s) {
    final ctrl = TextEditingController(text: s.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename screen'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context);
              setState(() => s.name = v);
              widget.onChanged();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteScreen(ScreenModel s) {
    setState(() {
      screens.removeWhere((x) => x.id == s.id);
      for (final x in screens) {
        if (x.next == s.id) x.next = null;
      }
      _rebuildChain();
    });
    widget.onChanged();
  }

  void _addScreen() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Screen'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Home, Profile'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              setState(() {
                final s = ScreenModel(id: uid(), name: name);
                if (screens.isNotEmpty && screens.last.next == null) {
                  screens.last.next = s.id;
                }
                screens.add(s);
              });
              widget.onChanged();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
