import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';

class Backup {
  static String exportAll(List<Project> projects) {
    final data = {
      'app': 'DroidCraft',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'projects': projects.map((p) => p.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static List<Project> parseImport(String raw) {
    final j = jsonDecode(raw);
    if (j is! Map || j['projects'] == null) {
      throw 'Not a DroidCraft backup file';
    }
    return (j['projects'] as List)
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> showBackupSheet(BuildContext ctx, List<Project> projects, Future<void> Function(List<Project>) onRestore) async {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Backup & Restore',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${projects.length} project${projects.length == 1 ? '' : 's'} available',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            _card(
              icon: Icons.upload_outlined,
              title: 'Export backup',
              subtitle: 'Copy all projects as JSON text — paste into any file or app',
              onTap: () {
                final json = Backup.exportAll(projects);
                Clipboard.setData(ClipboardData(text: json));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Backup copied (${json.length} chars)'),
                  backgroundColor: const Color(0xFF10B981),
                ));
              },
            ),
            const SizedBox(height: 12),
            _card(
              icon: Icons.download_outlined,
              title: 'Restore backup',
              subtitle: 'Paste JSON backup below to restore',
              onTap: () => _showRestoreDialog(ctx, onRestore),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      );

  static void _showRestoreDialog(BuildContext ctx, Future<void> Function(List<Project>) onRestore) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Restore backup'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Paste the JSON backup text below.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 8,
            autofocus: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            decoration: const InputDecoration(
              hintText: '{"app":"DroidCraft",...}',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () async {
              try {
                final list = Backup.parseImport(ctrl.text);
                Navigator.pop(ctx);
                await onRestore(list);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Restored ${list.length} project${list.length == 1 ? '' : 's'}'),
                    backgroundColor: const Color(0xFF10B981),
                  ));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Invalid backup: $e'),
                    backgroundColor: const Color(0xFFEF4444),
                  ));
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
