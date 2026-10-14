import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../renderer.dart';
import '../theme.dart';
import '../widgets/phone_frame.dart';

class PreviewScreen extends StatefulWidget {
  final Project project;
  final String? startId;
  const PreviewScreen({super.key, required this.project, this.startId});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late String _currentId;

  @override
  void initState() {
    super.initState();
    _currentId = widget.startId ??
        (widget.project.screens.isNotEmpty ? widget.project.screens.first.id : '');
  }

  ScreenModel get _screen => widget.project.screens
      .firstWhere((s) => s.id == _currentId,
          orElse: () => widget.project.screens.first);

  bool get _isAtStart =>
      widget.project.screens.isNotEmpty &&
      _currentId == widget.project.screens.first.id;

  void _go(String? id) {
    if (id == null || id.isEmpty) return;
    if (!widget.project.screens.any((s) => s.id == id)) return;
    if (id == _currentId) return;
    HapticFeedback.selectionClick();
    setState(() => _currentId = id);
  }

  void _restart() {
    if (widget.project.screens.isEmpty) return;
    if (_isAtStart) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already at the first screen')));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _currentId = widget.project.screens.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final nextId = _screen.next;
    final hasNext =
        nextId != null && widget.project.screens.any((s) => s.id == nextId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        title: Text(_screen.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            onPressed: _restart,
            icon: Icon(
              Icons.restart_alt,
              size: 18,
              color: _isAtStart ? DC.muted(context) : AppTheme.primary,
            ),
            label: Text('Start',
                style: TextStyle(
                  color: _isAtStart ? DC.muted(context) : AppTheme.primary,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 130),
          child: PhoneFrame(
            title: _screen.name,
            screenBg: parseColor(_screen.bg, Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _screen.components.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                          child: Text('This screen is empty.',
                              style: TextStyle(color: DC.muted(context)))),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _screen.components.map((c) {
                        final linkId = (c.props['link'] ?? '').toString();
                        final linked = linkId.isNotEmpty &&
                            widget.project.screens.any((s) => s.id == linkId);
                        final body = ComponentRenderer(component: c);
                        if (!linked) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: body,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _go(linkId),
                            child: body,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
        if (hasNext)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: FilledButton.icon(
              onPressed: () => _go(nextId),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Continue to ${_project_next_name(nextId)}'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
            ),
          ),
      ]),
    );
  }

  String _project_next_name(String? id) {
    if (id == null) return 'next';
    final s = widget.project.screens.firstWhere(
      (x) => x.id == id,
      orElse: () => ScreenModel(id: '', name: 'next'),
    );
    return s.name;
  }
}
