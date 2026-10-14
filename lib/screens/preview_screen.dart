import 'package:flutter/material.dart';
import '../models.dart';
import '../renderer.dart';
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

  void _go(String id) {
    if (widget.project.screens.any((s) => s.id == id)) {
      setState(() => _currentId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        title: Text(_screen.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => _go(widget.project.screens.first.id),
            child: const Text('Start'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: PhoneFrame(
          title: _screen.name,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _screen.components.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: Text('This screen is empty.',
                            style: TextStyle(color: Colors.grey))),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _screen.components.map((c) {
                      final linkId = (c.props['link'] ?? '').toString();
                      final linked = linkId.isNotEmpty &&
                          widget.project.screens.any((s) => s.id == linkId);
                      final body = ComponentRenderer(component: c);
                      if (!linked) return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: body,
                      );
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
    );
  }
}
