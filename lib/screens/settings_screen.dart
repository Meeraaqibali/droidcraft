import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backup.dart';
import '../services.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    final projSvc = context.watch<ProjectService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('APPEARANCE'),
          _card(children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              secondary: Icon(theme.mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use dark theme across the app', style: TextStyle(fontSize: 12)),
              value: theme.mode == ThemeMode.dark,
              activeColor: AppTheme.primary,
              onChanged: (_) => context.read<ThemeService>().toggle(),
            ),
          ]),
          const SizedBox(height: 20),
          _section('FONT STYLE'),
          _card(children: AppTheme.fontOptions.entries.map((e) {
            final on = theme.font == e.value;
            return ListTile(
              onTap: () => context.read<ThemeService>().setFont(e.value),
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: on ? AppTheme.primary : Colors.grey),
              title: Text(e.key,
                  style: TextStyle(
                      fontFamily: e.value,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
              subtitle: Text('The quick brown fox',
                  style: TextStyle(fontFamily: e.value, fontSize: 12, color: Colors.grey)),
            );
          }).toList()),
          const SizedBox(height: 20),
          _section('DATA'),
          _card(children: [
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Projects', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${projSvc.projects.length} saved', style: const TextStyle(fontSize: 12)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Color(0xFFEF4444)),
              title: const Text('Clear all projects',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
              subtitle: const Text('Permanently delete every saved project', style: TextStyle(fontSize: 12)),
              onTap: () => _confirmClear(context, projSvc),
            ),
          ]),
          const SizedBox(height: 20),
          _section('BACKUP & RESTORE'),
          _card(children: [
            ListTile(
              leading: const Icon(Icons.upload_outlined, color: Color(0xFF4F46E5)),
              title: const Text('Export backup', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Copy all projects as JSON text', style: TextStyle(fontSize: 12)),
              onTap: () => Backup.showBackupSheet(context, projSvc.projects, (list) async {
                await projSvc.replaceAll(list);
              }),
            ),
          ]),
          const SizedBox(height: 20),
          _section('ABOUT'),
          _card(children: const [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('DroidCraft', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Design Android UI visually\nVersion 1.0.0', style: TextStyle(fontSize: 12)),
              isThreeLine: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(children: children),
        ),
      );

  void _confirmClear(BuildContext ctx, ProjectService svc) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear all projects?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await svc.clearAll();
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('All projects cleared')));
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
