import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backup.dart';
import '../services.dart';
import '../theme.dart';
import '../widgets/pressable.dart';

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
          _section(context, 'APPEARANCE'),
          _card(context, children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              secondary: Icon(theme.mode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode),
              title: Text('Dark mode',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: DC.text(context))),
              subtitle: Text('Use dark theme across the app',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              value: theme.mode == ThemeMode.dark,
              activeColor: AppTheme.primary,
              onChanged: (_) => context.read<ThemeService>().toggle(),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, 'DATA'),
          _card(context, children: [
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text('Projects',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: DC.text(context))),
              subtitle: Text('${projSvc.projects.length} saved',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
            ),
            Divider(height: 1, color: DC.border(context)),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined,
                  color: AppTheme.danger),
              title: const Text('Clear all projects',
                  style: TextStyle(
                      color: AppTheme.danger, fontWeight: FontWeight.w600)),
              subtitle: Text('Permanently delete every saved project',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              onTap: () => _confirmClear(context, projSvc),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, 'BACKUP & RESTORE'),
          _card(context, children: [
            ListTile(
              leading: const Icon(Icons.upload_outlined,
                  color: AppTheme.primary),
              title: Text('Export backup',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: DC.text(context))),
              subtitle: Text('Copy all projects as JSON text',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              onTap: () => Backup.showBackupSheet(
                  context, projSvc.projects,
                  (list) async => await projSvc.replaceAll(list)),
            ),
            Divider(height: 1, color: DC.border(context)),
            ListTile(
              leading: const Icon(Icons.download_outlined,
                  color: AppTheme.primary),
              title: Text('Restore backup',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: DC.text(context))),
              subtitle: Text('Paste a JSON backup to restore',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              onTap: () => Backup.showBackupSheet(
                  context, projSvc.projects,
                  (list) async => await projSvc.replaceAll(list)),
            ),
          ]),
          const SizedBox(height: 20),
          _section(context, 'ABOUT'),
          _card(context, children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('DroidCraft',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: DC.text(context))),
              subtitle: Text('Design Android UI visually\nVersion 1.0.0',
                  style: TextStyle(fontSize: 12, color: DC.muted(context))),
              isThreeLine: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext ctx, String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(t,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: DC.muted(ctx),
                letterSpacing: 1)),
      );

  Widget _card(BuildContext ctx, {required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: DC.surface(ctx),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DC.border(ctx)),
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
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await svc.clearAll();
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('All projects cleared')));
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
